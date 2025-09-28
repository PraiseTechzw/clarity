# 🔐 Google & GitHub Authentication Setup Guide

## 📋 **Complete Setup Steps**

### **Step 1: Install Dependencies**
```bash
flutter pub get
```

### **Step 2: Environment Variables Setup**

#### **2.1 Create .env File**
Create a `.env` file in your project root with the following content:

```env
# Google OAuth Configuration
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here

# GitHub OAuth Configuration
GITHUB_CLIENT_ID=your_github_client_id_here
GITHUB_CLIENT_SECRET=your_github_client_secret_here

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_API_KEY=your_firebase_api_key
```

#### **2.2 Add .env to .gitignore**
Make sure `.env` is in your `.gitignore` file:

```gitignore
# Environment variables
.env
.env.local
.env.production
```

### **Step 3: Google Sign-In Setup**

#### **3.1 Google Cloud Console Setup** ✅ **COMPLETED**
- **Client ID**: `YOUR_GOOGLE_CLIENT_ID_HERE`
- **Client Secret**: `YOUR_GOOGLE_CLIENT_SECRET_HERE`
- **Creation Date**: September 27, 2025

**Note**: Add these values to your `.env` file for local development.

#### **3.2 Android Configuration** ✅ **COMPLETED**
1. **Google Services JSON**: Added to `android/app/google-services.json`
2. **Build Configuration**: Updated `android/app/build.gradle.kts` with Google Services plugin
3. **Project Configuration**: Updated `android/build.gradle.kts` with Google Services classpath

#### **3.3 Get SHA-1 Fingerprint (Required)**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Important**: You need to add this SHA-1 fingerprint to your Google Cloud Console OAuth client configuration.

#### **3.4 iOS Configuration**
1. **Add to `ios/Runner/Info.plist`:**
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>REVERSED_CLIENT_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

### **Step 4: GitHub OAuth Setup**

#### **4.1 GitHub OAuth App Creation**
1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in:
   - **Application name**: Clarity
   - **Homepage URL**: `https://your-domain.com`
   - **Authorization callback URL**: `https://your-domain.com/auth/github/callback`

#### **4.2 Update Configuration**
Update `lib/services/auth_service.dart`:
```dart
static const String _githubClientId = 'YOUR_GITHUB_CLIENT_ID';
static const String _githubClientSecret = 'YOUR_GITHUB_CLIENT_SECRET';
static const String _githubRedirectUri = 'YOUR_GITHUB_REDIRECT_URI';
```

### **Step 5: Update Google Configuration**
Update `lib/services/auth_service.dart`:
```dart
static const String _googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
static const String _googleClientIdIOS = 'YOUR_GOOGLE_CLIENT_ID_IOS';
```

### **Step 6: Platform-Specific Setup**

#### **6.1 Android Setup**
1. **Add to `android/app/build.gradle`:**
   ```gradle
   dependencies {
       implementation 'com.google.android.gms:play-services-auth:20.7.0'
   }
   ```

2. **Update `android/app/src/main/AndroidManifest.xml`:**
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

#### **6.2 iOS Setup**
1. **Add to `ios/Podfile`:**
   ```ruby
   pod 'GoogleSignIn'
   ```

2. **Run:**
   ```bash
   cd ios && pod install
   ```

### **Step 7: Testing**

#### **7.1 Test Google Sign-In**
```dart
// Test in your app
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.signInWithGoogle();
```

#### **7.2 Test GitHub Sign-In**
```dart
// Test in your app
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.signInWithGitHub();
```

### **Step 8: Production Considerations**

#### **8.1 Security**
- Store client secrets securely in environment variables
- Use different .env files for different environments
- Implement proper token validation
- Add rate limiting

#### **8.2 Backend Integration**
- Create API endpoints for token validation
- Implement user data synchronization
- Add session management
- Handle token refresh

## 🚀 **Quick Start Commands**

```bash
# Install dependencies
flutter pub get

# Clean and rebuild
flutter clean
flutter pub get

# Run on Android
flutter run

# Run on iOS
flutter run -d ios
```

## 🔧 **Troubleshooting**

### **Common Issues:**

1. **Google Sign-In not working:**
   - Check SHA-1 fingerprint
   - Verify OAuth client configuration
   - Ensure Google Play Services is installed

2. **GitHub OAuth issues:**
   - Verify redirect URI
   - Check client ID and secret
   - Ensure proper scopes

3. **Build errors:**
   - Clean and rebuild
   - Check platform-specific configurations
   - Verify all dependencies are installed

## 📱 **Platform Support**

- ✅ Android
- ✅ iOS
- ✅ Web (with additional setup)
- ✅ Desktop (with additional setup)

## 🔐 **Security Best Practices**

1. **Never commit secrets to version control**
2. **Use environment variables for production**
3. **Implement proper token validation**
4. **Add rate limiting and abuse prevention**
5. **Use HTTPS for all OAuth redirects**
6. **Implement proper session management**

## 📞 **Support**

For issues with this implementation:
1. Check the troubleshooting section
2. Verify all configuration steps
3. Test with minimal implementation first
4. Check platform-specific documentation

---

**Note**: This is a comprehensive setup guide. Follow each step carefully for successful implementation.