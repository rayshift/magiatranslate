#!/bin/bash
BASEDIR="$(realpath "$(dirname "${0}")")"

# env-based
JARSIGNER="${MT_JARSIGNER:-jarsigner}" # /usr/bin/jarsigner

# arg-based
APK="${1:-${BASEDIR}/build/io.kamihama.magiatranslate.v0.50.apk}"
KEYSTORE="${2:-${BASEDIR}/changeme.keystore}"

if [ ! -f "${APK}" ]
then
	echo "Missing apk to sign! Tried file: ${APK}"
	exit 1
fi
if [ ! -f "${KEYSTORE}" ]
then
	echo "Missing keystore! Tried file: ${KEYSTORE}"
	exit 2
fi

${JARSIGNER} -sigalg SHA512withRSA -digestalg SHA-512 -keystore "${KEYSTORE}" "${APK}" -storepass changeme name
