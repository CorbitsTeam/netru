# نظام البروفيل المتكامل - نترو

تم تطوير نظام بروفيل متكامل يسمح للمستخدمين بإدارة حساباتهم بسهولة.

## 🏗️ المكونات الرئيسية

### 1. صفحة البروفيل المحسنة (EnhancedProfilePage)
**الملف:** `enhanced_profile_page.dart`
- عرض معلومات المستخدم بتصميم أنيق
- إحصائيات المستخدم (البلاغات، القضايا، النقاط)
- أقسام منظمة للمعلومات والأمان
- زر التوجه لتعديل البروفيل والإعدادات

### 2. صفحة تعديل البروفيل (EditProfilePage)
**الملف:** `edit_profile_page.dart`
- تعديل المعلومات الشخصية (الاسم، الهاتف، الموقع، العنوان)
- رفع وتغيير صورة الملف الشخصي
- دعم Image Picker (كاميرا/معرض)
- رفع الصور لـ Supabase تلقائياً
- حفظ البيانات المحدثة

### 3. صفحة الإعدادات المبسطة (SimpleSettingsPage)
**الملف:** `simple_settings_page.dart`
- عرض معلومات المستخدم مع زر التعديل
- إعدادات أساسية (الوضع المظلم، الإشعارات، اللغة)
- إجراءات الحساب (تغيير كلمة المرور، تقييم التطبيق)
- تسجيل خروج آمن

## 🔧 الميزات التقنية

### Use Cases الجديدة
1. **UpdateUserProfileUseCase** - تحديث بيانات المستخدم
2. **UploadProfileImageUseCase** - رفع صور الملف الشخصي

### Data Layer
- **UserDataSource.updateUserProfile()** - تحديث البيانات في Supabase
- **AuthRepository.uploadDocument()** - رفع الصور للتخزين

### التحديثات على قاعدة البيانات
```sql
-- حقل الصورة الشخصية موجود بالفعل في جدول users
profile_image TEXT
```

## 📱 كيفية الاستخدام

### للوصول لصفحة البروفيل المحسنة:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EnhancedProfilePage(),
  ),
);
```

### للوصول لصفحة تعديل البروفيل:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EditProfilePage(),
  ),
);
```

### للوصول لصفحة الإعدادات:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SimpleSettingsPage(),
  ),
);
```

## 🎯 الوظائف المتاحة

### تعديل الصورة الشخصية
- اختيار من الكاميرا أو المعرض
- ضغط الصورة تلقائياً
- رفع فوري لـ Supabase
- تحديث محلي للبيانات

### تحديث البيانات
- تعديل الاسم الكامل
- تحديث رقم الهاتف
- تغيير الموقع والعنوان
- حفظ آمن مع validation

### الإعدادات
- التبديل بين الوضع العادي والمظلم
- تفعيل/إلغاء الإشعارات  
- تغيير اللغة (عربي/إنجليزي)
- تسجيل خروج آمن

## 🔒 الأمان

- جميع التحديثات تمر عبر Use Cases
- تنظيف البيانات قبل الحفظ
- رفع الصور بأسماء فريدة
- تحديث البيانات المحلية بعد النجاح

## 📋 الملفات المُحدثة

1. **الملفات الجديدة:**
   - `edit_profile_page.dart` - صفحة تعديل البروفيل
   - `simple_settings_page.dart` - صفحة الإعدادات المبسطة
   - `update_user_profile.dart` - Use case التحديث
   - `upload_profile_image.dart` - Use case رفع الصور

2. **الملفات المُحدثة:**
   - `enhanced_profile_page.dart` - إضافة navigation للصفحات الجديدة
   - `user_repository.dart` - إضافة updateUserProfile method
   - `user_data_source.dart` - إضافة updateUserProfile implementation
   - `injection_container.dart` - تسجيل Use Cases الجديدة

## 🚀 الخطوات التالية

يمكنك الآن:
1. اختبار رفع الصور من الكاميرا والمعرض
2. تعديل البيانات الشخصية وحفظها
3. التنقل بين الصفحات بسلاسة
4. استخدام الإعدادات المختلفة

جميع الوظائف تعمل مع معالجة شاملة للأخطاء وتصميم متجاوب!