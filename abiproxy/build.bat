@echo off

:start
set ndk="C:/Android/android-ndk-r21d/"
set /p ndk="Enter ndk Location [C:/Android/android-ndk-r21d/]: "

if not exist %~dp0\build mkdir %~dp0\build

:build
echo Building libraries.

rmdir /S /Q %~dp0\build\armeabi-v7a\
rmdir /S /Q %~dp0\build\arm64-v8a\
mkdir %~dp0\build\armeabi-v7a
mkdir %~dp0\build\arm64-v8a

echo Running cmake armeabi-v7a...

cd %~dp0\build\armeabi-v7a
call "C:\PROGRAM FILES (X86)\MICROSOFT VISUAL STUDIO\2019\ENTERPRISE\COMMON7\IDE\COMMONEXTENSIONS\MICROSOFT\CMAKE\CMake\bin\cmake.exe" -G Ninja -DANDROID_ABI="armeabi-v7a" -DCMAKE_BUILD_TYPE:STRING="Debug" -DCMAKE_INSTALL_PREFIX:PATH="%~dp0\build\armeabi-v7a" -DCMAKE_TOOLCHAIN_FILE:FILEPATH="%ndk%/build/cmake/android.toolchain.cmake" -DCMAKE_MAKE_PROGRAM:FILEPATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" "-DANDROID_PLATFORM=21" "-DCMAKE_SYSTEM_NAME=Android" "-DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a" "-DCMAKE_ANDROID_NDK=%ndk%" "-DCMAKE_SYSTEM_VERSION=16" "-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang" "%~dp0\"
if errorlevel 1 goto errorexit
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
if errorlevel 1 goto errorexit

echo Running cmake arm64-v8a...
cd %~dp0\build\arm64-v8a
call "C:\PROGRAM FILES (X86)\MICROSOFT VISUAL STUDIO\2019\ENTERPRISE\COMMON7\IDE\COMMONEXTENSIONS\MICROSOFT\CMAKE\CMake\bin\cmake.exe" -G Ninja -DANDROID_ABI="arm64-v8a" -DCMAKE_BUILD_TYPE:STRING="Debug" -DCMAKE_INSTALL_PREFIX:PATH="%~dp0\build\arm64-v8a" -DCMAKE_TOOLCHAIN_FILE:FILEPATH="%ndk%/build/cmake/android.toolchain.cmake" -DCMAKE_MAKE_PROGRAM:FILEPATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" "-DANDROID_PLATFORM=21" "-DCMAKE_SYSTEM_NAME=Android" "-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a" "-DCMAKE_ANDROID_NDK=%ndk%" "-DCMAKE_SYSTEM_VERSION=16" "-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang" "%~dp0\"
if errorlevel 1 goto errorexit
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
if errorlevel 1 goto errorexit

echo Successful.
goto :exit

:errorexit
echo An error has occurred, exiting.
goto exit

:exit
pause