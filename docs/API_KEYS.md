# API Keys Setup Guide

This guide explains how to properly set up API keys for the Lost & Found NITH application while keeping them secure.

## 🔐 Security Important Notice

**NEVER commit actual API keys to version control systems like GitHub.** This repository is configured to exclude the `api_keys.dart` file from being committed, but you must still be careful.

## 📋 Required API Keys

### 1. Gemini AI API Key
- Used for AI-powered post creation
- Required for core functionality
- Get it from: [Google AI Studio](https://aistudio.google.com/)

### 2. Stability AI API Key (Optional)
- Used for AI image generation
- Not required for basic functionality
- Get it from: [Stability AI Platform](https://platform.stability.ai/)

## 🛠️ Setup Instructions

### Step 1: Create the API Keys File

Copy the template file to create your actual API keys file:

```bash
# On Windows
copy lib\constants\api_keys_template.dart lib\constants\api_keys.dart

# On macOS/Linux
cp lib/constants/api_keys_template.dart lib/constants/api_keys.dart
```

### Step 2: Edit the API Keys File

Open `lib/constants/api_keys.dart` and replace the placeholder values:

```dart
// BEFORE (Template)
const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
const String stabilityApikey = 'YOUR_STABILITY_AI_API_KEY_HERE';

// AFTER (Your actual keys)
const String geminiApiKey = 'AIzaSyB3hs7wXYZabc123def456ghi789jkl'; // Your actual Gemini API key
const String stabilityApikey = 'sk-abc123def456ghi789jkl'; // Your actual Stability AI API key (optional)
```

### Step 3: Verify .gitignore Configuration

Ensure that `lib/constants/api_keys.dart` is listed in your `.gitignore` file:

```gitignore
# API Keys - DO NOT COMMIT TO VERSION CONTROL
/lib/constants/api_keys.dart
```

## 🧪 Testing Your API Keys

After setting up your API keys, you can test them by:

1. Running the application
2. Using the AI-powered post creation feature
3. Verifying that the AI correctly processes your input

## 🔧 Troubleshooting

### API Key Not Working
- Double-check that you've copied the full API key correctly
- Ensure there are no extra spaces or characters
- Verify that the API key is enabled and has the correct permissions

### File Not Found Errors
- Make sure you've created the `api_keys.dart` file
- Verify the file is in the correct location: `lib/constants/api_keys.dart`
- Check that the variable names match exactly

### Security Issues
- If you suspect your API key has been compromised:
  1. Immediately revoke the key in the respective platform
  2. Generate a new API key
  3. Update your `api_keys.dart` file with the new key
  4. Never share or publish your API keys

## 🔄 Best Practices

### Development vs Production
- Use separate API keys for development and production environments
- Monitor API usage quotas for both environments
- Set up billing alerts to avoid unexpected charges

### Key Rotation
- Regularly rotate your API keys (every 3-6 months)
- Keep a backup of working keys before rotating
- Update all environments with new keys simultaneously

### Monitoring
- Enable API usage monitoring and alerts
- Set up notifications for unusual activity
- Regularly review API access logs

## 📞 Support

If you encounter issues with API key setup:
1. Check the [Google AI Documentation](https://ai.google.dev/docs)
2. Review the [Stability AI Documentation](https://platform.stability.ai/docs)
3. Create an issue in the GitHub repository