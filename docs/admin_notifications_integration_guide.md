# دليل التكامل - نظام الإشعارات الإدارية المحدث
# Admin Notifications Integration Guide - Updated System

## نظرة عامة | Overview

تم تحديث نظام الإشعارات الإدارية ليستخدم **Supabase Edge Functions** بدلاً من الاستعلامات المباشرة لقاعدة البيانات. هذا التحديث يوفر:

The Admin Notifications system has been updated to use **Supabase Edge Functions** instead of direct database queries. This update provides:

- 🔐 **أمان محسن**: مصادقة إدارية مركزية
- 📱 **دعم FCM**: إرسال إشعارات push فورية  
- ⚡ **أداء أفضل**: معالجة محسنة للطلبات
- 📊 **إحصائيات دقيقة**: تتبع شامل للإشعارات
- 🔧 **سهولة الصيانة**: كود مركزي وموحد

---

## البنية الجديدة | New Architecture

### 1. Edge Function
```
📁 /supabase/functions/admin-notifications/
├── index.ts              # الوظيفة الرئيسية
├── types.ts              # تعريفات الأنواع
└── firebase-jwt.ts       # مساعد Firebase JWT
```

### 2. خدمات Flutter
```
📁 lib/core/services/
└── admin_notifications_service.dart   # خدمة Flutter الجديدة

📁 lib/features/admin/data/datasources/
└── admin_notification_remote_data_source.dart   # مصدر البيانات المحدث
```

---

## كيفية الاستخدام | How to Use

### 1. إعداد الخدمة في Dependency Injection

```dart
// في ملف service_locator.dart أو main.dart
import 'package:netru_app/core/services/admin_notifications_service.dart';

void setupServices() {
  // تسجيل الخدمات
  sl.registerLazySingleton<AdminNotificationsService>(
    () => AdminNotificationsService(),
  );
  
  sl.registerLazySingleton<AdminNotificationRemoteDataSource>(
    () => AdminNotificationRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
      edgeFunctionsService: sl<SupabaseEdgeFunctionsService>(),
      adminNotificationsService: sl<AdminNotificationsService>(),
    ),
  );
}
```

### 2. جلب جميع الإشعارات | Get All Notifications

```dart
// في الـ Repository أو مباشرة
final dataSource = sl<AdminNotificationRemoteDataSource>();

try {
  final notifications = await dataSource.getAllNotifications(
    page: 1,
    limit: 20,
    search: 'بحث',
    type: 'general',
    status: 'sent',
  );
  
  print('تم جلب ${notifications.length} إشعار');
} catch (e) {
  print('خطأ في جلب الإشعارات: $e');
}
```

### 3. إنشاء إشعار جديد | Create New Notification

```dart
try {
  final notification = await dataSource.createNotification(
    title: 'إشعار جديد',
    body: 'محتوى الإشعار',
    type: 'general',
    userIds: ['user_123'], // اختياري
    data: {'key': 'value'}, // بيانات إضافية
  );
  
  print('تم إنشاء الإشعار: ${notification.id}');
} catch (e) {
  print('خطأ في إنشاء الإشعار: $e');
}
```

### 4. إرسال إشعارات جماعية | Send Bulk Notifications

```dart
// إرسال لمستخدمين محددين
try {
  await dataSource.sendBulkNotifications(
    userIds: ['user_1', 'user_2', 'user_3'],
    title: 'إشعار جماعي',
    body: 'هذا إشعار لمجموعة من المستخدمين',
    type: 'announcement',
    data: {'category': 'news'},
  );
  
  print('تم إرسال الإشعارات الجماعية بنجاح');
} catch (e) {
  print('خطأ في إرسال الإشعارات: $e');
}

// إرسال لمجموعات محددة
try {
  await dataSource.sendNotificationToGroups(
    userGroups: ['citizens'],
    title: 'إشعار للمواطنين',
    body: 'رسالة مهمة لجميع المواطنين',
    type: 'government',
  );
  
  print('تم إرسال الإشعار للمجموعة بنجاح');
} catch (e) {
  print('خطأ في إرسال إشعار المجموعة: $e');
}
```

### 5. جلب الإحصائيات | Get Statistics

```dart
try {
  final stats = await dataSource.getNotificationStatistics();
  
  print('إجمالي الإشعارات: ${stats['total']}');
  print('المرسلة: ${stats['sent']}');
  print('في الانتظار: ${stats['pending']}');
  print('حسب النوع: ${stats['by_type']}');
} catch (e) {
  print('خطأ في جلب الإحصائيات: $e');
}
```

### 6. حذف إشعار | Delete Notification

