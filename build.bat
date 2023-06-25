@echo off
if "%1" == "Debug" (
    set BUILD_TYPE="Debug"
    set DOBBY_DEBUG="ON"
) else if "%1" == "Release" (
    set BUILD_TYPE="Release"
    set DOBBY_DEBUG="OFF"
) else (
    echo Build type must be either Release or Debug
    goto errorexit
)

for /r "%~dp0\apk" %%a in (*.apk) do set apk=%%~dpnxa
if "%apk%" neq "" (
    echo Found apk %apk%.
    goto :find_armv7_apk
)
echo Did not find any MagiReco APK! Add it to the apk/ directory.
goto errorexit
pause

:find_armv7_apk
for /r "%~dp0\armv7apk" %%a in (*.apk) do set armv7apk=%%~dpnxa
if "%armv7apk%" neq "" (
    echo Found ARMv7 apk %armv7apk%.
    goto :start
)
echo Did not find any ARMv7 MagiReco APK! Add it to the armv7apk directory.
goto errorexit
pause

:start
if "%JAVA_HOME%" == "" (
    echo JAVA_HOME is not set
    goto errorexit
)
set ndk="C:/Android/android-ndk-r21d/"
set /p ndk="Enter ndk Location [%ndk%]: "
set cmake="C:/Android/sdk/cmake/3.22.1/bin/cmake.exe"
set /p cmake="Enter cmake Location [%cmake%]: "
set ninja="C:/Android/sdk/cmake/3.22.1/bin/ninja.exe"
set /p ninja="Enter ninja Location [%ninja%]: "

set zipalign="C:/Android/sdk/build-tools/34.0.0/zipalign.exe"
set /p zipalign="Enter zipalign Location [%zipalign%]: "
set apksigner="C:/Android/sdk/build-tools/34.0.0/apksigner.bat"
set /p apksigner="Enter apksigner Location [%apksigner%]: "

if not exist "%~dp0\build" mkdir "%~dp0\build"

set apktooljar=apktool_2.7.0.jar
set apktoolsha256=c11b5eb518d9ac2ab18e959cbe087499079072b04d567cdcae5ceb447f9a7e7d
if exist "%~dp0\build\%apktooljar%" goto checkapktoolhash
:downloadapktool
echo Downloading apktool...
CALL curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36" -o "%~dp0\build\%apktooljar%" -L "https://bitbucket.org/iBotPeaches/apktool/downloads/%apktooljar%"
:checkapktoolhash
certutil -hashfile "%~dp0\build\%apktooljar%" SHA256 | findstr /i %apktoolsha256% && goto apktoolexists
echo SHA256 mismatch for "%~dp0\build\%apktooljar%"set deleteold=N
set redownloadapktool=N
set /p redownloadapktool="Try delete and redownload apktool (uppercase Y/[N])? "
if %redownloadapktool% NEQ Y goto errorexit
del /f "%~dp0\build\%apktooljar%"
goto downloadapktool
:apktoolexists
if not exist "%~dp0\build\app\" goto create

set deleteold=N
set /p deleteold="Remake existing APK work directory (uppercase Y/[N])? "
if %deleteold% NEQ Y goto build

:create
echo Removing existing build files...
rmdir /S /Q "%~dp0\build\app\"
rmdir /S /Q "%~dp0\build\armv7\app\"
echo Running apktool...
CALL "%JAVA_HOME%\bin\java.exe" -jar "%~dp0\build\%apktooljar%" d "%apk%" -o "%~dp0\build\app"
mkdir "%~dp0\build\app\smali\com\loadLib\"
if not exist "%~dp0\build\app\lib\armeabi-v7a" mkdir "%~dp0\build\app\lib\armeabi-v7a"
if not exist "%~dp0\build\app\lib\arm64-v8a" mkdir "%~dp0\build\app\lib\arm64-v8a"
echo Extracting ARMv7 lib...
CALL "%JAVA_HOME%\bin\java.exe" -jar "%~dp0\build\%apktooljar%" d "%armv7apk%" --no-src --no-res -o "%~dp0\build\armv7\app"
move "%~dp0\build\armv7\app\lib\armeabi-v7a\*.*" "%~dp0\build\app\lib\armeabi-v7a\"
if errorlevel 1 goto errorexit
rmdir /S /Q "%~dp0\build\armv7\app\"

set tried_set_gitattr=N
:apply_patch
echo Applying smali patches...
cd /d "%~dp0"
for %%a in (
    NativeBridge.patch
    Hook.patch
    Backtrace.patch
) do (
    call git apply --stat "%~dp0\patches\%%a"
    call git apply "%~dp0\patches\%%a"
    if errorlevel 1 goto handle_eol
)
goto apply_misc_patch

:handle_eol
echo handle_eol
if "%tried_set_gitattr%" == "Y" goto errorexit
set tried_set_gitattr=Y
echo Convert all smali files from CRLF into LF...
cd /d "%~dp0"
powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass ".\convert_smali_eol.ps1"
goto apply_patch

:apply_misc_patch
echo Applying misc patches...
REM call copy /Y "%~dp0\patches\images\story_ui_sprites00_patch.plist" "%~dp0\build\app\assets\package\story\story_ui_sprites00.plist"
REM call copy /Y "%~dp0\patches\images\story_ui_sprites00_patch.png" "%~dp0\build\app\assets\package\story\story_ui_sprites00.png"

