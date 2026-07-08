# HelloAide — No-root APK build (AIDE / Termux)

## Option A: AIDE
1. Copy this folder to `/sdcard/AIDE/HelloAide/`.
2. Open AIDE → "Open existing project" → select `HelloAide`.
3. AIDE detects `AndroidManifest.xml` and builds an APK automatically
   (uses its bundled aapt2 + d8). No root needed.

## Option B: Termux (recommended, modern SDK)
Install toolchain once:
```
pkg update
pkg install aapt2 d8 ecj apksigner openjdk-17 zip
curl -L -o $PREFIX/share/android.jar \
  https://raw.githubusercontent.com/Sable/android-platforms/master/android-34/android.jar
```
Build:
```
bash scripts/build.sh
```
Output: `app-debug.apk` — install with `pm install app-debug.apk` or tap it.

## Notes on aapt2 / d8 / jar
These are native Android SDK Build-Tools binaries — they cannot be shipped
as source. On Android, use the ARM64 builds from Termux's `pkg` repo
(no root). On desktop, install Android SDK Build-Tools 34.0.0+.

Project layout:
```
HelloAide/
  app/src/main/
    AndroidManifest.xml
    java/com/example/hello/MainActivity.java
    res/layout/activity_main.xml
    res/values/strings.xml
  scripts/build.sh
```
