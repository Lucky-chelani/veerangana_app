# Security Setup Guide for Veerangana App

## 🔐 Environment Variables Setup

This guide explains how to securely configure API keys and credentials for the Veerangana app.

### 1. Environment Files

- `.env` - Contains actual production API keys (NEVER commit to Git)
- `.env.example` - Template with placeholder values (safe to commit)

### 2. Required API Keys

#### Firebase Configuration
- `FIREBASE_WEB_API_KEY`
- `FIREBASE_ANDROID_API_KEY` 
- `FIREBASE_IOS_API_KEY`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`
- And other Firebase config values

#### Google APIs
- `GOOGLE_MAPS_API_KEY` - For Maps functionality
- `GEMINI_API_KEY` - For Sakhi AI chatbot

### 3. Setup Instructions

#### For Development:
1. Copy `.env.example` to `.env`
2. Replace placeholder values with your actual API keys
3. Never commit the `.env` file to version control

#### For Production:
1. Set environment variables in your deployment platform
2. Ensure `.env` file is in `.gitignore`
3. Use the provided environment configuration class

### 4. Security Features Implemented

✅ **API Key Protection**
- All sensitive keys moved to environment variables
- Secure environment configuration class
- Git ignore rules for sensitive files

✅ **Build Security**
- ProGuard configuration for code obfuscation
- Signing configuration for release builds
- Optimized app bundle generation

✅ **Firebase Security**
- Dynamic configuration loading
- Platform-specific API keys
- Secure initialization process

### 5. Play Store Preparation

Run the preparation script before uploading:

**Windows:**
```bash
prepare_for_playstore.bat
```

**Linux/Mac:**
```bash
chmod +x prepare_for_playstore.sh
./prepare_for_playstore.sh
```

### 6. Important Security Notes

⚠️ **Never commit these files:**
- `.env`
- `android/key.properties`
- `android/app/google-services.json` (with real credentials)
- Any keystore files

⚠️ **Always verify before committing:**
- Check that no API keys are hardcoded
- Ensure environment variables are being used
- Review git status before pushing

### 7. Release Signing

1. Generate a release keystore:
```bash
keytool -genkey -v -keystore veerangana-release-key.keystore -alias veerangana -keyalg RSA -keysize 2048 -validity 10000
```

2. Update `android/key.properties` with your keystore details

3. Keep your keystore file secure and backed up

### 8. API Key Restrictions

For production, restrict your API keys:

#### Google Maps API Key:
- Restrict to your app's package name
- Enable only required APIs (Maps SDK for Android)

#### Firebase API Keys:
- Use Firebase App Check for additional security
- Set up security rules for Firestore

#### Gemini API Key:
- Set usage quotas and restrictions
- Monitor API usage regularly

### 9. Troubleshooting

**Build Issues:**
- Ensure `.env` file exists and has all required variables
- Check that flutter_dotenv package is properly installed
- Verify environment configuration is initialized in main.dart

**API Key Issues:**
- Confirm API keys are valid and have proper permissions
- Check API quotas and billing settings
- Verify API restrictions match your app configuration

### 10. Best Practices

1. **Regular Security Audits**: Review and rotate API keys periodically
2. **Monitoring**: Set up alerts for unusual API usage
3. **Backup**: Keep secure backups of keystores and certificates
4. **Documentation**: Maintain updated documentation of all security configurations

## 📞 Support

If you encounter any issues with the security setup, please refer to the Flutter and Firebase documentation or create an issue in the project repository.
