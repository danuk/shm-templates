#!/bin/bash

HOST="https://admin.DOMAIN"
PASS=''

curl -u "admin:$PASS" \
     -X "POST" \
     -H "Content-Type: text/html; charset=utf-8" \
     $HOST/shm/v1/admin/template/wg_manager \
     --data-binary @shm_actions_script.sh


