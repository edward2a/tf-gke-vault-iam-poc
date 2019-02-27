#!/bin/bash
set -o pipefail


# Parse input from TF
eval $(jq -r '@sh "VAULT_ADDR=\(.vault_address) GOOGLE_PROJECT=\(.google_project) DATA=\(.key_data)"')


VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8200}


# Decrypt # handling it in TF
#DATA="$(gcloud kms decrypt --location=global --keyring=vault --key=vault-init --plaintext-file=/dev/stdout \
#    --ciphertext-file=<(gsutil cati gs://${GOOGLE_PROJECT}-vault-assets/vault_unseal_keys.txt.encrypted))"


# Extract items as required
UNSEAL_KEYS=($(grep -Po '(Unseal Key [1-5]: ).*? ' <<<${DATA} | awk '{ print $4 }'))
ROOT_TOKEN=$(grep -Po '(Root Token: ).*? ' <<<${DATA} | awk '{ print $3 }')


# Get seal status
SEAL_STATUS="$(curl -skf https://${VAULT_ADDR}/v1/sys/seal-status | jq -r .sealed)"; ret=${?}
((ret == 0)) || { echo "ERROR: curl exit ${ret}" 1>&2; exit ${ret}; }


# Unseal if required
if ${SEAL_STATUS}; then
    for UNSEAL_KEY in ${UNSEAL_KEYS[*]}; do
        curl -X POST -skf --connect-timeout 5 -o /dev/null --data "{\"key\":\"${UNSEAL_KEY}\"}" https://${VAULT_ADDR}/v1/sys/unseal
        ret=${?}
        ((${ret} == 0)) || { echo "ERROR: curl exit ${ret}" 1>&2; exit ${ret}; }
    done
fi


# Output for tf
jq -ncM --arg root_token "${ROOT_TOKEN}" '{"root_token":$root_token}'

