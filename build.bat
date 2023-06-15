@echo off
for /r "%~dp0\apk" %%a in (*.apk) do set apk=%%~dpnxa
if "%apk%" neq "" (
echo Found apk %apk%.
goto :start
)
echo Did not find any MagiReco APK! Add it to the apk/ directory.
goto errorexit
pause

:start
set ndk="C:/Android/android-ndk-r21d/"
set /p ndk="Enter ndk Location [C:/Android/android-ndk-r21d/]: "

if not exist %~dp0\build mkdir %~dp0\build
if exist %~dp0\build\apktool_2.4.1.jar goto apktoolexists
echo Downloading apktool...
CALL curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -o "%~dp0\build\apktool_2.4.1.jar" -L "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar"

:apktoolexists
if not exist %~dp0\build\app\ goto create

set deleteold=N
set /p deleteold="Remake existing APK work directory (Y/[N])? "
if %deleteold% NEQ Y goto build

:create
echo Removing existing build files...
rmdir /S /Q %~dp0\build\app\
echo Running apktool...
CALL java -jar %~dp0\build\apktool_2.4.1.jar d %apk% -o %~dp0\build\app\
mkdir %~dp0\build\app\smali\com\loadLib\
if not exist %~dp0\build\app\lib\armeabi-v7a mkdir %~dp0\build\app\lib\armeabi-v7a
if not exist %~dp0\build\app\lib\arm64-v8a mkdir %~dp0\build\app\lib\arm64-v8a

echo Applying smali patches...
cd %~dp0
call git apply --stat "%~dp0\patches\NativeBridge.patch"
call git apply --stat "%~dp0\patches\Hook.patch"
call git apply --stat "%~dp0\patches\Backtrace.patch"
call git apply "%~dp0\patches\NativeBridge.patch"
call git apply "%~dp0\patches\Hook.patch"
call git apply "%~dp0\patches\Backtrace.patch"
echo Applying misc patches...
REM call copy /Y "%~dp0\patches\images\story_ui_sprites00_patch.plist" "%~dp0\build\app\assets\package\story\story_ui_sprites00.plist"
REM call copy /Y "%~dp0\patches\images\story_ui_sprites00_patch.png" "%~dp0\build\app\assets\package\story\story_ui_sprites00.png"

REM Fix low-pitched audio bug since magireco 3.0.1
REM This was once done with MagiaHook.
REM However, due to unexplained reason,
REM that hook made the game engine probabilistically fail to create OpenSLES player,
REM thus the game would get silenced in that way.
node "%~dp0/patches/audiofix.js" --wdir "%~dp0/build/app" --overwrite
if errorlevel 1 goto errorexit

call copy /Y "%~dp0\patches\koruri-semibold.ttf" "%~dp0\build\app\assets\fonts\koruri-semibold.ttf"

echo Updating sprites and AndroidManifest.xml...
call python3 buildassets.py

:build
echo Copying new smali files...
call copy /Y "%~dp0\smali\loader\*.smali" "%~dp0\build\app\smali\com\loadLib\"
mkdir %~dp0\build\app\smali\io\kamihama\magianative\
echo Copying magianative...
call copy /Y "%~dp0\smali\MagiaNative\app\src\main\java\io\kamihama\magianative\*.smali" "%~dp0\build\app\smali\io\kamihama\magianative\"
echo Copying libraries...
call robocopy /NFL /NDL /NJH /NJS /nc /ns /e %~dp0\smali\okhttp-smali\okhttp3\ %~dp0\build\app\smali\okhttp3\
call robocopy /NFL /NDL /NJH /NJS /nc /ns /e %~dp0\smali\okhttp-smali\okio\ %~dp0\build\app\smali\okio\
echo Copying unknown...
call robocopy /NFL /NDL /NJH /NJS /nc /ns /e %~dp0\patches\unknown\ %~dp0\build\app\unknown\
call copy /Y "%~dp0\patches\strings.xml" "%~dp0\build\app\res\values\strings.xml"

echo Building libraries.

rmdir /S /Q %~dp0\build\armeabi-v7a\
rmdir /S /Q %~dp0\build\arm64-v8a\
mkdir %~dp0\build\armeabi-v7a
mkdir %~dp0\build\arm64-v8a

echo Running cmake armeabi-v7a...

cd %~dp0\build\armeabi-v7a
call "C:\PROGRAM FILES (X86)\MICROSOFT VISUAL STUDIO\2019\ENTERPRISE\COMMON7\IDE\COMMONEXTENSIONS\MICROSOFT\CMAKE\CMake\bin\cmake.exe" -G Ninja -DANDROID_ABI="armeabi-v7a" -DCMAKE_BUILD_TYPE:STRING="Debug" -DCMAKE_INSTALL_PREFIX:PATH="%~dp0\build\armeabi-v7a" -DCMAKE_TOOLCHAIN_FILE:FILEPATH="%ndk%/build/cmake/android.toolchain.cmake" -DCMAKE_MAKE_PROGRAM:FILEPATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" "-DANDROID_PLATFORM=19" "-DCMAKE_SYSTEM_NAME=Android" "-DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a" "-DCMAKE_ANDROID_NDK=%ndk%" "-DCMAKE_SYSTEM_VERSION=16" "-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang" "-DDOBBY_DEBUG=ON" "%~dp0\"
if errorlevel 1 goto errorexit
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
if errorlevel 1 goto errorexit

echo Running cmake arm64-v8a...
cd %~dp0\build\arm64-v8a
call "C:\PROGRAM FILES (X86)\MICROSOFT VISUAL STUDIO\2019\ENTERPRISE\COMMON7\IDE\COMMONEXTENSIONS\MICROSOFT\CMAKE\CMake\bin\cmake.exe" -G Ninja -DANDROID_ABI="arm64-v8a" -DCMAKE_BUILD_TYPE:STRING="Debug" -DCMAKE_INSTALL_PREFIX:PATH="%~dp0\build\arm64-v8a" -DCMAKE_TOOLCHAIN_FILE:FILEPATH="%ndk%/build/cmake/android.toolchain.cmake" -DCMAKE_MAKE_PROGRAM:FILEPATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" "-DANDROID_PLATFORM=21" "-DCMAKE_SYSTEM_NAME=Android" "-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a" "-DCMAKE_ANDROID_NDK=%ndk%" "-DCMAKE_SYSTEM_VERSION=16" "-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang" "-DDOBBY_DEBUG=ON" "%~dp0\"
if errorlevel 1 goto errorexit
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
if errorlevel 1 goto errorexit

echo Copying libraries...
call copy /Y %~dp0\build\armeabi-v7a\libuwasa.so %~dp0\build\app\lib\armeabi-v7a\libuwasa.so
call copy /Y %~dp0\build\arm64-v8a\libuwasa.so %~dp0\build\app\lib\arm64-v8a\libuwasa.so

echo Rebuilding APK...
call java -jar %~dp0\build\apktool_2.4.1.jar b %~dp0\build\app\ -o %~dp0\build\magia_patched.apk

:signandupload
echo Signing apk...
call %~dp0\sign.bat
echo Finished!
goto exit

:errorexit
echo An error has occurred, exiting.
goto exit

:exit
pause