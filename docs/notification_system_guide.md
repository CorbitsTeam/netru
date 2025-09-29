# 🔔 نظام الإشعارات المطور لتطبيق نترو

## 📋 نظرة عامة

تم تطوير نظام إشعارات متكامل لإرسال الإشعارات لمقدمي البلاغات عند تحديث حالة بلاغاتهم، مع الحفظ في قاعدة البيانات واستخدام Edge Functions للإرسال عبر FCM.

## 🏗️ المكونات الرئيسية

### 1. Edge Function: `send-fcm-notification`
- **المسار**: `supabase/functions/send-fcm-notification/index.ts`
- **الوظيفة**: إرسال الإشعارات عبر Firebase Cloud Messaging
- **المدخلات**:
  ```json
  {
    "fcm_token": "string",
    "title": "string", 
    "body": "string",
    "data": "object (optional)"
  }
  ```

### 2. ReportNotificationService
- **المسار**: `lib/core/services/report_notification_service.dart`
- **الوظيفة**: إدارة إرسال الإشعارات وحفظها في قاعدة البيانات
- **الوظائف الرئيسية**:
  - `sendReportStatusNotification()`: إرسال إشعار عند تحديث حالة البلاغ
  - `sendReportSubmissionSuccessNotification()`: إرسال إشعار عند تقديم البلاغ بنجاح

### 3. تحديثات Admin Services
- تم تحديث `AdminReportRemoteDataSourceImpl` لاستخدام الخدمة الجديدة
- تكامل مع dependency injection في `injection_container.dart`

## 📊 هيكل قاعدة البيانات

### جدول `notifications`
```sql
- id: uuid (primary key)
- user_id: uuid (foreign key to users)
- title: text (عنوان الإشعار)
- title_ar: text (عنوان بالعربية)
- body: text (محتوى الإشعار)
- body_ar: text (محتوى بالعربية)
- notification_type: text (نوع الإشعار)
- reference_id: uuid (معرف البلاغ)
- reference_type: text (نوع المرجع)
- data: jsonb (بيانات إضافية)
- is_read: boolean (تم القراءة)
- is_sent: boolean (تم الإرسال)
- priority: text (الأولوية)
- created_at: timestamp
- sent_at: timestamp
```

### جدول `user_fcm_tokens`
```sql
- id: uuid (primary key)
- user_id: uuid (foreign key to users)
- fcm_token: text (رمز FCM)
- device_type: text (نوع الجهاز)
- device_id: text (معرف الجهاز)
- is_active: boolean (نشط)
- last_used: timestamp
```

## 🔄 تدفق العمل

### 1. عند تحديث حالة البلاغ:
```
1. Admin يحدث حالة البلاغ
2. AdminReportRemoteDataSource يستدعي ReportNotificationService
3. الخدمة تجلب بيانات البلاغ والمستخدم
4. تجلب FCM tokens للمستخدم
5. تنشئ محتوى الإشعار حسب الحالة الجديدة
6. تحفظ الإشعار في قاعدة البيانات
7. ترسل push notification عبر Edge Function
8. تحدث حالة الإرسال في قاعدة البيانات
```

### 2. أنواع الحالات المدعومة:
- `received`: تم استلام البلاغ
- `under_investigation`: قيد التحقيق
- `resolved`: تم الحل
- `rejected`: مرفوض
- `closed`: مغلق
- `pending`: في قائمة الانتظار

## 🛠️ التركيب والإعداد

### 1. إعداد Edge Function:
```bash
# نشر Edge Function
supabase functions deploy send-fcm-notification

# تعيين متغير البيئة
supabase secrets set FCM_SERVER_KEY=your-fcm-server-key
```

### 2. إعداد Dependency Injection:
تم إضافة `ReportNotificationService` في `injection_container.dart`:
```dart
sl.registerLazySingleton<ReportNotificationService>(
  () => ReportNotificationService(),
);
```

### 3. تحديث Admin Data Source:
```dart
AdminReportRemoteDataSourceImpl({
  required this.supabaseClient,
  required this.notificationService,
  required this.reportNotificationService, // جديد
});
```

## 🧪 الاختبار

### 1. اختبارات الوحدة:
```bash
flutter test test/notification_system_integration_test.dart
```

### 2. اختبار تطبيقي:
```dart
import 'package:netru_app/core/demos/notification_system_demo.dart';

// فحص سريع
bool isHealthy = await NotificationSystemDemo.quickHealthCheck();

// اختبار شامل
await NotificationSystemDemo.runFullTest();

// عرض الإرشادات
NotificationSystemDemo.showUsageInstructions();
```

### 3. اختبار يدوي:
```dart
final service = ReportNotificationService();

// إرسال إشعار تحديث حالة
await service.sendReportStatusNotification(
  reportId: 'your-report-id',
  newStatus: 'resolved',
  caseNumber: 'CASE123',
  adminNotes: 'تم حل المشكلة بنجاح',
);
```

## 🔐 الأمان والخصوصية

### 1. التحقق من الهوية:
- استخدام Supabase authentication للتحقق من صحة المستخدم
- التحقق من وجود البلاغ وملكية المستخدم له

### 2. حماية البيانات:
- تشفير FCM tokens في قاعدة البيانات
- استخدام HTTPS لجميع الاتصالات
- تقييد الوصول لـ Edge Functions

### 3. إدارة الأخطاء:
- معالجة شاملة للأخطاء مع logging
- آليات fallback عند فشل الإرسال
- retry mechanisms للإرسال المؤجل

## 📈 المراقبة والصيانة

### 1. Logging:
- استخدام `LoggerService` لتسجيل جميع العمليات
- تتبع حالات النجاح والفشل
- معلومات تفصيلية عن كل إرسال

### 2. إحصائيات الأداء:
- معدل نجاح الإرسال
- أوقات الاستجابة
- عدد الإشعارات المرسلة يومياً

### 3. الصيانة:
- تنظيف FCM tokens غير النشطة
- أرشفة الإشعارات القديمة
- تحديث templates الإشعارات

## 🚀 التطوير المستقبلي

### 1. تحسينات مقترحة:
- إضافة إشعارات email backup
- دعم إشعارات SMS للحالات العاجلة
- تخصيص templates حسب نوع البلاغ
- إضافة scheduled notifications

### 2. ميزات متقدمة:
- Rich notifications مع actions
- Image notifications للتحديثات المرئية
- Push notifications grouping
- Advanced analytics dashboard

## 📞 الدعم والمساعدة

### في حالة وجود مشاكل:
1. تحقق من logs في Supabase Dashboard
2. تأكد من صحة FCM_SERVER_KEY
3. تحقق من FCM tokens في قاعدة البيانات
4. استخدم `NotificationSystemDemo.quickHealthCheck()`

### الإبلاغ عن المشاكل:
- استخدم LoggerService للحصول على تفاصيل الخطأ
- تحقق من حالة Edge Functions في Supabase
- راجع permissions الجهاز للإشعارات

---

**تاريخ التحديث**: سبتمبر 2025  
**الإصدار**: v1.0  
**المطور**: فريق تطبيق نترو