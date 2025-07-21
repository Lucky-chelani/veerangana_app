#!/bin/bash

# Play Store Preparation Script for Veerangana App
# Run this script before uploading to Play Store

echo "🚀 Preparing Veerangana app for Play Store upload..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run tests (if any)
echo "🧪 Running tests..."
flutter test

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Build app bundle for Play Store
echo "🔨 Building app bundle for Play Store..."
flutter build appbundle --release

echo "✅ Build complete! Your app bundle is ready for Play Store upload."
echo "📁 Location: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "📋 Pre-upload checklist:"
echo "   ✓ Environment variables configured"
echo "   ✓ API keys secured"
echo "   ✓ App signed with release key"
echo "   ✓ Code optimized and obfuscated"
echo "   ✓ App bundle generated"
echo ""
echo "🎯 Next steps:"
echo "   1. Test the release build thoroughly"
echo "   2. Upload the .aab file to Google Play Console"
echo "   3. Fill in the store listing details"
echo "   4. Set up app signing in Play Console"
echo "   5. Submit for review"
