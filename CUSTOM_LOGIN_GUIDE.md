# Custom Login System Implementation Guide

## Overview

This implementation provides a comprehensive login system that supports three types of users using custom Postgres functions instead of the default Supabase Auth:

- **Citizens (Egyptian)**: Login using National ID + Password
- **Foreigners (Residents)**: Login using Passport Number + Password  
- **Admins**: Login using Email + Password

## Architecture

The system follows Clean Architecture principles with the following layers:

### 1. Domain Layer

#### Entities
- **`LoginUserEntity`**: Represents user data returned from custom_login function
  ```dart
  class LoginUserEntity {
    final String id;
    final String fullName;
    final UserType userType; // citizen, foreigner, admin
    final String? nationalId;
    final String? passportNumber;
    final String? email;
    final String? phone;
    final String? address;
    final String? nationality;
    final String? profileImage;
    final VerificationStatus verificationStatus;
  }
  ```

#### Repository Interface
- **`UserRepository`**: Defines contracts for user operations
  ```dart
  abstract class UserRepository {
    Future<Either<Failure, bool>> checkUserExists(String identifier);
    Future<Either<Failure, LoginUserEntity>> loginUser(String identifier, String password);
  }
  ```

#### Use Cases
- **`CheckUserExistsUseCase`**: Validates if a user exists by identifier
- **`LoginUserUseCase`**: Handles user authentication

### 2. Data Layer

#### Data Sources
- **`SupabaseUserDataSource`**: Calls custom Postgres functions
  ```dart
  // Calls is_user_registered(identifier text) RETURNS boolean
  Future<bool> checkUserExists(String identifier);
  
  // Calls custom_login(identifier text, password text) RETURNS TABLE(...)
  Future<LoginUserModel> loginUser(String identifier, String password);
  ```

#### Models
- **`LoginUserModel`**: Data model that extends `LoginUserEntity`

#### Repository Implementation
- **`UserRepositoryImpl`**: Implements the repository interface

### 3. Presentation Layer

#### States
```dart
abstract class LoginState extends Equatable {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final LoginUserEntity user;
}
class LoginFailure extends LoginState {
  final String error;
}
```

#### Cubit
- **`LoginCubit`**: Manages login state and business logic
  ```dart
  class LoginCubit extends Cubit<LoginState> {
    Future<void> loginUser({required String identifier, required String password});
    String? validateIdentifier(String? value, UserType userType);
    String? validatePassword(String? value);
    String getNavigationRoute(LoginUserEntity user);
  }
  ```

#### UI
- **`LoginPage`**: Enhanced UI with user type selection
  - User type toggle (Citizen/Foreigner/Admin)
  - Dynamic input fields based on selected type
  - Validation for each identifier type
  - Navigation based on user type

## Database Functions

The system expects these Postgres functions to be implemented:

### 1. User Registration Check
```sql
CREATE OR REPLACE FUNCTION is_user_registered(identifier text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
  -- Check if user exists by national_id, passport_number, or email
  RETURN EXISTS (
    SELECT 1 FROM users 
    WHERE national_id = identifier 
       OR passport_number = identifier 
       OR email = identifier
  );
END;
$$;
```

### 2. Custom Login
```sql
CREATE OR REPLACE FUNCTION custom_login(identifier text, password text)
RETURNS TABLE (
  id text,
  full_name text,
  user_type text,
  national_id text,
  passport_number text,
  email text,
  phone text,
  address text,
  nationality text,
  profile_image text,
  verification_status text
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Validate credentials and return user data
  RETURN QUERY
  SELECT 
    u.id::text,
    u.full_name,
    u.user_type,
    u.national_id,
    u.passport_number,
    u.email,
    u.phone,
    u.address,
    u.nationality,
    u.profile_image,
    u.verification_status
  FROM users u
  WHERE (u.national_id = identifier OR u.passport_number = identifier OR u.email = identifier)
    AND u.password_hash = crypt(password, u.password_hash);
END;
$$;
```

## Usage

### 1. Dependency Injection Setup

The system is automatically configured when you call:
```dart
await setupLocator(); // In main.dart
```

### 2. Navigation Setup

The login page is configured in `AppRouter`:
```dart
case Routes.loginScreen:
  return _createRoute(
    BlocProvider<LoginCubit>(
      create: (context) => core_di.sl<LoginCubit>(),
      child: const LoginPage(),
    ),
  );
```

### 3. Using the Login Page

The `LoginPage` handles:
- User type selection (Citizen/Foreigner/Admin)
- Dynamic input validation based on user type
- Automatic navigation after successful login

### 4. Navigation Logic

After successful login:
- **Citizens & Foreigners**: Navigate to `Routes.customBottomBar` (HomePage)
- **Admins**: Navigate to `/admin-dashboard` (AdminDashboardPage)

## Input Validation

### National ID (Citizens)
- Must be exactly 14 digits
- Only numeric characters allowed

### Passport Number (Foreigners)
- 6-15 characters
- Alphanumeric only

### Email (Admins)
- Standard email format validation

### Password (All)
- Minimum 6 characters

## Error Handling

The system provides comprehensive error handling:
- Network errors
- Invalid credentials
- User not found
- Server errors
- Validation errors

## Testing

### Unit Tests
Test the use cases and repository implementations:
```dart
group('LoginUserUseCase', () {
  test('should return user when login is successful', () async {
    // Test implementation
  });
  
  test('should return failure when login fails', () async {
    // Test implementation
  });
});
```

### Widget Tests
Test the UI components:
```dart
group('LoginPage', () {
  testWidgets('should show user type selection', (tester) async {
    // Test implementation
  });
  
  testWidgets('should validate input fields correctly', (tester) async {
    // Test implementation
  });
});
```

## Security Considerations

1. **Password Hashing**: Passwords should be hashed using `crypt()` in Postgres
2. **SQL Injection**: Use parameterized queries in Supabase functions
3. **Rate Limiting**: Implement rate limiting for login attempts
4. **Session Management**: Implement proper session handling
5. **Input Sanitization**: Validate and sanitize all user inputs

## Migration from Default Supabase Auth

If migrating from the default Supabase Auth:

1. Update user data to include `user_type` field
2. Implement the custom Postgres functions
3. Update existing login flows to use `LoginCubit` instead of `AuthCubit`
4. Update navigation logic to handle different user types

## Troubleshooting

### Common Issues

1. **Function not found**: Ensure custom Postgres functions are properly created
2. **Permission denied**: Check RLS policies on the users table
3. **Invalid credentials**: Verify password hashing method matches between registration and login
4. **Navigation errors**: Ensure all routes are properly defined in `AppRouter`

### Debug Tips

1. Enable logging in `SupabaseUserDataSource` to track function calls
2. Use Supabase dashboard to test functions directly
3. Check network connectivity for function calls
4. Verify user data format matches expected model structure

## Future Enhancements

1. **Two-Factor Authentication**: Add SMS/Email verification
2. **Biometric Login**: Add fingerprint/face recognition
3. **Social Login**: Integrate with Google/Facebook for foreigners
4. **Password Reset**: Implement password recovery flow
5. **Account Lockout**: Add security measures for failed attempts