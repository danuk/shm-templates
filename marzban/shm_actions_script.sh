#!/bin/bash

set -e

EVENT="{{ event_name }}"
SESSION_ID="{{ user.gen_session.id }}"
API_URL="{{ config.api.url }}"

echo "EVENT=$EVENT"

get_marzban_token() {
    if [ -f "/opt/marzban/.env" ]; then
        export $(grep '^SUDO_USERNAME' /opt/marzban/.env | sed 's/ //g')
        export $(grep '^SUDO_PASSWORD' /opt/marzban/.env | sed 's/ //g')

        export TOKEN=$(curl -s -X 'POST' \
          "http://127.0.0.1:8000/api/admin/token" \
          -H 'Content-Type: application/x-www-form-urlencoded' \
          -d "grant_type=password&username=$SUDO_USERNAME&password=$SUDO_PASSWORD" | jq -r .access_token)

        if [ -z "$TOKEN" ]; then
            echo 'Error: can not get TOKEN. Please check docker containers status'
        fi
    else
        echo 'Error: Marzban has not been installed yet'
        exit 1
    fi
}

case $EVENT in
    INIT)
        export SERVER_HOST="{{ server.settings.host_name }}"
        if [ -z $SERVER_HOST ]; then
            echo "ERROR: set variable 'host_name' to server settings"
            exit 1
        fi

        echo "Install required packages"
        apt-get update
        apt-get install -y \
            curl \
            pwgen \
            jq

        echo "Check SHM API host: $API_URL"
        set +e
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $API_URL/shm/v1/test)
        RET_CODE=$?
        if [ $RET_CODE -ne 0 ]; then
            echo "Error: host $API_URL is incorrect."
            echo "Please set correct public host in SHM config. It must be accessible from the server."
            exit 1
        fi
        if [ $HTTP_CODE -ne '200' ]; then
            echo "ERROR: incorrect API URL: $API_URL"
            echo "Got status: $HTTP_CODE"
            exit 1
        fi
        set -e

        echo "Install Marzban..."
        export SUDO_USERNAME=admin
        export SUDO_PASSWORD=$(pwgen -n 16 -1)
        bash -c "$(curl -sL https://github.com/danuk/shm-templates/raw/main/marzban/marzban.sh)" @ install
        echo "done"

        echo "Setup Marzban..."
        sleep 5
        get_marzban_token
        bash -c "$(curl -sL https://github.com/danuk/shm-templates/raw/main/marzban/marzban-setup.sh)"
        echo "done"
        ;;
    CREATE)
        echo "Create a new user"

        PAYLOAD="$(cat <<-EOF
        {
          "username": "us_{{ us.id }}",
          "proxies": {
            "vmess": {},
            "vless": {"flow": ""},
            "trojan": {},
            "shadowsocks": {
              "method": "chacha20-poly1305"
            }
          },
          "data_limit": 0,
          "expire": null,
          "data_limit_reset_strategy": "no_reset",
          "status": "active",
          "inbounds": {
            "vmess": [
              "VMess TCP",
              "VMess Websocket"
            ],
            "vless": [
              "VLESS TCP REALITY",
              "VLESS GRPC REALITY"
            ],
            "trojan": [
              "Trojan Websocket TLS"
            ],
            "shadowsocks": [
              "Shadowsocks TCP"
            ]
          }
        }
EOF
        )"

        get_marzban_token
        USER_CFG=$(curl -s -X 'POST' \
          "http://127.0.0.1:8000/api/user" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d "$PAYLOAD")

        if [ -z "$USER_CFG" ]; then
            echo "Error: can't create a new user"
            exit 1
        fi

        echo "Upload user config to SHM: vpn_mrzb_{{ us.id }}"
        curl -s -XPUT \
            -H "session-id: $SESSION_ID" \
            -H "Content-Type: application/json" \
            $API_URL/shm/v1/storage/manage/vpn_mrzb_{{ us.id }} \
            --data-binary "$USER_CFG"
        echo "done"
        ;;
    ACTIVATE)
        echo "Activate user"

        get_marzban_token
        curl -s -X 'PUT' \
          "http://127.0.0.1:8000/api/user/us_{{ us.id }}" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d '{"status":"active"}'

        echo "done"
        ;;
    BLOCK)
        echo "Block user"

        get_marzban_token
        curl -s -X 'PUT' \
          "http://127.0.0.1:8000/api/user/us_{{ us.id }}" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d '{"status":"disabled"}'

        echo "done"
        ;;
    REMOVE)
        echo "Remove user"

        get_marzban_token
        curl -s -X 'DELETE' \
          "http://127.0.0.1:8000/api/user/us_{{ us.id }}" \
          -H "Authorization: Bearer $TOKEN"

        echo "Remove user key from SHM"
        curl -s -XDELETE \
            -H "session-id: $SESSION_ID" \
            $API_URL/shm/v1/storage/manage/vpn_mrzb_{{ us.id }}
        echo "done"
        ;;
    *)
        echo "Unknown event: $EVENT. Exit."
        exit 0
        ;;
esac

