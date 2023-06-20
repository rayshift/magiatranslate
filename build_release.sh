#!/bin/bash
BASEDIR="$(realpath "$(dirname "${0}")")"

# env-based
BASH="${BASH:-bash}" # /bin/bash
CMAKE="${MT_CMAKE:-cmake}" # /usr/bin/cmake
NINJA="${MT_NINJA:-ninja}" # /usr/bin/ninja
CURL="${MT_CURL:-curl}" # /usr/bin/curl
JAVA="${MT_JAVA:-java}" # /usr/bin/java
PYTHON="${MT_PYTHON:-python3}" # /usr/bin/python3.8
NODEJS="${MT_NODEJS:-node}" # /usr/bin/node
APKTOOL="${MT_APKTOOL:-apktool_2.6.0.jar}"
ZIPALIGN="${MT_ZIPALIGN:-zipalign}" # ~/android-sdk/build-tools/zipalign
APKSIGNER="${MT_APKSIGNER:-apksigner}" # ~/android-sdk/build-tools/apksigner

ARMV7SRCAPK="${ARMV7SRCAPK:-${BASEDIR}/armv7apk/vanilla-armv7.apk}"

# arg-based
SRCAPK="${1:-${BASEDIR}/apk/vanilla.apk}"
VERSION="${2:-v0.50}"
NDK="${3:-${BASEDIR}/ndk/android-ndk-r21e}"
FORCEOW="${4:-true}"
TARCHS="${5:-"armeabi-v7a arm64-v8a"}"

RESULT="${BASEDIR}/build/io.kamihama.magiatranslate.${VERSION}.apk"

_pre() {
	[ -f "${SRCAPK}" ] || _errorexit 5 "Did not find MagiReco APK! Tried path: ${SRCAPK}"
	echo "Found apk ${SRCAPK}"

	if [[ "${TARCHS}" == *"armeabi-v7a"* ]]; then
		[ -f "${ARMV7SRCAPK}" ] || _errorexit 5 "Did not find ARMv7 MagiReco APK! Tried path: ${ARMV7SRCAPK}"
		echo "Found ARMv7 apk ${ARMV7SRCAPK}"
	fi

	[ -d "${NDK}" ] || _errorexit 6 "NDK directory does not exist! Tried path: ${NDK}"
	NDK=$(realpath "${NDK}")
	echo "Found ndk directory ${NDK}"

	[ -f "${NDK}/build/cmake/android.toolchain.cmake" ] || _errorexit 7 "NDK is missing! Unpack it into ${NDK}"

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
	rm -rf "${BASEDIR}/build/armv7/app"
	echo "Running apktool..."
	${JAVA} -jar "${BASEDIR}/build/${APKTOOL}" d "${SRCAPK}" -o "${BASEDIR}/build/app/"
	mkdir -p "${BASEDIR}/build/app/smali/com/loadLib"
	for tarch in ${TARCHS}
	do
		mkdir -p "${BASEDIR}/build/app/lib/${tarch}"
	done

	if [[ "${TARCHS}" == *"armeabi-v7a"* ]]; then
		echo "Extracting ARMv7 lib..."
		${JAVA} -jar "${BASEDIR}/build/${APKTOOL}" d "${ARMV7SRCAPK}" --no-src --no-res -o "${BASEDIR}/build/armv7/app"
		mv "${BASEDIR}/build/armv7/app/lib/armeabi-v7a/"* "${BASEDIR}/build/app/lib/armeabi-v7a/"
		rm -rf "${BASEDIR}/build/armv7/app"
	fi

	echo "Applying smali patches..."
	local PATCHES=(
		"NativeBridge.patch"
		"Hook.patch"
		"Backtrace.patch"
	)
	local PATCH
	for PATCH in "${PATCHES[@]}"; do
		git -C "${BASEDIR}" apply --stat "${BASEDIR}/patches/${PATCH}"
		git -C "${BASEDIR}" apply "${BASEDIR}/patches/${PATCH}"
	done
	echo "Applying misc patches..."
	# cp "${BASEDIR}/patches/images/story_ui_sprites00_patch.plist" "${BASEDIR}/build/app/assets/package/story/story_ui_sprites00.plist"
	# cp "${BASEDIR}/patches/images/story_ui_sprites00_patch.png" "${BASEDIR}/build/app/assets/package/story/story_ui_sprites00.png"

	# Fix low-pitched audio bug since magireco 3.0.1
	# This was once done with MagiaHook.
	# However, due to unexplained reason,
	# that hook made the game engine probabilistically fail to create OpenSLES player,
	# thus the game would get silenced in that way.
	"${NODEJS}" "${BASEDIR}/patches/audiofix.js" --wdir "${BASEDIR}/build/app" --overwrite

	cp "${BASEDIR}/patches/koruri-semibold.ttf" "${BASEDIR}/build/app/assets/fonts/koruri-semibold.ttf"

	echo "Updating sprites and AndroidManifest.xml..."
	${PYTHON} "${BASEDIR}/buildassets.py"
}


