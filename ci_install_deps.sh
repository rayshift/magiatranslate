#!/bin/bash
set -e

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"

. ci_versions/deps.sh

rm -fr deps
mkdir deps
cd deps

mkdir -p Android/Sdk
pushd Android/Sdk
curl -A "${UA}" -o "commandlinetools-linux.zip" -L "${COMMANDLINETOOLS_URL}"
sha256sum "commandlinetools-linux.zip" | grep -q "${COMMANDLINETOOLS_SHA256}"
unzip "commandlinetools-linux.zip"
rm "commandlinetools-linux.zip"
yes | ./cmdline-tools/bin/sdkmanager --sdk_root="$(realpath .)" --licenses
for PKG in "cmake;${CMAKE_VER}" "ndk;${NDK_VER}" "build-tools;${BUILD_TOOLS_VER}"; do
    ./cmdline-tools/bin/sdkmanager --sdk_root="$(realpath .)" --install "${PKG}"
done
popd

# apktool
APKTOOL="apktool_${APKTOOL_VER}.jar"
curl -A "${UA}" -o "${APKTOOL}" -L "https://bitbucket.org/iBotPeaches/apktool/downloads/${APKTOOL}"
sha256sum "${APKTOOL}" | grep -q "${APKTOOL_SHA256}"