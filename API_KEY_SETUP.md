# API Key Setup Guide

This document explains how to securely configure API keys for the Netru application.

## Required API Keys

### Groq API Key
The application uses Groq API for chatbot functionality. You need to obtain an API key from [Groq Console](https://console.groq.com/keys).

## Setup Methods

### Method 1: Environment Variables (Recommended)

#### Windows (PowerShell)
```powershell
$env:GROQ_API_KEY="your_groq_api_key_here"
flutter run
```

#### Windows (Command Prompt)
```cmd
set GROQ_API_KEY=your_groq_api_key_here
flutter run
```

#### macOS/Linux
```bash
export GROQ_API_KEY="your_groq_api_key_here"
flutter run
```

### Method 2: Dart Define (Recommended for CI/CD)
```bash
flutter run --dart-define GROQ_API_KEY=your_groq_api_key_here
```

For building:
```bash
flutter build apk --dart-define GROQ_API_KEY=your_groq_api_key_here
```

### Method 3: VS Code Launch Configuration
Create or update `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "netru_app",
            "request": "launch",
            "type": "dart",
            "args": [
                "--dart-define",
                "GROQ_API_KEY=your_groq_api_key_here"
            ]
        }
    ]
}
```

## Security Features

### Secure Storage
- API keys are stored using `flutter_secure_storage`
- Keys are encrypted using platform-specific secure storage (Keychain on iOS, EncryptedSharedPreferences on Android)
- Keys are never stored in plain text

### Environment Isolation
- Different API keys can be used for development, staging, and production
- Environment-specific configuration prevents accidental key exposure

### Key Rotation
To rotate API keys:
1. Generate a new API key from your provider
2. Update your environment variable or dart-define
3. Restart the application
4. The new key will be securely stored and the old one removed

## Troubleshooting

### "GROQ_API_KEY not found" Error
This error occurs when the API key is not properly configured. Verify:
1. Environment variable is set correctly
2. No typos in the variable name
3. Key is not empty or contains only whitespace
4. For dart-define, ensure proper syntax: `--dart-define GROQ_API_KEY=value`

### Key Not Working
1. Verify the API key is valid in your provider's dashboard
2. Check if the key has proper permissions
3. Ensure you're not exceeding rate limits
4. Verify the key hasn't expired

### Android Build Issues
If you encounter build issues related to secure storage:
1. Ensure `minSdkVersion` is at least 21 in `android/app/build.gradle`
2. Add ProGuard rules if using code obfuscation

## Best Practices

1. **Never commit API keys** to version control
2. **Use different keys** for different environments
3. **Monitor key usage** in your provider's dashboard
4. **Rotate keys regularly** (every 90 days recommended)
5. **Use CI/CD secrets** for automated deployments
6. **Implement key validation** in your application

## Development Workflow

1. Copy `.env.example` to create your environment template
2. Set up your API keys using one of the methods above
3. Run the application
4. The ApiKeyService will automatically handle secure storage

The application will automatically:
- Validate API keys on startup
- Store keys securely for future use
- Handle key rotation without data loss
- Provide clear error messages for configuration issues