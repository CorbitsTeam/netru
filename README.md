<div align="center">
  <img src="assets/screens-app/mainLogo.svg" alt="Netru Logo" width="200"/>

# Netru - نترو

### تطبيق الأمان والخدمات الذكية للمواطنين المصريين

تطبيق متكامل يوفر خدمات الأمان والحماية مع مساعد ذكي قانوني، خرائط الجريمة التفاعلية، ونظام التبليغ الإلكتروني للمواطنين المصريين البالغين (18 سنة فأكثر).

![Flutter Version](https://img.shields.io/badge/Flutter-3.7.2-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS-green)
![License](https://img.shields.io/badge/License-MIT-blue)
![Language](https://img.shields.io/badge/Language-Arabic%20|%20English-orange)

</div>

---

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Technologies](#technologies)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 About

**Netru** هو تطبيق Flutter متطور مصمم خصيصاً للمواطنين المصريين، يهدف إلى توفير منصة شاملة للأمان والخدمات الذكية. يتضمن التطبيق مجموعة متنوعة من الميزات المتقدمة مثل المساعد الذكي القانوني، خرائط الجريمة التفاعلية، ونظام التبليغ الإلكتروني.

### 🇪🇬 للمواطنين المصريين

التطبيق مُحسّن خصيصاً للبيئة المصرية ويستهدف المواطنين البالغين (18 سنة فأكثر) مع دعم كامل للغة العربية والقوانين المصرية.

---

## ✨ Features

### 🤖 المساعد الذكي القانوني

- **سوبيك**: مساعد ذكي متخصص في القوانين المصرية
- دعم المحادثات المتعددة مع حفظ تاريخ الجلسات
- إجابات فورية على الاستفسارات القانونية
- واجهة محادثة سهلة ومتطورة

### 🗺️ خرائط الجريمة التفاعلية

- **Heat Map متطورة** لعرض بيانات الجريمة في الوقت الفعلي
- تحديد المناطق الآمنة والخطرة
- إحصائيات تفصيلية حسب المنطقة والنوع
- تكامل مع خدمات الموقع GPS

### 📝 نظام التبليغ الإلكتروني

- إنشاء التقارير الإلكترونية بسهولة
- دعم رفع المستندات والصور
- تتبع حالة التقارير في الوقت الفعلي
- إنتاج ملفات PDF احترافية

### 🔐 نظام المصادقة المتطور

- تسجيل دخول آمن مع Supabase
- استخراج بيانات الهوية المصرية تلقائياً
- حماية البيانات الشخصية

### 📱 واجهة مستخدم متطورة

- دعم الوضع المظلم والفاتح
- واجهة responsive مع Screen Util
- خطوط عربية أنيقة (Almarai، Tajawal)
- رسوم متحركة سلسة مع Flutter Animate

### 🔔 نظام الإشعارات الذكي

- إشعارات Firebase Cloud Messaging
- إشعارات محلية مخصصة
- تنبيهات أمنية في الوقت الفعلي

### 👨‍💼 لوحة تحكم إدارية

- إدارة المستخدمين والتقارير
- إحصائيات شاملة
- نظام إشعارات المدراء

### 📊 ميزات إضافية

- **إدارة القضايا**: متابعة القضايا القانونية
- **الأخبار والتحديثات**: آخر الأخبار الأمنية
- **الخرائط التفاعلية**: Flutter Map مع خدمات الموقع
- **ضغط الصور**: تحسين أداء التطبيق
- **المسح الضوئي للوثائق**: استخراج البيانات من المستندات

---

## 📱 Screenshots

### 🔐 Authentication Screens

<div align="center">
  <img src="assets/screens-app/auth-one.png" alt="تسجيل دخول" width="250"/>
  <img src="assets/screens-app/auth-two.png" alt="إنشاء حساب" width="250"/>
</div>

### 🏠 Home & Main Features

<div align="center">
  <img src="assets/screens-app/home.png" alt="الشاشة الرئيسية" width="250"/>
  <img src="assets/screens-app/settings.png" alt="الإعدادات" width="250"/>
</div>

### 🤖 AI Chatbot & Legal Assistant

<div align="center">
  <img src="assets/screens-app/ai-chat-bot.png" alt="المساعد الذكي" width="250"/>
</div>

### 🗺️ Crime Heat Map

<div align="center">
  <img src="assets/screens-app/crime-heatmap.png" alt="خريطة الجريمة" width="250"/>
</div>

### 📝 Reports System

<div align="center">
  <img src="assets/screens-app/create-report.png" alt="إنشاء تقرير" width="250"/>
  <img src="assets/screens-app/report.png" alt="عرض التقرير" width="250"/>
</div>

---

## 🛠️ Technologies

### Core

- **Flutter** 3.7.2
- **Dart** SDK
- **Clean Architecture** Pattern

### State Management

- **Flutter Bloc** 8.1.4 (BLoC Pattern)
- **Equatable** 2.0.7 (Value Equality)

### Backend & Database

- **Supabase Flutter** 2.8.1 (Backend as a Service)
- **Firebase Core** 3.13.0
- **Firebase Messaging** 15.2.5 (Push Notifications)

### Key Packages

| Package                         | Version | Purpose                           |
| ------------------------------- | ------- | --------------------------------- |
| **flutter_bloc**                | ^8.1.4  | State Management (BLoC Pattern)   |
| **supabase_flutter**            | ^2.8.1  | Backend Database & Authentication |
| **dio**                         | ^5.9.0  | HTTP Client for API Calls         |
| **cached_network_image**        | ^3.4.1  | Image Caching & Loading           |
| **flutter_screenutil**          | ^5.9.3  | Responsive UI Design              |
| **google_fonts**                | ^6.3.0  | Typography & Font Loading         |
| **google_sign_in**              | ^6.2.1  | Google Authentication             |
| **flutter_map**                 | ^8.2.1  | Interactive Maps                  |
| **geolocator**                  | ^14.0.2 | GPS Location Services             |
| **geocoding**                   | ^3.0.0  | Address ↔️ Coordinates             |
| **image_picker**                | ^1.2.0  | Camera & Gallery Access           |
| **cunning_document_scanner**    | ^1.3.1  | Document Scanning                 |
| **flutter_local_notifications** | ^19.1.0 | Local Push Notifications          |
| **shared_preferences**          | ^2.5.3  | Local Data Persistence            |
| **lottie**                      | ^3.3.1  | Vector Animations                 |
| **flutter_animate**             | ^4.5.2  | UI Animations                     |
| **pin_code_fields**             | ^8.0.1  | OTP Input Fields                  |
| **country_picker**              | ^2.0.24 | Country Code Selection            |
| **pdf**                         | ^3.10.1 | PDF Generation                    |
| **fl_chart**                    | ^0.64.0 | Charts & Data Visualization       |
| **get_it**                      | ^8.2.0  | Dependency Injection              |
| **dartz**                       | ^0.10.1 | Functional Programming            |
| **logger**                      | ^2.4.0  | Advanced Logging                  |

### Development Tools

- **flutter_lints** ^3.0.0 (Code Analysis)
- **build_runner** ^2.4.10 (Code Generation)
- **bloc_test** ^9.1.5 (BLoC Testing)

---

## 📁 Project Structure

```
lib/
├── 📁 core/                    # Core functionality
│   ├── 📁 constants/          # App constants
│   ├── 📁 cubit/             # Global state management
│   │   ├── locale/           # Localization cubit
│   │   └── theme/            # Theme cubit
│   ├── 📁 di/                # Dependency injection
│   ├── 📁 domain/            # Core domain entities
│   ├── 📁 errors/            # Error handling
│   ├── 📁 extensions/        # Dart extensions
│   ├── 📁 helper/            # Helper utilities
│   ├── 📁 network/           # Network handling
│   ├── 📁 routing/           # App routing
│   ├── 📁 services/          # Core services
│   ├── 📁 theme/             # App theming
│   ├── 📁 utils/             # Utilities & helpers
│   └── 📁 widgets/           # Reusable widgets
├── 📁 features/               # Feature modules
│   ├── 📁 admin/             # Admin dashboard
│   ├── 📁 auth/              # Authentication
│   ├── 📁 cases/             # Legal cases
│   ├── 📁 chatbot/           # AI Legal Assistant
│   ├── 📁 heatmap/           # Crime heat maps
│   ├── 📁 home/              # Home screen
│   ├── 📁 news/              # News & updates
│   ├── 📁 notifications/     # Notifications
│   ├── 📁 onboarding/        # App introduction
│   ├── 📁 profile/           # User profile
│   ├── 📁 reports/           # Electronic reporting
│   ├── 📁 settings/          # App settings
│   └── 📁 splash/            # Splash screen
├── 📁 shared/                 # Shared components
├── app.dart                   # App configuration
├── app_bloc_observer.dart     # BLoC observer
├── firebase_options.dart      # Firebase config
└── main.dart                 # App entry point
```

### 🏗️ Architecture Pattern

يستخدم المشروع **Clean Architecture** مع **BLoC Pattern** للحصول على:

- فصل واضح بين الطبقات
- سهولة الاختبار والصيانة
- قابلية إعادة الاستخدام
- إدارة حالة متقدمة

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.7.2 أو أحدث)
- **Dart SDK**
- **Android Studio** / **Xcode**
- **Git**
- حساب **Firebase** (للإشعارات)
- حساب **Supabase** (للقاعدة البيانات)

### 🔧 Firebase Setup

1. إنشاء مشروع Firebase جديد
2. تفعيل Firebase Authentication
3. تفعيل Firebase Cloud Messaging
4. تحميل ملفات التكوين:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

### 🔧 Supabase Setup

1. إنشاء مشروع Supabase جديد
2. الحصول على Project URL و Anon Key
3. إعداد قاعدة البيانات والجداول المطلوبة

---

## 💻 Installation

### 1. Clone المستودع

```bash
git clone https://github.com/CorbitsTeam/netru_app.git
cd netru_app
```

### 2. تثبيت التبعيات

```bash
flutter pub get
```

### 3. إعداد ملفات التكوين

```bash
# تكوين Firebase
flutter packages pub run build_runner build

# إنشاء أيقونة التطبيق
flutter packages pub run flutter_launcher_icons:main
```

### 4. تشغيل التطبيق

```bash
# للأندرويد
flutter run

# للـ iOS
flutter run
```

---

## 🎮 Usage

### 🔐 بدء الاستخدام

1. **التسجيل**: إنشاء حساب جديد أو تسجيل دخول
2. **إعداد البيانات**: إضافة بيانات الهوية المصرية
3. **الاستكشاف**: تصفح الميزات المختلفة

### 🤖 استخدام المساعد الذكي

- انتقل إلى صفحة "المساعد الذكي"
- ابدأ محادثة جديدة
- اسأل عن القوانين المصرية أو استفسارات عامة

### 🗺️ استخدام خريطة الجريمة

- السماح بالوصول للموقع
- عرض الإحصائيات حسب المنطقة
- تصفح البيانات التفاعلية

### 📝 إنشاء تقرير

- الانتقال إلى صفحة "إنشاء تقرير"
- ملء البيانات المطلوبة
- رفع المستندات (اختياري)
- إرسال التقرير

---

## 🤝 Contributing

نرحب بالمساهمات من المطورين! للمساهمة:

### 1. Fork المشروع

```bash
git fork https://github.com/CorbitsTeam/netru_app.git
```

### 2. إنشاء branch جديد

```bash
git checkout -b feature/new-feature
```

### 3. Commit التغييرات

```bash
git commit -m "Add some feature"
```

### 4. Push للـ branch

```bash
git push origin feature/new-feature
```

### 5. إنشاء Pull Request

### 📋 Guidelines

- اتباع Clean Architecture
- كتابة tests للمكونات الجديدة
- استخدام التعليقات باللغة العربية
- اتباع Flutter/Dart style guide

---

## 📄 License

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

```
MIT License

Copyright (c) 2024 Netru App

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📞 Contact & Support

- **البريد الإلكتروني**: corbitsteam@gmail.com
- **Documentation**: [التوثيق الكامل](https://netru-eg.blogspot.com/)

---

## 🙏 Acknowledgments

شكر خاص لـ:

- **Flutter Team** لإطار العمل الرائع
- **Supabase** لخدمات Backend المتميزة
- **Firebase** لخدمات الإشعارات
- **جميع المطورين** الذين ساهموا في المكتبات المستخدمة
- **المجتمع المصري** لدعم مشاريع التكنولوجيا المحلية

---

<div align="center">
  <p>صنع بـ ❤️ في مصر للمواطنين المصريين</p>
  <p>Made with ❤️ in Egypt for Egyptian Citizens</p>

**Netru - نترو | أمانك معنا**

</div>
