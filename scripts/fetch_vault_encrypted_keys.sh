#!/bin/bash

LIMIT=12
IDX=0

eval $(jq -r '@sh "SIGNED_URL=\(.signed_url)"')

echo "signed url: ${SIGNED_URL}" > crypt_data.log
while true; do

    ENCRYPTED_DATA="$(curl -sf "${SIGNED_URL}" 2>>crypt_data.log | base64 -w0)"

    if (( ${#ENCRYPTED_DATA} > 0 )); then
        break

    else

        if (( IDX > LIMIT )); then

            if (( ! ${#ENCRYPTED_DATA} > 0 )); then

                echo "ERROR: ciphertext length is ${#ENCRYPTED_DATA}" 1>&2
                exit 1

            fi

        fi

        sleep 10s
        let IDX++

    fi
done
echo "${ENCRYPTED_DATA}" >> crypt_data.log
jq -ncM --arg encrypted_data "${ENCRYPTED_DATA}" '{"encrypted_data":$encrypted_data}'
