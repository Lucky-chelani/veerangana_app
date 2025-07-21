@echo off
title Generate Release Keystore for Veerangana App

echo 🔐 Generating Release Keystore for Veerangana App
echo.
echo This script will create a release keystore for signing your app.
echo Please provide the following information when prompted:
echo.

set /p KEY_ALIAS="Enter key alias (e.g., veerangana): "
set /p VALIDITY="Enter validity in days (default 10000): "
if "%VALIDITY%"=="" set VALIDITY=10000

echo.
echo Generating keystore with the following settings:
echo Key Alias: %KEY_ALIAS%
echo Validity: %VALIDITY% days
echo.

keytool -genkey -v -keystore veerangana-release-key.keystore -alias %KEY_ALIAS% -keyalg RSA -keysize 2048 -validity %VALIDITY%

echo.
echo ✅ Keystore generated successfully!
echo.
echo 📋 Next Steps:
echo 1. Update android/key.properties with your keystore information:
echo    storePassword=your_store_password
echo    keyPassword=your_key_password
echo    keyAlias=%KEY_ALIAS%
echo    storeFile=../veerangana-release-key.keystore
echo.
echo 2. Keep your keystore file secure and backed up!
echo 3. NEVER commit your keystore or key.properties to version control
echo.
echo ⚠️  IMPORTANT: Store your keystore and passwords securely!
echo    If you lose them, you won't be able to update your app on Play Store.
echo.
pause