```dart
try {
  await dataSource.deleteNotification('notification_id');
  print('تم حذف الإشعار بنجاح');
} catch (e) {
  print('خطأ في حذف الإشعار: $e');
}
```

---

## أنواع الإشعارات المدعومة | Supported Notification Types

### 1. الأنواع الأساسية | Basic Types
- `general` - إشعارات عامة
- `announcement` - إعلانات رسمية
- `emergency` - إشعارات طوارئ
- `report_update` - تحديثات البلاغات
- `government` - إشعارات حكومية

### 2. أهداف الإرسال | Target Types
- `all` - جميع المستخدمين
- `specific_users` - مستخدمين محددين
- `user_type` - نوع مستخدمين (مواطنين، موظفين، إلخ)

---

## معالجة الأخطاء | Error Handling

```dart
Future<void> handleNotificationOperation() async {
  try {
    // عملية الإشعار
    await dataSource.createNotification(/* ... */);
  } on SupabaseException catch (e) {
    // أخطاء Supabase
    print('خطأ في قاعدة البيانات: ${e.message}');
  } on FormatException catch (e) {
    // أخطاء تنسيق البيانات
    print('خطأ في تنسيق البيانات: $e');
  } catch (e) {
    // أخطاء عامة
    print('خطأ غير متوقع: $e');
  }
}
```

---

## متطلبات الأمان | Security Requirements

### 1. مصادقة الإدارة | Admin Authentication
- يجب أن يكون المستخدم مسجل دخول
- نوع المستخدم يجب أن يكون `admin`
- جلسة صالحة مطلوبة

### 2. أذونات FCM | FCM Permissions
- ملف خدمة Firebase صالح
- تكوين FCM صحيح في المشروع
- أذونات الإشعارات في التطبيق

---

## مراقبة الأداء | Performance Monitoring

### 1. سجلات النظام | System Logs
```dart
// تفعيل السجلات المفصلة
LoggerService().setLogLevel(LogLevel.debug);

// مراقبة الأداء
final stopwatch = Stopwatch()..start();
await dataSource.getAllNotifications();
print('وقت الاستجابة: ${stopwatch.elapsedMilliseconds}ms');
```

### 2. مؤشرات الأداء | Performance Metrics
- ⏱️ **وقت الاستجابة**: < 2 ثانية للطلبات العادية
- 📊 **معدل النجاح**: > 99% للعمليات الأساسية
- 💾 **استهلاك الذاكرة**: محسن للاستخدام الطويل

---

## استكشاف الأخطاء | Troubleshooting

### مشاكل شائعة | Common Issues

#### 1. فشل في المصادقة
```
Error: Admin authentication required
```
**الحل**: تأكد من تسجيل دخول المستخدم كمدير

#### 2. خطأ في FCM
```
Error: Failed to send FCM notification
```
**الحل**: تحقق من ملف خدمة Firebase والإعدادات

#### 3. خطأ في قاعدة البيانات
```
Error: Failed to query notifications
```
**الحل**: تأكد من صحة اتصال Supabase

### أدوات التشخيص | Diagnostic Tools

```dart
// اختبار الاتصال
Future<bool> testConnection() async {
  try {
    await AdminNotificationsService().getStatistics();
    return true;
  } catch (e) {
    return false;
  }
}

// اختبار FCM
Future<bool> testFCM() async {
  try {
    await AdminNotificationsService().createNotification(
      userId: 'test_user',
      title: 'اختبار',
      body: 'اختبار FCM',
    );
    return true;
  } catch (e) {
    return false;
  }
}
```

---

## التحديثات المستقبلية | Future Updates

### مميزات قادمة | Upcoming Features
- 📅 **جدولة الإشعارات**: إرسال في أوقات محددة
- 🎯 **استهداف جغرافي**: حسب المحافظة والمدينة
- 📈 **تحليلات متقدمة**: تقارير مفصلة
- 🔔 **إشعارات تفاعلية**: أزرار وإجراءات

### تحسينات الأداء | Performance Improvements
- ⚡ **تخزين مؤقت**: تحسين سرعة الاستجابة
- 🔄 **إعادة المحاولة**: آلية تلقائية للأخطاء
- 📊 **ضغط البيانات**: تقليل استهلاك الشبكة

---

## الدعم والمساعدة | Support & Help

للحصول على المساعدة أو الإبلاغ عن مشاكل:
- 📧 البريد الإلكتروني: [email]
- 📝 GitHub Issues: [repository]
- 📖 التوثيق الكامل: [docs link]

---

**ملاحظة**: تأكد من تحديث جميع التبعيات وإعدادات Firebase قبل استخدام النظام الجديد.