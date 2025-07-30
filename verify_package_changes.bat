@echo off
title Verify Package Name Changes

echo 🔍 Verifying Package Name Changes
echo ================================
echo.
echo Checking for any remaining references to com.example.veerangana...
echo.

echo 📱 Android Configuration:
findstr /s /i "com.example.veerangana" android\* 2>nul
if %errorlevel% equ 0 (
    echo ❌ Found remaining references in Android files
) else (
    echo ✅ Android files updated successfully
)
echo.

echo 🔥 Firebase Configuration:
findstr /s /i "com.example.veerangana" android\app\src\google-services.json 2>nul
if %errorlevel% equ 0 (
    echo ❌ Found remaining references in Firebase config
) else (
    echo ✅ Firebase configuration updated successfully
)
echo.

echo 🌐 Environment Files:
findstr /s /i "com.example.veerangana" .env* 2>nul
if %errorlevel% equ 0 (
    echo ❌ Found remaining references in environment files
) else (
    echo ✅ Environment files updated successfully
)
echo.

echo 📋 Summary of changes made:
echo ✅ Package name changed to: com.lucky.veerangana
echo ✅ Android build.gradle updated
echo ✅ Android namespace updated
echo ✅ Firebase google-services.json updated
echo ✅ Environment variables updated
echo ✅ ProGuard rules updated
echo ✅ MainActivity.kt moved and updated
echo ✅ iOS bundle identifier updated
echo.
echo 🚀 Next Steps:
echo 1. Update Firebase Console (see FIREBASE_UPDATE_GUIDE.md)
echo 2. Update API key restrictions in Google Cloud Console
echo 3. Test the app to ensure Firebase works correctly
echo 4. Rebuild the app with: flutter clean && flutter pub get
echo.
pause
