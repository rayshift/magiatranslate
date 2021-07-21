#!/bin/bash
BASEDIR="$(realpath "$(dirname "${0}")")"

# env-based
BASH="${BASH:-bash}" # /bin/bash
CMAKE="${MT_CMAKE:-cmake}" # /usr/bin/cmake
NINJA="${MT_NINJA:-ninja}" # /usr/bin/ninja
CURL="${MT_CURL:-curl}" # /usr/bin/curl
JAVA="${MT_JAVA:-java}" # /usr/bin/java
PYTHON="${MT_PYTHON:-python3}" # /usr/bin/python3.8
JARSIGNER="${MT_JARSIGNER:-jarsigner}" # /usr/bin/jarsigner
APKTOOL="${MT_APKTOOL:-apktool_2.5.0.jar}"

# arg-based
SRCAPK="${1:-${BASEDIR}/apk/vanilla.apk}"
VERSION="${2:-v0.50}"
NDK="${3:-${BASEDIR}/ndk/android-ndk-r21e}"
FORCEOW="${4:-true}"

RESULT="${BASEDIR}/build/io.kamihama.magiatranslate.${VERSION}.apk"

_pre() {
	if [ ! -f "${SRCAPK}" ]
	then
		echo "Did not find MagiReco APK! Tried path: ${SRCAPK}"
		_errorexit 5
	fi
	echo "Found apk ${SRCAPK}"

	if [ ! -d "${NDK}" ]
	then
		echo "NDK directory does not exist! Tried path: ${NDK}"
		_errorexit 6
	fi
	NDK=$(realpath "${NDK}")
	echo "Found ndk directory ${NDK}"

	if [ ! -f "${NDK}/build/cmake/android.toolchain.cmake" ]
	then
		echo "NDK is missing! Unpack it into ${NDK}"
		_errorexit 7
	fi

	for executie in ${BASH} ${CMAKE} ${NINJA} ${CURL} ${JAVA} ${PYTHON}
	do
		[ -x "$(command -v "${executie}")" ] || echo "Warning: ${executie} is missing, please install or provide path via environment"
	done

	_start
}

_start() {
	mkdir -p "${BASEDIR}/build"

	[ ! -f "${BASEDIR}/build/${APKTOOL}" ] && _get_apktool

	[[ ! -d "${BASEDIR}/build/app/" || "${FORCEOW}" = true ]] && _create

	_build
}

_get_apktool() {
	echo "Downloading apktool..."
	${CURL} -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -o "${BASEDIR}/build/${APKTOOL}" -L "https://bitbucket.org/iBotPeaches/apktool/downloads/${APKTOOL}"
}

_create() {
	echo "Removing existing build files..."
	rm -rf "${BASEDIR}/build/app"
	echo "Running apktool..."
	${JAVA} -jar "${BASEDIR}/build/${APKTOOL}" d "${SRCAPK}" -o "${BASEDIR}/build/app/"
	mkdir -p "${BASEDIR}/build/app/smali/com/loadLib"
	mkdir -p "${BASEDIR}/build/app/lib/arm64-v8a"

	echo "Applying smali patches..."
	git -C "${BASEDIR}" apply --stat "${BASEDIR}/patches/NativeBridge.patch"
	git -C "${BASEDIR}" apply --stat "${BASEDIR}/patches/Hook.patch"
	git -C "${BASEDIR}" apply "${BASEDIR}/patches/NativeBridge.patch"
	git -C "${BASEDIR}" apply "${BASEDIR}/patches/Hook.patch"
	echo "Applying misc patches..."
	# cp "${BASEDIR}/patches/images/story_ui_sprites00_patch.plist" "${BASEDIR}/build/app/assets/package/story/story_ui_sprites00.plist"
	# cp "${BASEDIR}/patches/images/story_ui_sprites00_patch.png" "${BASEDIR}/build/app/assets/package/story/story_ui_sprites00.png"

	cp "${BASEDIR}/patches/koruri-semibold.ttf" "${BASEDIR}/build/app/assets/fonts/koruri-semibold.ttf"

	echo "Updating sprites and AndroidManifest.xml..."
	${PYTHON} "${BASEDIR}/buildassets.py"
}


