#!/bin/bash

export SUBSCRIPTION_DOMAIN="{{ server.settings.subscription_domain }}"
export EMAIL_FOR_CERTIFICATE_ISSUE="{{ config.acme.email_for_certificate_issue }}"

EVENT="{{ event_name }}"
SESSION_ID="{{ user.gen_session.id }}"
API_URL="{{ config.api.url }}"

echo "Marzban Template v1"
echo
echo "EVENT=$EVENT"

get_marzban_token() {
    if [ -f "/opt/marzban/.env" ]; then
        export $(grep '^SUDO_USERNAME' /opt/marzban/.env | sed 's/ //g')
        export $(grep '^SUDO_PASSWORD' /opt/marzban/.env | sed 's/ //g')
        export $(grep '^UVICORN_PORT' /opt/marzban/.env | sed 's/ //g')

        if [[ $(grep '^UVICORN_SSL_CERTFILE' /opt/marzban/.env) ]]; then
            export MARZBAN_HOST="https://127.0.0.1:$UVICORN_PORT"
        else
            export MARZBAN_HOST="http://127.0.0.1:$UVICORN_PORT"
        fi

        echo "Marzban host: $MARZBAN_HOST"

        [ -z "$SUDO_USERNAME" ] && echo 'Error: SUDO_USERNAME not defined in /opt/marzban/.env' && exit 1
        [ -z "$SUDO_PASSWORD" ] && echo 'Error: SUDO_PASSWORD not defined in /opt/marzban/.env' && exit 1

        export TOKEN=$(curl -sk -XPOST \
          "$MARZBAN_HOST/api/admin/token" \
          -H 'Content-Type: application/x-www-form-urlencoded' \
          -d "grant_type=password&username=$SUDO_USERNAME&password=$SUDO_PASSWORD" | jq -r .access_token)

        if [ -z "$TOKEN" ]; then
            echo 'Error: can not get TOKEN. Please check docker containers status'
            exit 1
        fi
    else
        echo 'Error: Marzban has not been installed yet'
        exit 1
    fi
}

case $EVENT in
    INIT)
        export SERVER_HOST="{{ server.host.remove('.*@') }}"
        if [ -z $SERVER_HOST ]; then
            echo "ERROR: can't get server host"
            exit 1
        fi

        echo "Install required packages"
        apt-get update
        apt-get install -y \
            curl \
            pwgen \
            net-tools \
            socat \
            jq

        echo "Install Marzban..."
        export SUDO_USERNAME=admin
        export SUDO_PASSWORD=$(pwgen -n 16 -1)
        bash -c "$(curl -sL https://github.com/danuk/shm-templates/raw/main/marzban/marzban.sh)" @ install
        echo "done"
        echo

        echo "Setup Marzban..."
        sleep 5
        get_marzban_token
        bash -c "$(curl -sL https://github.com/danuk/shm-templates/raw/main/marzban/marzban-setup.sh)"
        echo "done"

        echo "Check SHM API host: $API_URL"
        HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" $API_URL/shm/v1/test)
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
        USER_CFG=$(curl -sk -XPOST \
          "$MARZBAN_HOST/api/user" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d "$PAYLOAD")

        if [ -z $(echo "$USER_CFG" | jq -r '.username | select( . != null )') ]; then
            echo "Error: $USER_CFG"
            exit 1
        fi

        echo "Upload user config to SHM: vpn_mrzb_{{ us.id }}"
        curl -sk -XPUT \
            -H "session-id: $SESSION_ID" \
            -H "Content-Type: application/json" \
            $API_URL/shm/v1/storage/manage/vpn_mrzb_{{ us.id }} \
            --data-binary "$USER_CFG"
        echo "done"
        ;;
    ACTIVATE)
        echo "Activate user"

        get_marzban_token
        curl -sk -XPUT \
          "$MARZBAN_HOST/api/user/us_{{ us.id }}" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d '{"status":"active"}'

        echo "done"
        ;;
    BLOCK)
        echo "Block user"

        get_marzban_token
        curl -sk -XPUT \
          "$MARZBAN_HOST/api/user/us_{{ us.id }}" \
          -H "Authorization: Bearer $TOKEN" \
          -H 'Content-Type: application/json' \
          -d '{"status":"disabled"}'

        echo "done"
        ;;
    REMOVE)
        echo "Remove user"

        get_marzban_token
        curl -sk -XDELETE \
          "$MARZBAN_HOST/api/user/us_{{ us.id }}" \
          -H "Authorization: Bearer $TOKEN"

        echo "Remove user key from SHM"
        curl -sk -XDELETE \
            -H "session-id: $SESSION_ID" \
            $API_URL/shm/v1/storage/manage/vpn_mrzb_{{ us.id }}
        echo "done"
        ;;
    PROLONGATE)
        echo "Reset user counters"

        get_marzban_token
        curl -sk -XPOST \
          "$MARZBAN_HOST/api/user/us_{{ us.id }}/reset" \
          -H "Authorization: Bearer $TOKEN"
        echo "done"
        ;;
    *)
        echo "Unknown event: $EVENT. Exit."
        exit 0
        ;;
esac

