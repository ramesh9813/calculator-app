# Calculator

A simple, offline Android calculator app. Single `MainActivity` with a
full-screen `WebView` that loads a self-contained calculator page
(`app/src/main/assets/index.html`).

## Features

- Standard mode: digits, decimal, `+ − × ÷`, `%`, parentheses, backspace, clear
- Scientific mode: `sin`, `cos`, `tan`, `√`, `x²`, `xʸ`, `log`, `ln`, `π`, `e`, `n!`
- Expression display with live result and a collapsible history list
- Dark, touch-friendly UI — works fully offline, no permissions

The expression evaluator is a small tokenizer + shunting-yard parser written in
plain JavaScript — no `eval()` anywhere.

## Build

Requires JDK 17 and the Android SDK with `platforms/android-34` and
`build-tools/34.0.0`.

```bash
export JAVA_HOME=/path/to/jdk-17
export ANDROID_HOME=/path/to/android-sdk
./build.sh
```

This compiles with `javac`, converts with `d8`, links with `aapt2`, aligns with
`zipalign`, and signs with a generated debug key — producing
`calculator.apk`, ready to sideload (enable "Install unknown apps" and open
the file).

On a normal machine with a working Gradle daemon, `./gradlew assembleDebug`
also works.

## Project layout

```
app/src/main/
  AndroidManifest.xml
  java/com/muse/calc/MainActivity.java   # WebView host activity
  assets/index.html                       # the whole calculator UI + logic
```

Package: `com.muse.calc` · minSdk 24 (Android 7.0+) · targetSdk 34
