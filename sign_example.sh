#!/bin/bash
BASEDIR="$(realpath "$(dirname "${0}")")"

# env-based
ZIPALIGN="${MT_ZIPALIGN:-zipalign}" # ~/android-sdk/build-tools/zipalign
APKSIGNER="${MT_APKSIGNER:-apksigner}" # ~/android-sdk/build-tools/apksigner

# hardcode-based
#ZIPALIGN="${BASEDIR}/abt/zipalign"
#APKSIGNER="${BASEDIR}/abt/apksigner"

# arg-based
APK="${1:-${BASEDIR}/build/com.aniplex.magireco.v0.50.apk}"
KEYSTORE="${2:-${BASEDIR}/changeme.keystore}"

_errorexit() {
	[ -z "${2}" ] || echo "${2}"
	echo "Signing failed."
	exit ${1}
}

[ -f "${APK}" ] || _errorexit 1 "Missing apk to sign! Tried file: ${APK}"
[ -f "${KEYSTORE}" ] || _errorexit 2 "Missing keystore! Tried file: ${KEYSTORE}"

echo "Doing zipalign..."
"${ZIPALIGN}" -f -p 4 "${APK}" "${APK}.tmp"
[ "$?" -ne "0" ] && _errorexit 3 "Failed to zipalign!"
echo "Removing tmp file..."
mv "${APK}.tmp" "${APK}"

echo "Doing apksign..."
"${APKSIGNER}" sign --ks "${KEYSTORE}" --ks-pass pass:changeme --ks-key-alias name "${APK}"
[ "$?" -ne "0" ] && _errorexit 4 "Failed to apksign!"

exit 0
