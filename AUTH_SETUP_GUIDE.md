# Netru App - Authentication System Setup Guide

## 🔧 Setup Instructions

### 1. **Supabase Database Setup**

1. **Create Supabase Project:**
   - Go to [Supabase](https://supabase.com/)
   - Create a new project
   - Use the provided Project URL and API Key in `main.dart`

2. **Run Database Schema:**
   - Copy the SQL from `database/supabase_schema.sql`
   - Go to Supabase Dashboard → SQL Editor
   - Paste and run the SQL commands
   - This will create all necessary tables and security policies

3. **Configure Authentication:**
   - Go to Authentication → Settings
   - Enable Email provider
   - Configure Google OAuth (optional)

### 2. **Google Sign-In Setup (Optional)**

1. **Firebase Console:**
   - Create a Firebase project
   - Enable Google Sign-In
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

2. **Android Configuration:**
   ```bash
   # Place google-services.json in:
   android/app/google-services.json
   ```

3. **iOS Configuration:**
   ```bash
   # Place GoogleService-Info.plist in:
   ios/Runner/GoogleService-Info.plist
   ```

### 3. **Install Dependencies**

```bash
flutter pub get
```

### 4. **Required Dependencies**

The following dependencies are already added to `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.8.1
  google_sign_in: ^6.2.1
  flutter_bloc: ^8.1.4
  dartz: ^0.10.1
  equatable: ^2.0.7
  get_it: ^8.2.0
  # ... other dependencies
```

## 🏗️ Architecture Overview

### **Clean Architecture Structure**

```
features/auth/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login_with_email.dart
│       ├── signup_with_email.dart
│       ├── signin_with_google.dart
│       ├── register_citizen.dart
│       ├── register_foreigner.dart
│       └── auth_usecases.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   ├── datasources/
│   │   └── auth_remote_data_source.dart
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart
    │   └── auth_state.dart
    ├── pages/
    │   ├── login_page.dart
    │   └── signup_page.dart
    └── widgets/
        └── auth_widgets.dart
```

## 🚀 Features Implemented

### ✅ **Core Authentication**
- [x] Email & Password Login
- [x] Email & Password Sign Up
- [x] Google Sign-In Integration
- [x] Session Management
- [x] Auto-login Check
- [x] Logout Functionality

### ✅ **Egyptian Citizen Registration**
- [x] National ID Validation (14 digits)
- [x] Egyptian Phone Number Validation
- [x] Address Storage (Optional)
- [x] Separate Citizens Table in Supabase

### ✅ **Foreign User Registration**
- [x] Passport Number Storage
- [x] Nationality Selection
- [x] Separate Foreigners Table in Supabase

### ✅ **UI/UX Features**
- [x] Beautiful Arabic UI Design
- [x] Form Validation with Arabic Messages
- [x] Loading States
- [x] Error Handling
- [x] Government Ministry Branding
- [x] Security-focused Design

### ✅ **State Management**
- [x] BLoC/Cubit Pattern
- [x] Clean Architecture
- [x] Dependency Injection with GetIt
- [x] Proper Error Handling

## 📱 Usage Examples

### **Check Authentication Status**
```dart
// In any widget with AuthCubit access
context.read<AuthCubit>().checkAuthStatus();
```

### **Login with Email**
```dart
context.read<AuthCubit>().loginWithEmail(
  email: 'user@example.com',
  password: 'password123',
);
```

### **Register Egyptian Citizen**
```dart
context.read<AuthCubit>().registerCitizen(
  email: 'citizen@example.com',
  password: 'password123',
  fullName: 'أحمد محمد علي',
  nationalId: '29912121234567',
  phone: '01012345678',
  address: 'القاهرة، مصر',
);
```

### **Register Foreigner**
```dart
context.read<AuthCubit>().registerForeigner(
  email: 'foreigner@example.com',
  password: 'password123',
  fullName: 'John Smith',
  passportNumber: 'A1234567',
  nationality: 'American',
  phone: '01012345678',
);
```

## 🔒 Security Features

### **Database Security**
- Row Level Security (RLS) enabled
- Users can only access their own data
- Proper foreign key constraints
- Data validation at database level

### **Authentication Security**
- Strong password requirements
- Email verification (configurable)
- Session management
- Secure token storage

### **Validation**
- Egyptian National ID format validation
- Egyptian phone number validation
- Email format validation
- Password strength validation

## 🌐 Supabase Tables

### **users** (General user information)
```sql
id (UUID, PK) - Links to auth.users
email (VARCHAR, UNIQUE)
full_name (VARCHAR)
phone (VARCHAR)
profile_image (TEXT)
user_type (egyptian/foreigner)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### **citizens** (Egyptian citizens)
```sql
id (UUID, PK) - Links to auth.users
email (VARCHAR, UNIQUE)
full_name (VARCHAR)
phone (VARCHAR)
profile_image (TEXT)
national_id (VARCHAR, UNIQUE) - 14 digits
address (TEXT, OPTIONAL)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### **foreigners** (Foreign residents)
```sql
id (UUID, PK) - Links to auth.users
email (VARCHAR, UNIQUE)
full_name (VARCHAR)
phone (VARCHAR)
profile_image (TEXT)
passport_number (VARCHAR)
nationality (VARCHAR)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

## 🎨 UI Components

### **Custom Widgets**
- `AuthButton` - Gradient buttons with loading states
- `AuthTextField` - Custom form fields with validation
- `AuthHeader` - Government-branded headers
- `SocialButton` - Social login buttons

### **Pages**
- `LoginPage` - Email/Password and Google login
- `SignUpPage` - Registration with user type selection

## 🔧 Configuration

### **Supabase Configuration**
```dart
// In main.dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### **Dependency Injection**
```dart
// Auth dependencies are auto-configured
await initAuthDependencies();
```

## 🚨 Important Notes

1. **Google Sign-In**: Requires Firebase project setup
2. **Supabase**: Make sure to run the SQL schema
3. **Permissions**: Location permission is checked after auth
4. **Navigation**: Auth status determines app flow
5. **Arabic Support**: All UI text is in Arabic
6. **Validation**: Strong validation for Egyptian-specific data

## 🐛 Troubleshooting

### **Common Issues**

1. **Supabase Connection Error**
   - Check Project URL and API Key
   - Ensure database schema is applied

2. **Google Sign-In Not Working**
   - Verify Firebase configuration
   - Check bundle IDs match

3. **Navigation Issues**
   - Ensure routes are properly defined
   - Check BlocListener setup

4. **Validation Errors**
   - National ID must be exactly 14 digits
   - Phone must follow Egyptian format: 01[0125]XXXXXXXX

## 📞 Support

For issues or questions, please refer to:
- [Supabase Documentation](https://supabase.com/docs)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)

---

**وزارة الداخلية - جمهورية مصر العربية**
