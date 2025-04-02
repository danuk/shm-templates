#!/usr/bin/env bash
set -e

[ -z "$SERVER_HOST" ] && echo "Error: SERVER_HOST not defined" && exit 1
[ -z "$TOKEN" ] && echo "Error: TOKEN not defined" && exit 1

echo "Configure Marzban server host..."
PAYLOAD="$(cat <<-EOF
{
  "Shadowsocks TCP": [
    {
      "remark": "🚀 Marz ({USERNAME}) [{PROTOCOL} - {TRANSPORT}]",
      "address": "$SERVER_HOST",
      "port": null,
      "sni": null,
      "host": null,
      "security": "inbound_default",
      "alpn": "",
      "fingerprint": ""
    }
  ]
}
EOF
)"

curl -sk -XPUT \
  "$MARZBAN_HOST/api/hosts" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD"

echo "done\n"

echo "Configure certificates..."
echo "SUBSCRIPTION_DOMAIN=$SUBSCRIPTION_DOMAIN"
echo "EMAIL_FOR_CERTIFICATE_ISSUE=$EMAIL_FOR_CERTIFICATE_ISSUE"

if [[ -z "$SUBSCRIPTION_DOMAIN" || -z "$EMAIL_FOR_CERTIFICATE_ISSUE" ]]; then
    echo "WARNING: Skipping the certificate installation due to the absence of a SUBSCRIPTION_DOMAIN or EMAIL_FOR_CERTIFICATE_ISSUE"
    echo "Set the SUBSCRIPTION_DOMAIN variable in the server settings (subscription_domain)"
    echo "Set the EMAIL_FOR_CERTIFICATE_ISSUE variable in the config (acme.email_for_certificate_issue)"
    exit 0
fi

DIR=/var/lib/marzban/certs
mkdir -p $DIR

if [[ ! -f "$DIR/fullchain.pem" ]]; then
    curl -s https://get.acme.sh | sh -s email=$EMAIL_FOR_CERTIFICATE_ISSUE

    #Сертификат будет обновляться каждые 60 дней по умолчанию. После обновления сертификата marzban будет автоматически перезагружен.
    ~/.acme.sh/acme.sh \
        --set-default-ca \
        --server letsencrypt \
        --issue \
        --standalone \
        -d $SUBSCRIPTION_DOMAIN || true

   ~/.acme.sh/acme.sh \
        -d $SUBSCRIPTION_DOMAIN \
        --installcert \
        --key-file $DIR/key.pem \
        --fullchain-file $DIR/fullchain.pem \
        --reloadcmd "marzban restart -n"

    echo 'UVICORN_SSL_CERTFILE = "/var/lib/marzban/certs/fullchain.pem"' >> /opt/marzban/.env
    echo 'UVICORN_SSL_KEYFILE = "/var/lib/marzban/certs/key.pem"' >> /opt/marzban/.env

    sed -i 's/^UVICORN_PORT\s*=\s*8000/UVICORN_PORT = 443/' /opt/marzban/.env
    echo "XRAY_SUBSCRIPTION_URL_PREFIX = \"https://$SUBSCRIPTION_DOMAIN\"" >> /opt/marzban/.env

    echo "done"
fi

echo "Download template and docker-compose file with template..."
cd /opt/marzban
curl -sLO https://github.com/danuk/shm-templates/raw/main/marzban/docker-compose.yml
curl -sLO https://github.com/danuk/shm-templates/raw/main/marzban/template_subscription_index.html
echo "done"

marzban restart -n

