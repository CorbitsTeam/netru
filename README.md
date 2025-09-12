# نترو - تطبيق الأمن والحماية المجتمعي

<div align="center">
  <img src="assets/images/mainLogo.png" alt="نترو Logo" width="200"/>
  
  **من أجل أمن وأمان مصر**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.35.1-blue.svg)](https://flutter.dev/)
  [![Platform](https://img.shields.io/b# NetRu App - Clean Architecture Flutter Application

A comprehensive Flutter application built with Clean Architecture principles, featuring BLoC/Cubit state management, Supabase integration, advanced permission handling, and notification system.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with clear separation of concerns:

### 📁 Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── constants/                 # App constants
│   ├── data/                      # Data layer implementation
│   │   ├── datasources/          # External data sources
│   │   ├── models/               # Data models (DTOs)
│   │   └── repositories/         # Repository implementations
│   ├── domain/                    # Business logic layer
│   │   ├── entities/             # Business entities
│   │   ├── repositories/         # Repository contracts
│   │   └── usecases/             # Business use cases
│   ├── cubit/                     # State management
│   │   ├── permission/           # Permission management
│   │   ├── theme/                # Theme management
│   │   └── locale/               # Localization
│   ├── di/                        # Dependency injection
│   ├── errors/                    # Error handling
│   ├── services/                  # Core services
│   ├── utils/                     # Utilities
│   └── widgets/                   # Reusable widgets
├── features/                      # Feature modules
│   ├── home/                     # Home feature
│   ├── splash/                   # Splash screen
│   └── reports/                  # Reports feature
├── app.dart                      # App widget
└── main.dart                     # Entry point
```

## 🔧 Clean Architecture Layers

### 1. **Domain Layer** (Business Logic)
- **Entities**: Core business objects (`User`, `Permission`, `NotificationPayload`)
- **Repositories**: Abstract contracts for data operations
- **Use Cases**: Business rules and application logic

### 2. **Data Layer** (External Concerns)
- **Data Sources**: External APIs, local storage, etc.
- **Models**: Data Transfer Objects (DTOs)
- **Repository Implementations**: Concrete repository implementations

### 3. **Presentation Layer** (UI)
- **Cubits/Blocs**: State management using BLoC pattern
- **Widgets**: UI components and screens

## ⚡ Features Implemented

### 🔐 Permission Management System

Complete permission handling with Clean Architecture:

```dart
// Domain entities
PermissionType.location
PermissionType.camera
PermissionType.storage
PermissionType.notification

// Use cases
CheckPermissionUseCase
RequestPermissionUseCase
RequestMultiplePermissionsUseCase
OpenAppSettingsUseCase

// Cubit states
PermissionInitial
PermissionLoading
PermissionGranted(permission)
PermissionDenied(permission)
PermissionError(message)
```

#### Usage Example:
```dart
// Request essential permissions
await permissionCubit.requestEssentialPermissions();

// Request specific permission
await permissionCubit.requestCameraPermission();

// Check permission status
await permissionCubit.checkPermission(PermissionType.location);
```

### 📦 Supabase Integration (Ready for Implementation)

Complete setup for Supabase services:

#### Authentication:
- Email/password authentication
- Social logins (Google, Apple)
- Session management
- Password reset

#### Database:
- CRUD operations with PostgreSQL
- Real-time subscriptions
- Type-safe queries

#### Storage:
- File upload/download
- Image and video handling
- Secure URL generation

### 🔔 Push Notifications (Firebase + Supabase Ready)

Comprehensive notification system:
- Local notifications
- Push notifications via FCM
- Background message handling
- Notification scheduling

### 📊 Logging System

Centralized logging with multiple levels:

```dart
final logger = LoggerService();

// Different log levels
logger.logInfo('Information message');
logger.logError('Error occurred', error, stackTrace);
logger.logWarning('Warning message');

// Specific event logging
logger.logApiRequest('GET', '/users', data);
logger.logPermissionGranted('Camera');
logger.logAuthEvent('Sign in successful');
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2+)
- Dart SDK
- Android Studio / VS Code
- Firebase account (for notifications)
- Supabase account (for backend services)

### Installation

1. **Clone the repository:**
```bash
git clone [repository-url]
cd netru_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure Firebase:**
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)

4. **Configure Supabase:**
   - Update Supabase URL and keys in the service locator
   - Set up database tables
   - Configure storage buckets

5. **Run the app:**
```bash
flutter run
```

## 🛠️ Dependency Injection

Using GetIt for clean dependency injection:

```dart
// Service registration
sl.registerLazySingleton<LoggerService>(() => LoggerService()..init());
sl.registerLazySingleton<PermissionRepository>(() => PermissionRepositoryImpl(dataSource: sl()));

// Use case registration
sl.registerLazySingleton(() => RequestPermissionUseCase(sl()));

// Cubit registration
sl.registerFactory(() => PermissionCubit(
  checkPermissionUseCase: sl(),
  requestPermissionUseCase: sl(),
  // ... other dependencies
));
```

## 📝 State Management with BLoC/Cubit

Clean state management following BLoC patterns:

### Permission Cubit Example:
```dart
class PermissionCubit extends Cubit<PermissionState> {
  final RequestPermissionUseCase _requestPermissionUseCase;
  
  PermissionCubit({required RequestPermissionUseCase requestPermissionUseCase})
    : _requestPermissionUseCase = requestPermissionUseCase,
      super(PermissionInitial());

  Future<void> requestPermission(PermissionType type) async {
    emit(PermissionLoading());
    
    final result = await _requestPermissionUseCase(type);
    result.fold(
      (failure) => emit(PermissionError(failure.message)),
      (permission) => permission.isGranted 
        ? emit(PermissionGranted(permission))
        : emit(PermissionDenied(permission)),
    );
  }
}
```

## 🔧 Configuration

### 1. Supabase Configuration

Update in `lib/core/di/service_locator.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 2. Firebase Configuration

Add Firebase configuration files and initialize in main.dart:
```dart
await Firebase.initializeApp();
```

### 3. Permissions (Android)

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### 4. Permissions (iOS)

Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for photo capture</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access for location-based features</string>
```

## 🧪 Testing

The project is set up for comprehensive testing:

- **Unit Tests**: Business logic and use cases
- **Widget Tests**: UI components
- **Integration Tests**: End-to-end functionality

Run tests:
```bash
flutter test
```

## 📈 Performance Considerations

- **Lazy Loading**: Dependencies are registered as lazy singletons
- **Memory Management**: Proper disposal of streams and controllers
- **Efficient State Management**: Minimal rebuilds with BLoC
- **Background Processing**: Non-blocking permission requests

## 🔄 Future Enhancements

### Ready for Implementation:
1. **Complete Supabase Integration**: Database operations, storage, real-time
2. **Push Notifications**: Firebase messaging integration
3. **Offline Support**: Local caching and sync
4. **Social Authentication**: Google, Apple, Facebook logins
5. **Advanced Analytics**: User behavior tracking
6. **Biometric Authentication**: Fingerprint and face recognition

## 🤝 Contributing

1. Follow Clean Architecture principles
2. Write comprehensive tests
3. Document your code
4. Use conventional commits
5. Ensure code quality with linting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ayman** - Flutter Expert specializing in Clean Architecture and enterprise-level mobile applications.

---

**Note**: This application demonstrates professional Flutter development practices with Clean Architecture, comprehensive error handling, logging, and production-ready patterns. The architecture is designed to be scalable, maintainable, and testable.e/Platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev/)
  [![License](https://img.shields.io/badge/License-Private-red.svg)](#)
</div>

## نظرة عامة

تطبيق **نترو** هو تطبيق أمني متطور يهدف إلى تعزيز الأمن المجتمعي من خلال ربط المواطنين بوزارة الداخلية المصرية. يوفر التطبيق منصة سهلة وآمنة للإبلاغ عن الحوادث الأمنية، متابعة القضايا الأمنية، وتلقي التنبيهات المهمة.

## الميزات الرئيسية

### 🚨 نظام الإبلاغات المتقدم

- إرسال بلاغات فورية للجهات الأمنية
- تتبع حالة البلاغات المرسلة
- نظام تصنيف متنوع للحوادث

### 🗺️ خريطة الجرائم التفاعلية

- عرض الأنشطة الإجرامية على الخريطة
- مناطق الخطر والتحذيرات الأمنية
- إحصائيات مفصلة حسب المنطقة

### 📊 إحصائيات وتحليلات

- إحصائيات الجرائم والحوادث
- معدلات الأمان في المناطق المختلفة
- تقارير دورية عن الوضع الأمني

### 🔔 نظام التنبيهات الذكي

- تنبيهات فورية للحوادث القريبة
- إشعارات حالة البلاغات
- تحذيرات أمنية مهمة

### 👤 إدارة الحساب الشخصي

- ملف شخصي آمن
- سجل البلاغات السابقة
- إعدادات الخصوصية والأمان

## لقطات الشاشة

### الشاشة الرئيسية

<img src="assets/screens-app/home.jpg" alt="الشاشة الرئيسية" width="300"/>

تعرض الشاشة الرئيسية أهم الأخبار الأمنية وإحصائيات سريعة حول الوضع الأمني.

### نظام التنبيهات

<img src="assets/screens-app/alerts.jpg" alt="التنبيهات" width="300"/>

نظام تنبيهات شامل يشمل:

- تنبيهات المناطق عالية الخطورة
- حل البلاغات المرسلة
- تنبيهات أمنية قريبة من الموقع

### جهود الأجهزة الأمنية

<img src="assets/screens-app/details.jpg" alt="جهود الأجهزة الأمنية" width="300"/>

متابعة عمليات الأجهزة الأمنية ونتائجها في محافظة شمال سيناء.

### خريطة الجرائم

<img src="assets/screens-app/heat-map.jpg" alt="خريطة الجرائم" width="300"/>

خريطة تفاعلية تعرض:

- النشاط الأخير للنقاط الساخنة
- مناطق الجرائم المختلفة بألوان متدرجة
- إحصائيات الحوادث حسب الموقع

### مساعد الذكي الاصطناعي

<img src="assets/screens-app/ai-assistant.jpg" alt="الشاشة الرئيسية المحسنة" width="300"/>


### شاشة تسجيل الدخول

<img src="assets/screens-app/login.jpg" alt="تسجيل الدخول" width="300"/>

نظام تسجيل دخول آمن يتضمن:

- الرقم القومي
- الرقم السري مع خيار إظهار/إخفاء
- خيار "تذكرني"

### إعدادات الحساب

<img src="assets/screens-app/profile.jpg" alt="الإعدادات" width="300"/>

لوحة إعدادات شاملة تتضمن:

- معلومات الحساب الشخصي
- تفاصيل شخصية
- تغيير كلمة المرور
- تفعيل/إلغاء التحقق
- خيارات اللغة (العربية/English)

### تفاصيل البلاغ

<img src="assets/screens-app/report-details.jpg" alt="تفاصيل البلاغ" width="300"/>

صفحة مفصلة لتقديم البلاغات تشمل:

- معلومات المبلغ الشخصية
- معلومات البلاغ التفصيلية
- إرفاق الوسائط (صور/فيديو)
- الإجراءات المتاحة

### تقديم بلاغ

<img src="assets/screens-app/report-form.jpg" alt="تقديم بلاغ" width="300"/>

نموذج شامل لتقديم البلاغات يتضمن:

- معلومات شخصية
- نوع البلاغ (قائمة منسدلة متنوعة)
- تفاصيل البلاغ
- الموقع الجغرافي
- إرفاق الملفات

### حالة البلاغات

<img src="assets/screens-app/report-stutas.jpg" alt="حالة البلاغات" width="300"/>

متابعة شاملة لجميع البلاغات المرسلة مع حالات مختلفة:

- قيد المراجعة (رمادي)
- قيد التحقيق للوحدات المعنية (برتقالي)
- تم الحل (أخضر)
- مغلق نهائياً (أحمر)

### إنشاء حساب جديد

<img src="assets/screens-app/sign-up.jpg" alt="إنشاء حساب" width="300"/>

صفحة تسجيل مستخدم جديد تتطلب:

- الاسم الأول والأخير
- الرقم القومي
- رقم المصنع
- رقم الهاتف
- الرقم السري وتأكيده

### شاشة البداية

<img src="assets/screens-app/splash.jpg" alt="شاشة البداية" width="300"/>

شاشة ترحيب تعرض شعار "نترو" مع الشعار الوطني "من أجل أمن وأمان مصر".

## المتطلبات التقنية

### Flutter SDK

```
Flutter 3.35.1
```

### المنصات المدعومة

- 📱 iOS 11.0+
- 🤖 Android API 21+

### الأذونات المطلوبة

#### Android

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>يحتاج التطبيق للوصول لموقعك لتحديد موقع البلاغ</string>
<key>NSCameraUsageDescription</key>
<string>يحتاج التطبيق للكاميرا لتصوير الحوادث</string>
```

## التثبيت والتشغيل

### المتطلبات الأساسية

تأكد من تثبيت:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) أو [VS Code](https://code.visualstudio.com/)
- [Xcode](https://developer.apple.com/xcode/) (للتطوير على iOS)

### خطوات التشغيل

1. **استنساخ المشروع**

```bash
git clone [repository-url]
cd netro_app
```

2. **تثبيت التبعيات**

```bash
flutter pub get
```

3. **تشغيل أكواد البناء**

```bash
flutter packages pub run build_runner build
```

4. **تشغيل التطبيق**

```bash
flutter run
```

### بناء التطبيق للإنتاج

#### Android (APK)

```bash
flutter build apk --release
```

#### Android (App Bundle)

```bash
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

## التبعيات الرئيسية

| Package                | الإصدار | الوصف                       |
| ---------------------- | ------- | --------------------------- |
| `flutter_bloc`         | latest  | إدارة الحالة                |
| `dio`                  | ^5.9.0  | HTTP Client                 |
| `geolocator`           | ^14.0.2 | خدمات الموقع                |
| `flutter_map`          | ^8.2.1  | عرض الخرائط                 |
| `cached_network_image` | ^3.4.1  | تحميل وحفظ الصور            |
| `shared_preferences`   | ^2.5.3  | التخزين المحلي              |
| `permission_handler`   | ^12.0.1 | إدارة الأذونات              |
| `easy_localization`    | ^3.0.8  | الترجمة والدعم متعدد اللغات |
| `flutter_screenutil`   | ^5.9.3  | التصميم المتجاوب            |
| `google_fonts`         | ^6.3.0  | الخطوط المخصصة              |
| `lottie`               | ^3.3.1  | الرسوم المتحركة             |
| `animate_do`           | ^4.2.0  | تأثيرات الحركة              |

## الأمان والخصوصية

- 🔐 تشفير شامل لجميع البيانات المرسلة
- 🛡️ التحقق الثنائي من الهوية
- 📱 حماية البيانات الشخصية وفقاً لقوانين حماية البيانات
- 🔒 تخزين آمن للمعلومات الحساسة

## الدعم والمساعدة

للحصول على المساعدة أو الإبلاغ عن المشاكل:

- 📧 البريد الإلكتروني: support@netro-app.gov.eg
- 📞 الخط الساخن: 19696
- 🌐 الموقع الرسمي: [www.netro-app.gov.eg]

## ملاحظات مهمة

- هذا التطبيق مخصص للاستخدام داخل جمهورية مصر العربية فقط
- يجب التحقق من صحة البيانات المدخلة قبل الإرسال
- في حالة الطوارئ، يُنصح بالاتصال المباشر بالأرقام المخصصة للطوارئ

---

<div align="center">
  
**تم التطوير بواسطة فريق كوربتس**

_من أجل أمن وأمان مصر_ 🇪🇬

</div>
