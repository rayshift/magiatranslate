#!/bin/bash
BASEDIR="$(realpath "$(dirname "${0}")")"

# env-based
CMAKE="${MT_CMAKE:-cmake}" # /usr/bin/cmake
NINJA="${MT_NINJA:-ninja}" # /usr/bin/ninja

# arg-based
NDK="${1:-${BASEDIR}/../ndk/android-ndk-r16b}"

_start() {
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

	mkdir -p "${BASEDIR}/build"
	_build
}

_build() {
	echo "Building libraries."

	rm -rf "${BASEDIR}/build/arm64-v8a"
	mkdir -p "${BASEDIR}/build/arm64-v8a"

	echo "Running cmake arm64-v8a..."
	cd "${BASEDIR}"
	${CMAKE} -G Ninja \
		-DANDROID_ABI="arm64-v8a" \
		-DCMAKE_BUILD_TYPE:STRING="Release" \
		-DCMAKE_INSTALL_PREFIX:PATH="${BASEDIR}/build/arm64-v8a" \
		-DCMAKE_TOOLCHAIN_FILE:FILEPATH="${NDK}/build/cmake/android.toolchain.cmake" \
		-DCMAKE_MAKE_PROGRAM:FILEPATH="${NINJA}" \
		-DANDROID_PLATFORM="android-19" \
		-DCMAKE_SYSTEM_NAME="Android" \
		-DCMAKE_ANDROID_ARCH_ABI="arm64-v8a" \
		-DCMAKE_ANDROID_NDK="${NDK}" \
		-DCMAKE_SYSTEM_VERSION="16" \
		-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION="clang" \
		-DCMAKE_ANDROID_STL_TYPE="gnustl_static" \
		"${BASEDIR}/"
	[ "$?" -ne "0" ] && _errorexit 1
	${NINJA}
	[ "$?" -ne "0" ] && _errorexit 2

	if [ ! -f "${BASEDIR}/libabiproxy.so" ]
	then
		echo "libabiproxy was not cmade!"
		_errorexit 3
	fi
	mv "${BASEDIR}/libabiproxy.so" "${BASEDIR}/build/arm64-v8a/libabiproxy.so"

	_exit
}

_errorexit() {
	echo "An error has occurred, exiting."
	exit ${1}
}

_exit() {
	echo "Successful."
	exit 0
}

_start
