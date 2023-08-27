#!/bin/bash

EVENT="{{ event_name }}"
SESSION_ID="{{ user.gen_session.id }}"
API_URL="{{ config.api.url }}"

set -e

echo "EVENT=$EVENT"

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

        echo "Check domain: $API_URL"
        set +e
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $API_URL/shm/v1/test)
        RET_CODE=$?
        [ $RET_CODE -ne 0 ] && exit 1
        if [ $HTTP_CODE -ne '200' ]; then
            echo "ERROR: incorrect API URL: $API_URL"
            echo "Got status: $HTTP_CODE"
            exit 1
        fi
        set -e

        echo "Install Marzban"
        export SUDO_USERNAME=admin
        export SUDO_PASSWORD=$(pwgen -n 16 -1)
        bash -c "$(curl -sL https://github.com/danuk/shm-templates/raw/main/marzban/marzban.sh)" @ install

        echo "Setup Marzban"
        get_marzban_token()
        bash -c "$(curl -sL https://github.com/danuk/shm-templates/raw/main/marzban/marzban-setup.sh)"

        echo "done"
        ;;
    CREATE)
        echo "Create new user"

        PAYLOAD="$(cat <<-EOF
        {
          "username": "{{ user.id }}",
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

        USER_CFG=$(curl -s -X 'POST' \
          "http://127.0.0.1:8000/api/user" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d "$PAYLOAD")

        echo "Upload user config to SHM"
        curl -s -XPUT \
            -H "session-id: $SESSION_ID" \
            -H "Content-Type: text/plain" \
            $API_URL/shm/v1/storage/manage/vpn_mrzb_{{ us.id }} \
            --data-binary "$USER_CFG"
        echo "done"
        ;;
    ACTIVATE)
        echo "Activate user"

        get_marzban_token()
        curl -s -X 'PUT' \
          "http://127.0.0.1/api/user/{{ user.id }}" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d '{"status":"active"}'

        echo "done"
        ;;
    BLOCK)
        echo "Block user"

        get_marzban_token()
        curl -s -X 'PUT' \
          "http://127.0.0.1/api/user/{{ user.id }}" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d '{"status":"disabled"}'

        echo "done"
        ;;
    REMOVE)
        echo "Remove user"

        get_marzban_token()
        curl -s -X 'DELETE' \
          "http://127.0.0.1/api/user/{{ user.id }}" \
          -H "Authorization: Bearer $TOKEN"

        echo "Remove user key from SHM"
        $CURL -s -XDELETE \
            -H "session-id: $SESSION_ID" \
            $API_URL/shm/v1/storage/manage/vpn_mrzb_{{ us.id }}
        echo "done"
        ;;
    *)
        echo "Unknown event: $EVENT. Exit."
        exit 0
        ;;
esac

get_marzban_token() {
    if [ -f "/opt/marzban/.env" ]; then
        export $(grep '^SUDO_USERNAME' /opt/marzban/.env | sed 's/ //g')
        export $(grep '^SUDO_PASSWORD' /opt/marzban/.env | sed 's/ //g')

        export TOKEN=$(curl -s -X 'POST' \
          "http://127.0.0.1:8000/api/admin/token" \
          -H 'Content-Type: application/x-www-form-urlencoded' \
          -d "grant_type=password&username=$SUDO_USERNAME&password=$SUDO_PASSWORD" | jq -r .access_token)
    else
        echo 'Error: Marzban has not been installed yet'
        exit 1
    fi
}

