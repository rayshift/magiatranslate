#!/bin/bash
set -e
set -o pipefail

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"

CHECKSUM_URL="https://jp.rika.ren/apk/Origin/checksum.txt"

. ci_versions/src_apk.sh

LATEST_SRCAPK_VER=$(curl -s -A "${UA}" -L "${CHECKSUM_URL}" | grep -E -i "^Version\s+name:\s+" | tail -n1 | grep -P -o "(\\d+\\.)+\\d+$")

if echo "${SRCAPK_VER}" | grep -q -P "^(\\d+\\.)+\\d+$" && echo "${LATEST_SRCAPK_VER}" | grep -q -P "^(\\d+\\.)+\\d+$"; then
    if [[ "${SRCAPK_VER}" != "${LATEST_SRCAPK_VER}" ]]; then
        echo "latest-src-apk-ver=${LATEST_SRCAPK_VER}"
        echo "new-version-available=true"
    fi
fi