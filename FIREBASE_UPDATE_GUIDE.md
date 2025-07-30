📋 FIREBASE CONFIGURATION UPDATE CHECKLIST
===============================================

🚀 Your app package name has been changed to: com.lucky.veerangana

To update Firebase configuration, follow these steps:

1. 🌐 GO TO FIREBASE CONSOLE:
   - Visit: https://console.firebase.google.com/
   - Select your project: veerangana-a8a70

2. 📱 UPDATE ANDROID APP CONFIGURATION:
   - Go to Project Settings (gear icon)
   - Scroll down to "Your apps" section
   - Find your Android app (currently: com.example.veerangana)
   - Click the settings icon (gear) next to your Android app
   - Select "Project settings"
   - Under "General" tab, find your Android app
   - Update the package name to: com.lucky.veerangana
   
   OR
   
   - Add a new Android app with package name: com.lucky.veerangana
   - Download the new google-services.json file
   - Replace the old one in: android/app/google-services.json

3. 🍎 UPDATE iOS APP CONFIGURATION (if applicable):
   - In the same "Your apps" section
   - Find your iOS app (currently: com.example.veerangana)
   - Update bundle ID to: com.lucky.veerangana
   
   OR
   
   - Add a new iOS app with bundle ID: com.lucky.veerangana
   - Download the new GoogleService-Info.plist file
   - Replace the old one in: ios/Runner/GoogleService-Info.plist

4. 🔑 UPDATE API KEY RESTRICTIONS:
   - Go to Google Cloud Console: https://console.cloud.google.com/
   - Navigate to APIs & Services > Credentials
   - Find your API keys and update package name restrictions:
     * Android API Key: Add com.lucky.veerangana
     * Maps API Key: Add com.lucky.veerangana
     * Gemini API Key: Update if it has package restrictions

5. 📁 FILES TO UPDATE AFTER FIREBASE CHANGES:
   After downloading new config files from Firebase:
   
   For Android:
   - Replace: android/app/google-services.json
   
   For iOS:
   - Replace: ios/Runner/GoogleService-Info.plist

6. 🧪 TEST CONFIGURATION:
   - Clean and rebuild your app
   - Test Firebase authentication
   - Test Firestore database connection
   - Test Firebase Storage
   - Verify all Firebase services work correctly

⚠️  IMPORTANT NOTES:
- Keep backup of your old configuration files
- Test thoroughly before releasing to production
- The Firebase app IDs in your .env file should remain the same
- Only the package name/bundle ID changes

🔄 ALTERNATIVE APPROACH:
If you encounter issues, you can:
1. Create a completely new Firebase project
2. Migrate your data from the old project
3. Update all configuration files with new project details

✅ After completing these steps:
- Your app will work with the new package name
- All Firebase services will continue to function
- Your existing data will remain intact
