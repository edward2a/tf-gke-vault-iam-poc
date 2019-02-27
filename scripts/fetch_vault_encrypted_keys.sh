#!/bin/bash

LIMIT=12
IDX=0

eval $(jq -r '@sh "SIGNED_URL=\(.signed_url)"')


while ((IDX < LIMIT)); do
    if ENCRYPTED_DATA="$(curl -sf "${SIGNED_URL}" 2>/dev/null | base64 -w0)"; ret=$?; then
        break
    else
        sleep 10s
        let IDX++
    fi
done
(( ${ret} == 0 )) || { echo "ERROR: curl exit ${ret}" 1>&2; exit ${ret}; }


jq -ncM --arg encrypted_data "${ENCRYPTED_DATA}" '{"encrypted_data":$encrypted_data}'