_build() {
	echo "Copying new smali files..."
	cp ${BASEDIR}/smali/loader/*.smali "${BASEDIR}/build/app/smali/com/loadLib/"
	mkdir -p ${BASEDIR}/build/app/smali_classes2/io/kamihama/magianative
	echo "Copying magianative..."
	cp ${BASEDIR}/smali/MagiaNative/app/src/main/java/io/kamihama/magianative/*.smali "${BASEDIR}/build/app/smali_classes2/io/kamihama/magianative/"
	echo "Copying libraries..."
	cp -r "${BASEDIR}/smali/okhttp-smali/okhttp3/" "${BASEDIR}/build/app/smali_classes2/okhttp3/"
	cp -r "${BASEDIR}/smali/okhttp-smali/okio/" "${BASEDIR}/build/app/smali_classes2/okio/"
	echo "Copying unknown..."
	cp -r "${BASEDIR}/patches/unknown/" "${BASEDIR}/build/app/unknown/"
	cp "${BASEDIR}/patches/strings.xml" "${BASEDIR}/build/app/res/values/strings.xml"

	echo "Building libraries."

	rm -rf "${BASEDIR}/build/arm64-v8a"
	mkdir -p "${BASEDIR}/build/arm64-v8a"

	echo "Running cmake arm64-v8a..."
	cd "${BASEDIR}/build/arm64-v8a"
	${CMAKE} -G Ninja \
		-DANDROID_ABI="arm64-v8a" \
		-DCMAKE_BUILD_TYPE:STRING="Release" \
		-DCMAKE_INSTALL_PREFIX:PATH="${BASEDIR}/build/arm64-v8a" \
		-DCMAKE_TOOLCHAIN_FILE:FILEPATH="${NDK}/build/cmake/android.toolchain.cmake" \
		-DCMAKE_MAKE_PROGRAM:FILEPATH="${NINJA}" \
		-DANDROID_PLATFORM="21" \
		-DCMAKE_SYSTEM_NAME="Android" \
		-DCMAKE_ANDROID_ARCH_ABI="arm64-v8a" \
		-DCMAKE_ANDROID_NDK="${NDK}" \
		-DCMAKE_SYSTEM_VERSION="16" \
		-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION="clang" \
		-DDOBBY_DEBUG="OFF" \
		"${BASEDIR}/"
	[ "$?" -ne "0" ] && _errorexit 1
	${NINJA}
	[ "$?" -ne "0" ] && _errorexit 2

	echo "Copying libraries..."
	cp "${BASEDIR}/build/arm64-v8a/libuwasa.so" "${BASEDIR}/build/app/lib/arm64-v8a/libuwasa.so"
	cp "${BASEDIR}/abiproxy/build/arm64-v8a/libabiproxy.so" "${BASEDIR}/build/app/lib/arm64-v8a/libabiproxy.so"

	echo "Rebuilding APK..."
	${JAVA} -jar "${BASEDIR}/build/${APKTOOL}" b "${BASEDIR}/build/app/" -o "${RESULT}"

	_signandupload
}

_signandupload() {
	echo "Signing apk..."
	if [ ! -f "${BASEDIR}/sign.sh" ]
	then
		echo "Signer is missing! It must be there: ${BASEDIR}/sign.sh"
		_errorexit 8
	fi
	${BASH} "${BASEDIR}/sign.sh" "${RESULT}"
	[ "$?" -ne "0" ] && _errorexit 3 || _exit
}

_errorexit() {
	echo "An error has occurred, exiting."
	exit ${1}
}

_exit() {
	echo "Finished!"
	exit 0
}

_pre
