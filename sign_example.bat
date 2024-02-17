@echo off

if not exist "%zipalign%" (
    echo zipalign not found
    goto errorexit
)
if not exist "%apksigner%" (
    echo apksigner not found
    goto errorexit
)

echo Doing zipalign...
%zipalign% -f -p 4 "%~dp0\build\magia_patched.apk" "%~dp0\build\magia_patched_aligned.apk"
if errorlevel 1 (
echo Failed to zipalign!
goto errorexit
)
echo Removing tmp file...
del /f /q "%~dp0\build\magia_patched.apk"
rename "%~dp0\build\magia_patched_aligned.apk" magia_patched.apk

echo Doing apksign...
call %apksigner% sign --ks "%~dp0\changeme.keystore" --ks-pass pass:changeme --ks-key-alias name "%~dp0\build\magia_patched.apk"
if errorlevel 1 goto errorexit

exit /b

:errorexit
exit /b 3