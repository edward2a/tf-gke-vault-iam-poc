#!/bin/bash

# SUBMODULE LOADER - Because I can't get git submodule to work properly
# The file location is relative to the repo root
# Submodule file format:
#   path repo-url branch||commit||tag \n

if [ -z "${1}" ]; then
    echo "ERROR: missing submodules file argument => ${0} <submodules-file>"
    exit 1
fi

SCRIPT_PATH=$(readlink -f ${0})
SCRIPT_DIR=${SCRIPT_PATH%/*}
BASE_DIR=${SCRIPT_DIR%/*}
MODULES_FILE=${BASE_DIR}/${1}

if [ ! -r ${MODULES_FILE} ]; then
    echo "ERROR: File ${MODULES_FILE} not accessible"
    exit 1
fi

while read RPATH REPO BRANCH; do
    if [ -d ${RPATH} ]; then rm -rf ${RPATH}; fi
    git clone --depth=1 --branch ${BRANCH} ${REPO} ${RPATH}
done<${MODULES_FILE}

