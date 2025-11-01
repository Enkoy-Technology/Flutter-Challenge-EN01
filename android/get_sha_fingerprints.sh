#!/bin/bash
# Script to get SHA-1 and SHA-256 fingerprints from debug keystore
# These fingerprints need to be added to Firebase Console

echo "Getting SHA fingerprints from debug keystore..."
echo ""

# Default debug keystore location
KEYSTORE="$HOME/.android/debug.keystore"
ALIAS="androiddebugkey"
STORE_PASS="android"
KEY_PASS="android"

if [ ! -f "$KEYSTORE" ]; then
    echo "Error: Debug keystore not found at $KEYSTORE"
    echo "This usually means you need to build the app at least once."
    exit 1
fi

echo "SHA-1 Fingerprint:"
keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" -storepass "$STORE_PASS" -keypass "$KEY_PASS" 2>/dev/null | grep -A 1 "SHA1:" | grep -E "(SHA1|Certificate fingerprints)" | head -1 | sed 's/^[[:space:]]*SHA1:[[:space:]]*/    /'

echo ""
echo "SHA-256 Fingerprint:"
keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" -storepass "$STORE_PASS" -keypass "$KEY_PASS" 2>/dev/null | grep -A 1 "SHA256:" | grep -E "(SHA256|Certificate fingerprints)" | head -1 | sed 's/^[[:space:]]*SHA256:[[:space:]]*/    /'

echo ""
echo "To add these fingerprints to Firebase:"
echo "1. Go to https://console.firebase.google.com/"
echo "2. Select your project: chatapp-50cf0"
echo "3. Go to Project Settings (gear icon)"
echo "4. Scroll to 'Your apps' section"
echo "5. Click on your Android app (com.example.chatapp)"
echo "6. Click 'Add fingerprint' and paste the SHA-1 and SHA-256 values above"
echo "7. Save and rebuild your app"

