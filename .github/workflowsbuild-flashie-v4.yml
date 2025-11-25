name: Build Flashie APK v4

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      # Checkout repository
      - name: Checkout repository
        uses: actions/checkout@v3

      # Install Flutter
      - name: Install Flutter
        uses: subosito/flutter-action@v3
        with:
          flutter-version: '3.13.0'

      # Install dependencies
      - name: Install dependencies
        working-directory: mobile
        run: flutter pub get

      # Build APK
      - name: Build APK
        working-directory: mobile
        run: flutter build apk --release

      # Upload APK (✅ v4)
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: Flashie-APK
          path: mobile/build/app/outputs/flutter-apk/app-release.apk
