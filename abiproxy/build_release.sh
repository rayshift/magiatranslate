#!/bin/bash
BASEDIR="$(realpath "$(dirname "${0}")")"

# env-based
CMAKE="${MT_CMAKE:-cmake}" # /usr/bin/cmake
NINJA="${MT_NINJA:-ninja}" # /usr/bin/ninja

# arg-based
NDK="${1:-${BASEDIR}/../ndk/android-ndk-r16b}"
TARCHS="${2:-"armeabi-v7a arm64-v8a"}"

_start() {
	[ -d "${NDK}" ] || _errorexit 6 "NDK directory does not exist! Tried path: ${NDK}"
	NDK=$(realpath "${NDK}")
	echo "Found ndk directory ${NDK}"

	[ -f "${NDK}/build/cmake/android.toolchain.cmake" ] || _errorexit 7 "NDK is missing! Unpack it into ${NDK}"

	mkdir -p "${BASEDIR}/build"
	_build
}

_build() {
	echo "Building libraries."

	for tarch in ${TARCHS}
	do
		rm -rf "${BASEDIR}/build/${tarch}"
		mkdir -p "${BASEDIR}/build/${tarch}"

		echo "Running cmake ${tarch}..."
		cd "${BASEDIR}"
		${CMAKE} -G Ninja \
			-DANDROID_ABI="${tarch}" \
			-DCMAKE_BUILD_TYPE:STRING="Release" \
			-DCMAKE_INSTALL_PREFIX:PATH="${BASEDIR}/build/${tarch}" \
			-DCMAKE_TOOLCHAIN_FILE:FILEPATH="${NDK}/build/cmake/android.toolchain.cmake" \
			-DCMAKE_MAKE_PROGRAM:FILEPATH="${NINJA}" \
			-DANDROID_PLATFORM="android-19" \
			-DCMAKE_SYSTEM_NAME="Android" \
			-DCMAKE_ANDROID_ARCH_ABI="${tarch}" \
			-DCMAKE_ANDROID_NDK="${NDK}" \
			-DCMAKE_SYSTEM_VERSION="16" \
			-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION="clang" \
			-DCMAKE_ANDROID_STL_TYPE="gnustl_static" \
			"${BASEDIR}/"
		[ "$?" -ne "0" ] && _errorexit 1 "cmake failed for ${tarch}"
		${NINJA}
		[ "$?" -ne "0" ] && _errorexit 2 "ninja failed for ${tarch}"

		[ -f "${BASEDIR}/libabiproxy.so" ] || _errorexit 3 "libabiproxy was not cmade for ${tarch}!"
		mv "${BASEDIR}/libabiproxy.so" "${BASEDIR}/build/${tarch}/libabiproxy.so"
	done

	_exit
}

_errorexit() {
	[ ! -z "$2" ] && echo "$2"
	echo "An error has occurred, exiting."
	exit ${1}
}

_exit() {
	echo "Successful."
	exit 0
}

_start
