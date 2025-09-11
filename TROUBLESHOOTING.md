# دليل حل المشاكل - تطبيق نترو

## 🔧 المشاكل الشائعة وحلولها

### 1. مشاكل قاعدة البيانات

#### خطأ: "Could not find the 'user_type' column"
```sql
-- الحل: تشغيل هذا الكود في Supabase SQL Editor
ALTER TABLE citizens ADD COLUMN IF NOT EXISTS user_type TEXT DEFAULT 'citizen';
ALTER TABLE foreigners ADD COLUMN IF NOT EXISTS user_type TEXT DEFAULT 'foreigner';
```

#### خطأ: Permission denied for table
```sql
-- الحل: تفعيل RLS policies
ALTER TABLE citizens ENABLE ROW LEVEL SECURITY;
ALTER TABLE foreigners ENABLE ROW LEVEL SECURITY;

-- إضافة سياسات الوصول
CREATE POLICY "Users can view own data" ON citizens
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own data" ON citizens
FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### 2. مشاكل المصادقة

#### تسجيل الدخول بجوجل لا يعمل
```dart
// تحقق من إعدادات Google في pubspec.yaml
dependencies:
  google_sign_in: ^6.3.0
  
// تأكد من إضافة Google services في Android
// android/app/google-services.json
```

#### انتهاء صلاحية الجلسة
```dart
// في main.dart
void main() async {
  // إعداد auto-refresh للتوكن
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}
```

### 3. مشاكل التصميم

#### الخطوط العربية لا تظهر
```yaml
# في pubspec.yaml
flutter:
  fonts:
    - family: Almarai
      fonts:
        - asset: assets/fonts/Almarai-Regular.ttf
        - asset: assets/fonts/Almarai-Bold.ttf
          weight: 700
```

#### الأيقونات SVG لا تظهر
```dart
// تأكد من إضافة flutter_svg
dependencies:
  flutter_svg: ^2.2.0

// في pubspec.yaml
assets:
  - assets/icons/
```

### 4. مشاكل الأداء

#### التطبيق بطيء في التحميل
```dart
// إضافة loading states
class AuthButton extends StatelessWidget {
  final bool isLoading;
  
  @override
  Widget build(BuildContext context) {
    return isLoading 
      ? CircularProgressIndicator()
      : ElevatedButton(...);
  }
}
```

#### استهلاك ذاكرة عالي
```dart
// تنظيف Controllers
@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

### 5. مشاكل البناء (Build)

#### خطأ في Android build
```bash
# تنظيف المشروع
flutter clean
flutter pub get

# إعادة بناء الـ Android
cd android
./gradlew clean
cd ..
flutter build apk
```

#### خطأ في iOS build
```bash
# في مجلد ios
cd ios
rm Podfile.lock
rm -rf Pods
pod install
cd ..
flutter build ios
```

### 6. مشاكل الشبكة

#### عدم الاتصال بـ Supabase
```dart
// فحص الاتصال
class NetworkChecker {
  static Future<bool> hasConnection() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-project.supabase.co/rest/v1/'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### 7. أخطاء التحقق من صحة البيانات

#### الرقم القومي غير صحيح
```dart
String? validateNationalId(String? value) {
  if (value == null || value.isEmpty) {
    return 'الرقم القومي مطلوب';
  }
  if (value.length != 14) {
    return 'الرقم القومي يجب أن يكون 14 رقم';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'الرقم القومي يجب أن يحتوي على أرقام فقط';
  }
  return null;
}
```

#### كلمة المرور ضعيفة
```dart
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'كلمة المرور مطلوبة';
  }
  if (value.length < 8) {
    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  }
  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    return 'كلمة المرور يجب أن تحتوي على حروف كبيرة وصغيرة وأرقام';
  }
  return null;
}
```

## 🚨 حالات الطوارئ

### فقدان اتصال قاعدة البيانات
1. تحقق من حالة Supabase Dashboard
2. فحص إعدادات الشبكة
3. التبديل إلى وضع Offline مؤقتاً

### خطأ في المصادقة
1. مسح cache التطبيق
2. إعادة تسجيل الدخول
3. فحص صلاحية التوكن

### تعطل التطبيق
1. فحص logs في Crashlytics
2. إعادة تشغيل التطبيق
3. تحديث إلى آخر إصدار

## 📞 الدعم الفني

### معلومات مهمة عند طلب المساعدة
- إصدار Flutter
- إصدار التطبيق
- نوع الجهاز
- رسالة الخطأ كاملة
- خطوات إعادة إنتاج المشكلة

### ملفات السجل المهمة
```bash
# Flutter logs
flutter logs

# Android logs
adb logcat

# iOS logs
xcrun simctl spawn booted log stream
```

## 🔄 التحديثات الطارئة

### تحديث الطوارئ للأمان
```dart
// فحص إجباري للتحديث
class ForceUpdateChecker {
  static Future<bool> needsUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    
    // فحص أحدث إصدار من السيرفر
    final latestVersion = await getLatestVersion();
    
    return compareVersions(currentVersion, latestVersion) < 0;
  }
}
```

### إيقاف ميزة مؤقتاً
```dart
// استخدام Remote Config
class FeatureFlags {
  static Future<bool> isGoogleSignInEnabled() async {
    return await RemoteConfig.instance.getBool('google_signin_enabled');
  }
}
```

---

**مهم**: احتفظ بهذا الدليل محدثاً وتأكد من توثيق أي مشاكل جديدة وحلولها.
