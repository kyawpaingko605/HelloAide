#!/data/data/com.termux/files/usr/bin/bash
# No-root APK build script for Termux.
# Prereqs (run once):
#   pkg install aapt2 d8 ecj apksigner openjdk-17
#   # Download android.jar (API 34) once:
#   curl -L -o $PREFIX/share/android.jar \
#     https://raw.githubusercontent.com/Sable/android-platforms/master/android-34/android.jar
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/app"
BUILD="$ROOT/build"
ANDROID_JAR="${ANDROID_JAR:-$PREFIX/share/android.jar}"
KEYSTORE="$ROOT/debug.keystore"
KEY_ALIAS="androiddebugkey"
KEY_PASS="android"

rm -rf "$BUILD"
mkdir -p "$BUILD/gen" "$BUILD/obj" "$BUILD/dex" "$BUILD/apk" "$BUILD/res"

echo "[1/6] aapt2 compile resources"
aapt2 compile --dir "$APP/src/main/res" -o "$BUILD/res/res.zip"

echo "[2/6] aapt2 link -> base.apk + R.java"
aapt2 link -o "$BUILD/apk/base.apk" \
  -I "$ANDROID_JAR" \
  --manifest "$APP/src/main/AndroidManifest.xml" \
  --java "$BUILD/gen" \
  "$BUILD/res/res.zip"

echo "[3/6] compile Java (ecj)"
find "$APP/src/main/java" "$BUILD/gen" -name "*.java" > "$BUILD/sources.txt"
ecj -8 -d "$BUILD/obj" -cp "$ANDROID_JAR" @"$BUILD/sources.txt"

echo "[4/6] d8 -> classes.dex"
CLASSES=$(find "$BUILD/obj" -name "*.class")
d8 --lib "$ANDROID_JAR" --output "$BUILD/dex" $CLASSES

echo "[5/6] add classes.dex into apk"
cp "$BUILD/apk/base.apk" "$BUILD/apk/app-unsigned.apk"
(cd "$BUILD/dex" && zip -u "$BUILD/apk/app-unsigned.apk" classes.dex)

echo "[6/6] sign apk"
if [ ! -f "$KEYSTORE" ]; then
  keytool -genkeypair -v -keystore "$KEYSTORE" -alias "$KEY_ALIAS" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass "$KEY_PASS" -keypass "$KEY_PASS" \
    -dname "CN=Debug,O=Android,C=US"
fi
apksigner sign --ks "$KEYSTORE" --ks-pass pass:"$KEY_PASS" \
  --key-pass pass:"$KEY_PASS" \
  --out "$ROOT/app-debug.apk" "$BUILD/apk/app-unsigned.apk"

echo "Done -> $ROOT/app-debug.apk"
