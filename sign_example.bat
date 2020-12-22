@echo off
jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore %~dp0\changeme.keystore %~dp0\build\magia_patched.apk -storepass changeme name