if "%MT_AUDIOFIX_3_0_1%" == "" set MT_AUDIOFIX_3_0_1=Y
if "%MT_AUDIOFIX_3_0_1%" == "y" set MT_AUDIOFIX_3_0_1=Y
if "%MT_AUDIOFIX_3_0_1%" == "Y" (
    REM Fix low-pitched audio bug since magireco 3.0.1
    REM This was once done with MagiaHook.
    REM However, due to unexplained reason,
    REM that hook made the game engine probabilistically fail to create OpenSLES player,
    REM thus the game would get silenced in that way.
    node "%~dp0/patches/audiofix.js" --wdir "%~dp0/build/app" --overwrite
    if errorlevel 1 goto errorexit
)

call copy /Y "%~dp0\patches\koruri-semibold.ttf" "%~dp0\build\app\assets\fonts\koruri-semibold.ttf"

echo Updating sprites and AndroidManifest.xml...
REM handle fake python3 which does nothing but redirects to microsoft store
set python=python
python3 --version && set python=python3
cd /d "%~dp0"
REM %python% -m pip install -r requirements.txt
%python% buildassets.py
if errorlevel 1 goto errorexit

:build
echo Copying new smali files...
call copy /Y "%~dp0\smali\loader\*.smali" "%~dp0\build\app\smali\com\loadLib\"
mkdir "%~dp0\build\app\smali\io\kamihama\magianative\"
echo Copying magianative...
call copy /Y "%~dp0\smali\MagiaNative\app\src\main\java\io\kamihama\magianative\*.smali" "%~dp0\build\app\smali\io\kamihama\magianative\"
echo Copying libraries...
REM robocopy does not eat quoted paths
pushd "%~dp0"
call robocopy /NFL /NDL /NJH /NJS /nc /ns /e smali\okhttp-smali\okhttp3\ build\app\smali\okhttp3\
call robocopy /NFL /NDL /NJH /NJS /nc /ns /e smali\okhttp-smali\okio\ build\app\smali\okio\
echo Copying unknown...
call robocopy /NFL /NDL /NJH /NJS /nc /ns /e patches\unknown\ build\app\unknown\
popd
call copy /Y "%~dp0\patches\strings.xml" "%~dp0\build\app\res\values\strings.xml"

echo Building libraries.

rmdir /S /Q "%~dp0\build\armeabi-v7a\"
rmdir /S /Q "%~dp0\build\arm64-v8a\"
mkdir "%~dp0\build\armeabi-v7a"
mkdir "%~dp0\build\arm64-v8a"

echo Running cmake armeabi-v7a...

cd /d "%~dp0\build\armeabi-v7a"
call "%cmake%" -G Ninja -DANDROID_ABI="armeabi-v7a" -DCMAKE_BUILD_TYPE:STRING="%BUILD_TYPE%" "-DCMAKE_INSTALL_PREFIX:PATH=%~dp0\build\armeabi-v7a" "-DCMAKE_TOOLCHAIN_FILE:FILEPATH=%ndk%/build/cmake/android.toolchain.cmake" "-DCMAKE_MAKE_PROGRAM:FILEPATH=%ninja%" "-DANDROID_PLATFORM=19" "-DCMAKE_SYSTEM_NAME=Android" "-DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a" "-DCMAKE_ANDROID_NDK=%ndk%" "-DCMAKE_SYSTEM_VERSION=16" "-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang" "-DDOBBY_DEBUG=%DOBBY_DEBUG%" "%~dp0"
if errorlevel 1 goto errorexit
call "%ninja%"
if errorlevel 1 goto errorexit

echo Running cmake arm64-v8a...
cd /d "%~dp0\build\arm64-v8a"
call "%cmake%" -G Ninja -DANDROID_ABI="arm64-v8a" -DCMAKE_BUILD_TYPE:STRING="%BUILD_TYPE%" "-DCMAKE_INSTALL_PREFIX:PATH=%~dp0\build\arm64-v8a" "-DCMAKE_TOOLCHAIN_FILE:FILEPATH=%ndk%/build/cmake/android.toolchain.cmake" "-DCMAKE_MAKE_PROGRAM:FILEPATH=%ninja%" "-DANDROID_PLATFORM=21" "-DCMAKE_SYSTEM_NAME=Android" "-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a" "-DCMAKE_ANDROID_NDK=%ndk%" "-DCMAKE_SYSTEM_VERSION=16" "-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang" "-DDOBBY_DEBUG=%DOBBY_DEBUG%" "%~dp0"
if errorlevel 1 goto errorexit
call "%ninja%"
if errorlevel 1 goto errorexit

echo Copying libraries...
call copy /Y "%~dp0\build\armeabi-v7a\libuwasa.so" "%~dp0\build\app\lib\armeabi-v7a\libuwasa.so"
call copy /Y "%~dp0\build\arm64-v8a\libuwasa.so" "%~dp0\build\app\lib\arm64-v8a\libuwasa.so"

echo Rebuilding APK...
CALL "%JAVA_HOME%\bin\java.exe" -jar "%~dp0\build\%apktooljar%" b "%~dp0\build\app" -o "%~dp0\build\magia_patched.apk"

:signandupload
echo Signing apk...
call "%~dp0\sign.bat"
if errorlevel 1 goto errorexit
echo Finished!
goto exit

:errorexit
echo An error has occurred, exiting.
goto exit

:exit
cd /d "%~dp0"
pause