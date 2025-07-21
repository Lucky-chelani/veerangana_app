@echo off
title Veerangana App - Play Store Readiness Check

echo 🔍 Veerangana App - Play Store Readiness Check
echo ================================================
echo.

set ERRORS=0

echo Checking environment setup...
if exist .env (
    echo ✅ .env file exists
) else (
    echo ❌ .env file missing - copy from .env.example and configure
    set /a ERRORS+=1
)

if exist .env.example (
    echo ✅ .env.example template exists
) else (
    echo ❌ .env.example template missing
    set /a ERRORS+=1
)

echo.
echo Checking security files...
if exist android\key.properties (
    echo ✅ Key properties file exists
) else (
    echo ❌ android\key.properties missing - run generate_keystore.bat first
    set /a ERRORS+=1
)

if exist android\app\proguard-rules.pro (
    echo ✅ ProGuard rules configured
) else (
    echo ❌ ProGuard rules missing
    set /a ERRORS+=1
)

echo.
echo Checking gitignore...
findstr /c:".env" .gitignore >nul
if %errorlevel%==0 (
    echo ✅ Environment files in .gitignore
) else (
    echo ❌ .gitignore not properly configured
    set /a ERRORS+=1
)

echo.
echo Checking documentation...
if exist SECURITY_SETUP.md (
    echo ✅ Security setup guide exists
) else (
    echo ❌ Security setup guide missing
    set /a ERRORS+=1
)

if exist PLAY_STORE_GUIDE.md (
    echo ✅ Play Store guide exists
) else (
    echo ❌ Play Store guide missing
    set /a ERRORS+=1
)

echo.
echo Checking Flutter configuration...
call flutter doctor --version >nul 2>&1
if %errorlevel%==0 (
    echo ✅ Flutter is properly installed
) else (
    echo ❌ Flutter not found or not properly configured
    set /a ERRORS+=1
)

echo.
echo ================================================
if %ERRORS%==0 (
    echo 🎉 ALL CHECKS PASSED! Your app is ready for Play Store preparation.
    echo.
    echo Next steps:
    echo 1. Run prepare_for_playstore.bat to build release version
    echo 2. Test the release build thoroughly
    echo 3. Follow the Play Store guide for upload
) else (
    echo ⚠️  %ERRORS% issue(s) found. Please fix them before proceeding.
    echo Review the checklist above and fix any ❌ items.
)
echo.
pause
