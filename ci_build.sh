#!/bin/bash
set -e

BASEDIR="$(realpath "$(dirname "${0}")")"

# prepare signing key
[[ "${KEYSTORE_BASE64}" == "" ]] && echo "KEYSTORE_BASE64 is not set" >&2 && exit 1
[[ "${KS_PASS}" == "" ]] && echo "KS_PASS is not set" >&2 && exit 1
echo "${KEYSTORE_BASE64}" | base64 -d > "${BASEDIR}/builder.jks" 2> /dev/null
KEYSTORE_ARGS="--ks \"${BASEDIR}/builder.jks\" --ks-pass \"pass:${KS_PASS}\""
[[ "${KEY_PASS}" != "" ]] && echo "KEY_PASS is set!" >&2 && KEYSTORE_ARGS="${KEYSTORE_ARGS} --key-pass \"pass:${KEY_PASS}\""
[[ "${KS_KEY_ALIAS}" != "" ]] && echo "KS_KEY_ALIAS is set!" >&2 && KEYSTORE_ARGS="${KEYSTORE_ARGS} --ks-key-alias \"${KS_KEY_ALIAS}\""
unset KEYSTORE_BASE64
unset KS_PASS
unset KEY_PASS
unset KS_KEY_ALIAS
cp sign_example.sh sign.sh
sed -E -i "s@^(\"\\\$\{APKSIGNER\}\" sign ).+( \"\\\$\{APK\}\")\$@\\1${KEYSTORE_ARGS}\\2@" sign.sh 2>&1 > /dev/null
sed -i "s@^KEYSTORE=.*@KEYSTORE=\"${BASEDIR}/builder.jks\"@" sign.sh 2>&1 > /dev/null
chmod +x sign.sh

# prepare source APKs
MT_VER=$(grep -P -o "(?<=^#define MT_VERSION )\d+$" src/Config.h)
. ci_versions/src_apk.sh
SRCAPK="${BASEDIR}/apk/src_${SRCAPK_VER}.apk"
export ARMV7SRCAPK="${BASEDIR}/armv7apk/armv7src_${SRCAPK_VER}.apk"
VERSION="v${SRCAPK_VER}_v${MT_VER}"

# load deps versions
. ci_versions/deps.sh
DEPS_DIR="${BASEDIR}/deps"
# prepare apktool
export MT_APKTOOL="apktool_${APKTOOL_VER}.jar"
mkdir -p "${BASEDIR}/build"
cp "${DEPS_DIR}/${MT_APKTOOL}" "${BASEDIR}/build/${MT_APKTOOL}"
# prepare Android SDK
SDK_ROOT="${DEPS_DIR}/Android/Sdk"
NDK="${SDK_ROOT}/ndk/${NDK_VER}"
CMAKE_BIN_DIR="${SDK_ROOT}/cmake/${CMAKE_VER}/bin"
BUILD_TOOLS_DIR="${SDK_ROOT}/build-tools/${BUILD_TOOLS_VER}"
export MT_CMAKE="${CMAKE_BIN_DIR}/cmake"
export MT_NINJA="${CMAKE_BIN_DIR}/ninja"
export MT_ZIPALIGN="${BUILD_TOOLS_DIR}/zipalign"
export MT_APKSIGNER="${BUILD_TOOLS_DIR}/apksigner"

RESULT="${BASEDIR}/build/io.kamihama.magiatranslate.${VERSION}.apk"

# build failsafe APK which does not contain audiofix
MT_AUDIOFIX_3_0_1=N "${BASEDIR}/build_release.sh" "${SRCAPK}" "${VERSION}" "${NDK}"
FAILSAFE_APK="MagiaTranslate_${VERSION}_failsafe.apk"
mv "${RESULT}" "${BASEDIR}/${FAILSAFE_APK}"
echo "FAILSAFE_APK=${FAILSAFE_APK}" >> "$GITHUB_ENV"

# patch failsafe APK to build main APK
echo "Unpacking APK without decompiling..."
REUNPACK_DIR="${BASEDIR}/build/reunpacked/"
rm -fr "${REUNPACK_DIR}"
java -jar "${BASEDIR}/build/${MT_APKTOOL}" d --no-src --no-res "${FAILSAFE_APK}" -o "${REUNPACK_DIR}"
echo "Applying audiofix..."
node "${BASEDIR}/patches/audiofix.js" --wdir "${REUNPACK_DIR}" --overwrite
echo "Rebuilding APK..."
java -jar "${BASEDIR}/build/${MT_APKTOOL}" b "${REUNPACK_DIR}" -o "${RESULT}"
echo "Signing APK..."
${BASH} "${BASEDIR}/sign.sh" "${RESULT}"
MAIN_APK="MagiaTranslate_${VERSION}.apk"
mv "${RESULT}" "${BASEDIR}/${MAIN_APK}"
echo "MAIN_APK=${MAIN_APK}" >> "$GITHUB_ENV"

rm "${BASEDIR}/builder.jks"