# Magia Translate
[![Discord Chat](https://img.shields.io/discord/665980614998097941.svg)](https://discord.gg/6vncnjj)  
This is the client source code for Magia Translate, an English translation modification for Magia Record JP. It is licenced under the GNU General Public License v3.0.

## How to build
- Clone the repository including all submodules `git clone --recurse-submodules https://github.com/rayshift/magiatranslate`
- Download `android-ndk-r21d` from https://developer.android.com/ndk/downloads and place it somewhere.
- Install Visual Studio along with ninja and cmake plugins for C++. Edit the paths to these executables in the `.bat` files if you are not using VS 2019 Enterprise.
- Install the python requirements in requirements.txt.
- Move `sign_example.bat` to `sign.bat` and add your jarsigner keystore, alias and password.
- Build abiproxy by running `abiproxy/build_release.bat`.
- Place your magia record APK in the `apk` directory.
- Run `build_release.bat`.

Notes:
- Use `build.bat` if you want a debug build with debug symbols.
- If your apk has split ABIs (armeabi-v7a/arm64), you will need to move the other `libmadomagi_native.so` into `build/app/lib/{ARCH}`. For example, if the arm7 version of the game is placed in `apk/`, you need to move the `arm8` .so manually, and vice versa.

## Contributing
Create a pull request with your contributions. Please do not submit any copyrighted content (images) to this repository. 

Ensure you test your changes on both armeabi-v7a and arm64-v8a. Also test an emulator such as Nox. To force install a specific ABI, use something like:
`adb.exe -s device install --abi arm64-v8a -r -d .\MagiaTranslate_v2.2.6_v110.apk`

## Further reading
- The server source code is now public at https://github.com/rayshift/kamihama-server - in order to change the server URL, edit the URLs in the smali file `smali/MagiaNative/app/src/main/java/io/kamihama/magianative/RestClient.smali`. You can also recompile the smali file by loading the MagiaNative project in Android Studio, editing `RestClient.java`, and compiling with this plugin: https://github.com/ollide/intellij-java2smali
- The hooking library used is https://github.com/jmpews/Dobby. 
