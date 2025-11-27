# Installation Guide

This guide provides detailed instructions for installing and setting up the Lost & Found NITH application.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software
- **Flutter SDK** (3.0 or higher) - [Download Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Git** - [Download Git](https://git-scm.com/downloads)
- **IDE** (Visual Studio Code, Android Studio, or IntelliJ IDEA)

### Mobile Development (Optional)
- **Android Studio** - For Android development
- **Xcode** - For iOS development (macOS only)

### Backend Services
- **Firebase Account** - [Firebase Console](https://console.firebase.google.com/)
- **Node.js** - For Firebase functions (if needed)

## 🛠️ Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-username/l_f.git
cd l_f
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Set Up Firebase

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name (e.g., "Lost and Found NITH")
4. Accept terms and conditions
5. Select analytics settings (optional)
6. Click "Create project"

#### Configure Firebase for Different Platforms

##### Android Configuration
1. In Firebase Console, click "Add app" and select Android
2. Enter package name (usually `com.example.lost_found_nith`)
3. Register app
4. Download `google-services.json`
5. Place it in `android/app/` directory

##### iOS Configuration
1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID (usually `com.example.lostFoundNith`)
3. Register app
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory

##### Web Configuration
1. In Firebase Console, click "Add app" and select Web
2. Enter app nickname
3. Register app
4. Copy the Firebase configuration object
5. Update `lib/constants/firebase_config.dart` (create if needed)

### Step 4: Set Up API Keys

Follow the [API Keys Setup Guide](API_KEYS.md) to configure your API keys securely.

### Step 5: Configure Deep Linking (Optional)

To enable deep linking:
1. Update your domain in `pubspec.yaml`
2. Configure redirect URLs in Firebase Hosting
3. Test deep links with: `https://nithlostandfoundweb.netlify.app/post/{postId}`

## ▶️ Running the Application

### Development Mode
```bash
# Run on default device/emulator
flutter run

# Run on specific device
flutter run -d <device-name>

# Run on web
flutter run -d chrome
```

### Production Build
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web
```

## 🔧 Configuration Files

### Main Configuration Files
- `pubspec.yaml` - Project dependencies and metadata
- `lib/constants/api_keys.dart` - API keys (excluded from git)
- `lib/constants/firebase_config.dart` - Firebase configuration
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config

### Environment-Specific Configurations
- `lib/constants/config_dev.dart` - Development configuration
- `lib/constants/config_prod.dart` - Production configuration

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Widget Testing
The project includes widget tests to ensure UI components work correctly.

### Integration Testing
Integration tests verify that different parts of the application work together.

## 🚀 Deployment

### Web Deployment (Netlify)
1. Build the web version:
   ```bash
   flutter build web
   ```
2. Deploy to Netlify:
   - Connect your GitHub repository to Netlify
   - Set build command to `flutter build web`
   - Set publish directory to `build/web`

### Mobile Deployment
#### Android
1. Create signed APK/App Bundle
2. Upload to Google Play Store

#### iOS
1. Archive and upload to App Store Connect
2. Requires Apple Developer account

## ⚠️ Common Issues and Solutions

### Flutter Doctor Issues
Run `flutter doctor` to diagnose issues with your Flutter installation.

### Dependency Conflicts
If you encounter dependency conflicts:
```bash
flutter pub upgrade
```

### Firebase Configuration Errors
- Ensure `google-services.json` and `GoogleService-Info.plist` are in the correct locations
- Verify package/bundle IDs match your Firebase app configuration

### API Key Issues
- Check that API keys are correctly set up in `api_keys.dart`
- Ensure API keys have the necessary permissions
- Verify API key quotas haven't been exceeded

## 🆘 Getting Help

If you encounter issues during installation:

1. **Check the FAQ**: Review [FAQ.md](FAQ.md) for common questions
2. **Review Logs**: Check Flutter logs for detailed error messages
3. **Search Issues**: Look for similar issues in the GitHub repository
4. **Create Issue**: If you can't find a solution, create a new issue

## 🔄 Updates and Maintenance

### Keeping Dependencies Updated
Regularly update Flutter dependencies:
```bash
flutter pub outdated
flutter pub upgrade
```

### Flutter SDK Updates
Keep your Flutter SDK up to date:
```bash
flutter upgrade
```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Netlify Documentation](https://docs.netlify.com/)

---

**Need more help?** Check out the [Support](../README.md#support) section in the main README.