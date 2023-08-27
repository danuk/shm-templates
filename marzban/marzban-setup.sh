#!/usr/bin/env bash
set -e

[ -z "$SERVER_HOST" ] && echo "Error: SERVER_HOST not defined" && exit 1
[ -z "$TOKEN" ] && echo "Error: TOKEN not defined" && exit 1

PAYLOAD="$(cat <<-EOF
{
  "VMess TCP": [
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
  ],
  "VMess Websocket": [
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
  ],
  "VLESS TCP REALITY": [
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
  ],
  "VLESS GRPC REALITY": [
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
  ],
  "Trojan Websocket TLS": [
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
  ],
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

curl -s -X 'PUT' \
  "http://127.0.0.1:8000/api/hosts" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD"


