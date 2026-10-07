#!/bin/bash
# Manual APK build (no Gradle daemon): javac -> d8 -> aapt2 link -> zipalign -> apksigner
# Requires: JAVA_HOME pointing at JDK 17, ANDROID_HOME pointing at an SDK with
#           platforms/android-34 and build-tools/34.0.0 installed.
set -e
cd "$(dirname "$0")"

: "${JAVA_HOME:=$HOME/jdk-17}"
: "${ANDROID_HOME:=$HOME/android-sdk}"
export PATH="$JAVA_HOME/bin:$PATH"
BT="$ANDROID_HOME/build-tools/34.0.0"
PLATFORM="$ANDROID_HOME/platforms/android-34/android.jar"

mkdir -p build/classes build/dex

echo "== javac =="
javac -source 17 -target 17 -cp "$PLATFORM" -d build/classes \
    app/src/main/java/com/muse/calc/MainActivity.java

echo "== d8 =="
"$BT/d8" --min-api 24 --output build/dex \
    build/classes/com/muse/calc/MainActivity.class

echo "== aapt2 link =="
"$BT/aapt2" link -o build/unsigned.apk \
    -I "$PLATFORM" \
    --manifest app/src/main/AndroidManifest.xml \
    -A app/src/main/assets \
    --min-sdk-version 24 --target-sdk-version 34
(cd build/dex && zip -X -q ../unsigned.apk classes.dex)

echo "== zipalign =="
"$BT/zipalign" -f -p 4 build/unsigned.apk build/aligned.apk

if [ ! -f build/debug.keystore ]; then
    echo "== generating debug key =="
    keytool -genkeypair -keystore build/debug.keystore \
        -storepass android -keypass android \
        -keyalg RSA -keysize 2048 -validity 10950 \
        -alias androiddebugkey -dname "CN=Android Debug,O=Android,C=US"
fi

echo "== apksigner =="
"$BT/apksigner" sign \
    --ks build/debug.keystore --ks-pass pass:android --key-pass pass:android \
    --out build/calculator.apk build/aligned.apk
"$BT/apksigner" verify build/calculator.apk

cp -f build/calculator.apk calculator.apk
echo "== done: $(pwd)/calculator.apk =="
ls -la calculator.apk
