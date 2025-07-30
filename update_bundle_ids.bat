@echo off
title Update iOS Bundle Identifiers

echo 🔄 Updating iOS Bundle Identifiers...
echo Changing from com.example.veerangana to com.lucky.veerangana
echo.

echo Note: iOS project files have been identified that need manual updates:
echo.
echo 📁 Files that need manual updates in Xcode:
echo - ios\Runner.xcodeproj\project.pbxproj
echo - macos\Runner.xcodeproj\project.pbxproj
echo.
echo 🛠️  To update these manually:
echo 1. Open ios\Runner.xcodeproj in Xcode
echo 2. Select the Runner project in the navigator
echo 3. In the General tab, change Bundle Identifier to: com.lucky.veerangana
echo 4. Do the same for RunnerTests if present
echo 5. Repeat for macOS project if targeting macOS
echo.
echo ✅ Android and other platform files have been updated automatically.
echo.
pause