_build() {
	echo "Copying new smali files..."
	cp "${BASEDIR}"/smali/loader/*.smali "${BASEDIR}/build/app/smali/com/loadLib/"
	mkdir -p "${BASEDIR}/build/app/smali/io/kamihama/magianative"
	echo "Copying magianative..."
	cp "${BASEDIR}"/smali/MagiaNative/app/src/main/java/io/kamihama/magianative/*.smali "${BASEDIR}/build/app/smali/io/kamihama/magianative/"
	echo "Copying libraries..."
	cp -r "${BASEDIR}/smali/okhttp-smali/okhttp3/" "${BASEDIR}/build/app/smali/okhttp3/"
	cp -r "${BASEDIR}/smali/okhttp-smali/okio/" "${BASEDIR}/build/app/smali/okio/"
	echo "Copying unknown..."
	cp -r "${BASEDIR}/patches/unknown/" "${BASEDIR}/build/app/unknown/"
	cp "${BASEDIR}/patches/strings.xml" "${BASEDIR}/build/app/res/values/strings.xml"

	echo "Building libraries."

	for tarch in ${TARCHS}
	do
		rm -rf "${BASEDIR}/build/${tarch}"
		mkdir -p "${BASEDIR}/build/${tarch}"

		echo "Running cmake ${tarch}..."
		cd "${BASEDIR}/build/${tarch}"
		${CMAKE} -G Ninja \
			-DANDROID_ABI="${tarch}" \
			-DCMAKE_BUILD_TYPE:STRING="Release" \
			-DCMAKE_INSTALL_PREFIX:PATH="${BASEDIR}/build/${tarch}" \
			-DCMAKE_TOOLCHAIN_FILE:FILEPATH="${NDK}/build/cmake/android.toolchain.cmake" \
			-DCMAKE_MAKE_PROGRAM:FILEPATH="${NINJA}" \
			-DANDROID_PLATFORM="21" \
			-DCMAKE_SYSTEM_NAME="Android" \
			-DCMAKE_ANDROID_ARCH_ABI="${tarch}" \
			-DCMAKE_ANDROID_NDK="${NDK}" \
			-DCMAKE_SYSTEM_VERSION="16" \
			-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION="clang" \
			-DDOBBY_DEBUG="OFF" \
			"${BASEDIR}/"
		[ "$?" -ne "0" ] && _errorexit 1 "cmake failed for ${tarch}"
		${NINJA}
		[ "$?" -ne "0" ] && _errorexit 2 "ninja failed for ${tarch}"

		echo "Copying libraries for ${tarch}..."
		cp "${BASEDIR}/build/${tarch}/libuwasa.so" "${BASEDIR}/build/app/lib/${tarch}/libuwasa.so"
	done

	echo "Rebuilding APK..."
	${JAVA} -jar "${BASEDIR}/build/${APKTOOL}" b "${BASEDIR}/build/app/" -o "${RESULT}"

	_signandupload
}

_signandupload() {
	echo "Signing apk..."
	[ -f "${BASEDIR}/sign.sh" ] || _errorexit 8 "Signer is missing! It must be there: ${BASEDIR}/sign.sh"
	${BASH} "${BASEDIR}/sign.sh" "${RESULT}"
	[ "$?" -ne "0" ] && _errorexit 3 || _exit
}

_errorexit() {
	[ ! -z "$2" ] && echo "$2"
	echo "An error has occurred, exiting."
	exit ${1}
}

_exit() {
	echo "Finished!"
	exit 0
}

_pre
