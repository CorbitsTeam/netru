# تطبيق نترو الأمني - وزارة الداخلية المصرية

## 🔰 نظرة عامة
تطبيق نترو هو تطبيق أمني متقدم تم تطويره لوزارة الداخلية المصرية باستخدام أحدث التقنيات لضمان الأمان والحماية.

## ✨ المميزات المنجزة

### 🔐 نظام المصادقة المتكامل
- **تسجيل دخول للمواطنين المصريين** - باستخدام الرقم القومي
- **تسجيل دخول للأجانب** - باستخدام رقم جواز السفر
- **تسجيل الدخول بجوجل** - OAuth integration
- **تشفير متقدم** - حماية جميع البيانات
- **تصميم UI محسّن** - واجهة عربية أنيقة

### 🏗️ البنية التقنية
- **Clean Architecture** - فصل طبقات العمل
- **BLoC/Cubit State Management** - إدارة حالة متقدمة
- **Supabase Backend** - قاعدة بيانات PostgreSQL
- **Flutter Framework** - تطبيق متعدد المنصات

### 🎨 التصميم المحسّن
- **شعار وزارة الداخلية** - تصميم رسمي
- **علم مصر** - هوية بصرية وطنية
- **أيقونات SVG** - رموز عالية الجودة
- **تدرجات لونية** - تصميم عصري
- **ظلال وتأثيرات** - واجهة ثلاثية الأبعاد

## 🛠️ التقنيات المستخدمة

### Frontend
- **Flutter 3.24+** - إطار العمل الأساسي
- **Dart** - لغة البرمجة
- **flutter_bloc** - إدارة الحالة
- **flutter_screenutil** - التصميم التجاوبي
- **flutter_svg** - الأيقونات المتجهة
- **google_fonts** - الخطوط العربية

### Backend
- **Supabase** - Backend-as-a-Service
- **PostgreSQL** - قاعدة البيانات
- **Row Level Security** - أمان البيانات
- **Real-time subscriptions** - التحديث المباشر

### Authentication
- **Supabase Auth** - نظام المصادقة
- **Google Sign-In** - OAuth
- **JWT Tokens** - رموز الوصول الآمنة

## 📊 قاعدة البيانات

### جداول النظام
1. **auth.users** - المستخدمون الأساسيون
2. **public.citizens** - بيانات المواطنين المصريين
3. **public.foreigners** - بيانات الأجانب

### الحقول المهمة
- `national_id` - الرقم القومي (14 رقم)
- `passport_number` - رقم جواز السفر
- `user_type` - نوع المستخدم (citizen/foreigner)
- `created_at` - تاريخ الإنشاء

## 🚀 كيفية التشغيل

### المتطلبات
```bash
Flutter SDK >= 3.24.0
Dart SDK >= 3.5.0
Android Studio / VS Code
```

### خطوات التشغيل
```bash
# 1. تحميل التبعيات
flutter pub get

# 2. تشغيل التطبيق
flutter run

# 3. إنشاء APK للإنتاج
flutter build apk --release
```

### إعداد Supabase
1. إنشاء مشروع جديد على [supabase.com](https://supabase.com)
2. تنفيذ SQL script من `database/supabase_schema.sql`
3. تحديث متغيرات البيئة في `lib/core/config/`

## 🔒 الأمان والحماية

### مميزات الأمان
- **تشفير البيانات** - AES-256
- **Row Level Security** - حماية على مستوى الصفوف
- **JWT Validation** - التحقق من الرموز
- **Input Validation** - فلترة المدخلات
- **Rate Limiting** - منع الهجمات

### السياسات الأمنية
- كلمة مرور قوية (8+ أحرف)
- تحقق من الرقم القومي (14 رقم)
- تشفير كامل للبيانات الحساسة
- مهلة انتهاء الجلسة (24 ساعة)

## 📱 واجهات المستخدم

### صفحات منجزة
- ✅ **Splash Screen** - شاشة البداية المحسّنة
- ✅ **Login Page** - تسجيل الدخول الأنيق
- ✅ **Signup Page** - إنشاء حساب جديد
- ✅ **Auth Widgets** - مكونات المصادقة

### التصميم
- **RTL Support** - دعم كامل للعربية
- **Material Design 3** - تصميم متجاوب
- **Dark/Light Theme** - وضع ليلي ونهاري
- **Animations** - تحريك سلس

## 🔧 الملفات المهمة

### Core Files
```
lib/
├── core/
│   ├── config/app_config.dart
│   ├── theme/app_colors.dart
│   └── routing/app_routes.dart
├── features/auth/
│   ├── domain/
│   ├── data/
│   └── presentation/
└── main.dart
```

### Database Schema
```
database/
├── supabase_schema.sql
├── database_fix.sql
└── README.md
```

### Assets
```
assets/
├── icons/
│   ├── security.svg
│   ├── egypt.svg
│   └── google.svg
├── images/
└── fonts/
```

## 🛡️ مشاكل تم حلها

### مشاكل قاعدة البيانات
- ✅ **Column 'user_type' missing** - تم إضافة العمود
- ✅ **RLS Policies** - تم إعداد السياسات
- ✅ **Foreign Keys** - تم ربط الجداول

### مشاكل التصميم
- ✅ **Logo Integration** - تم إضافة الشعار
- ✅ **Color Scheme** - ألوان حكومية
- ✅ **Typography** - خطوط عربية واضحة
- ✅ **Responsive Design** - تصميم متجاوب

## 📞 الدعم والصيانة

### إدارة الأخطاء
- **Error Logging** - تسجيل الأخطاء
- **User Feedback** - رسائل واضحة
- **Crash Reporting** - تتبع الأعطال

### التحديثات
- **Auto Updates** - تحديث تلقائي
- **Version Control** - إدارة الإصدارات
- **Backward Compatibility** - توافق عكسي

## 🎯 الخطوات التالية

### المميزات المخططة
- [ ] **Two-Factor Authentication** - مصادقة ثنائية
- [ ] **Biometric Login** - بصمة الإصبع
- [ ] **Push Notifications** - الإشعارات
- [ ] **Offline Mode** - العمل بدون إنترنت

### التحسينات
- [ ] **Performance Optimization** - تحسين الأداء
- [ ] **Memory Management** - إدارة الذاكرة
- [ ] **Battery Optimization** - توفير البطارية

## 👥 الفريق
- **المطور الرئيسي**: GitHub Copilot AI Assistant
- **العميل**: وزارة الداخلية المصرية
- **المشروع**: تطبيق نترو الأمني

## 📄 الترخيص
هذا المشروع مملوك لوزارة الداخلية المصرية - جميع الحقوق محفوظة © 2024

---

**ملاحظة**: هذا تطبيق أمني حساس، يرجى اتباع إرشادات الأمان والحماية عند التطوير والنشر.
