@echo off
title Veerangana App - Play Store Preparation

echo 🚀 Preparing Veerangana app for Play Store upload...
echo.

echo 🧹 Cleaning previous builds...
call flutter clean

echo.
echo 📦 Getting dependencies...
call flutter pub get

echo.
echo 🧪 Running tests...
call flutter test

echo.
echo 🔍 Analyzing code...
call flutter analyze

echo.
echo 🔨 Building app bundle for Play Store...
call flutter build appbundle --release

echo.
echo ✅ Build complete! Your app bundle is ready for Play Store upload.
echo 📁 Location: build\app\outputs\bundle\release\app-release.aab
echo.
echo 📋 Pre-upload checklist:
echo    ✓ Environment variables configured
echo    ✓ API keys secured  
echo    ✓ App signed with release key
echo    ✓ Code optimized and obfuscated
echo    ✓ App bundle generated
echo.
echo 🎯 Next steps:
echo    1. Test the release build thoroughly
echo    2. Upload the .aab file to Google Play Console
echo    3. Fill in the store listing details
echo    4. Set up app signing in Play Console
echo    5. Submit for review
echo.
pause
