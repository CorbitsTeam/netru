# 🚀 Quick Setup Guide - نظام الإشعارات المتطور

## ✅ التحقق من الإعداد الحالي

### 1. Database Schema ✓
- [x] جدول `users` موجود
- [x] جدول `notifications` موجود  
- [x] جدول `user_fcm_tokens` موجود
- [x] دالة `upsert_fcm_token_str` موجودة

### 2. Edge Functions ✓
- [x] `admin-bulk-notifications` موجودة
- [x] `send-bulk-notifications` جديدة ومحسنة

### 3. Flutter Services ✓
- [x] `NotificationService` محسن
- [x] `SimpleFcmService` جاهز
- [x] `NotificationTemplateService` جديد
- [x] `AdminReportRemoteDataSource` محسن

## 🔧 الخطوات المطلوبة للتفعيل

### 1. إعداد FCM Server Key في Supabase

```bash
# في terminal الخاص بك، نفذ الأمر التالي:
supabase secrets set FCM_SERVER_KEY="YOUR_ACTUAL_FCM_SERVER_KEY_HERE"
```

**كيفية الحصول على FCM Server Key:**
1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. اختر مشروع `netru_app`
3. اذهب إلى Settings ⚙️ → Project settings
4. تبويب "Cloud Messaging"
5. انسخ "Server key" (يبدأ بـ `AAAAxxxx...`)

### 2. تفعيل Edge Functions

```bash
# تفعيل الـ Edge Function الجديدة
supabase functions deploy send-bulk-notifications

# التأكد من تفعيل الـ Edge Function القديمة
supabase functions deploy admin-bulk-notifications
```

### 3. اختبار النظام

#### أ. اختبار تسجيل FCM Token:
```dart
// في تطبيقك، شغل هذا الكود لاختبار تسجيل FCM Token
final fcmService = SimpleFcmService();
final token = await fcmService.getFcmTokenAndRegister();
print("✅ FCM Token registered: ${token?.substring(0, 20)}...");
```

#### ب. اختبار إرسال إشعار تجريبي:

**باستخدام curl:**
```bash
curl -X POST 'https://yesjtlgciywmwrdpjqsr.supabase.co/functions/v1/send-bulk-notifications' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "userIds": ["USER_ID_HERE"],
    "title": "🎉 اختبار النظام",
    "body": "إذا وصلك هذا الإشعار، فالنظام يعمل بنجاح!",
    "notificationType": "general"
  }'
```

**من داخل التطبيق:**
```dart
// في AdminReportRemoteDataSource أو أي مكان آخر
await edgeFunctionsService.sendBulkNotifications(
  userIds: ["USER_ID_FROM_DATABASE"],
  title: "🎉 اختبار النظام",
  body: "إذا وصلك هذا الإشعار، فالنظام يعمل بنجاح!",
  data: {"type": "test"},
);
```

### 4. تفعيل الإشعارات التلقائية

الإشعارات التلقائية ستعمل فوراً عند:

#### تغيير حالة البلاغ:
```dart
// سيتم إرسال إشعار تلقائياً للمبلغ
await adminReportDataSource.updateReportStatus(
  reportId: "report_id",
  status: "resolved", // أو أي حالة أخرى
  notes: "تم حل المشكلة",
);
```

#### تعيين محقق:
```dart
// سيتم إرسال إشعارين: واحد للمبلغ وآخر للمحقق
await adminReportDataSource.assignReport(
  reportId: "report_id", 
  investigatorId: "investigator_id",
  notes: "تم التعيين",
);
```

## 🔍 التحقق من عمل النظام

### 1. مراقبة السجلات في Supabase:
- اذهب إلى Supabase Dashboard
- Edge Functions → Logs
- ابحث عن رسائل مثل "FCM sent successfully" أو "notifications created"

### 2. فحص قاعدة البيانات:
```sql
-- التحقق من تسجيل FCM Tokens
SELECT * FROM user_fcm_tokens WHERE is_active = true;

-- التحقق من الإشعارات المرسلة
SELECT * FROM notifications ORDER BY created_at DESC LIMIT 10;

-- التحقق من معدل نجاح الإرسال
SELECT 
  COUNT(*) as total_notifications,
  COUNT(*) FILTER (WHERE is_sent = true) as sent_notifications
FROM notifications 
WHERE created_at > NOW() - INTERVAL '24 hours';
```

### 3. اختبار استقبال الإشعارات:
- تأكد من تفعيل الإشعارات في إعدادات التطبيق
- اختبر على أجهزة مختلفة (Android/iOS)
- تحقق من وصول الإشعارات حتى لو كان التطبيق مغلق

## 🚨 حل المشاكل الشائعة

### المشكلة: FCM Tokens لا تُسجل
**الحل:**
```dart
// تأكد من طلب الأذونات أولاً
final hasPermission = await Permission.notification.request();
if (!hasPermission.isGranted) {
  // اطلب من المستخدم تفعيل الإشعارات يدوياً
  await openAppSettings();
}
```

### المشكلة: الإشعارات لا تصل
**الحلول:**
1. تحقق من وجود `FCM_SERVER_KEY` في Supabase Secrets
2. تأكد من صحة FCM Server Key
3. تحقق من أن FCM Token مسجل وفعال في قاعدة البيانات
4. راجع سجلات Edge Functions للأخطاء

### المشكلة: الإشعارات تصل لكن لا تفتح الصفحة الصحيحة
**الحل:**
```dart
// تأكد من وجود البيانات الصحيحة في payload
data: {
  "type": "report_status_update",
  "report_id": "ACTUAL_REPORT_ID",
  "navigation_route": "/report_details",
  "action": "view_report",
}
```

## 📊 المتابعة والإحصائيات

### مراقبة الأداء:
```sql
-- إحصائيات يومية للإشعارات
SELECT 
  DATE(created_at) as date,
  COUNT(*) as total_sent,
  notification_type,
  COUNT(*) FILTER (WHERE is_sent = true) as successful_deliveries
FROM notifications 
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at), notification_type
ORDER BY date DESC;

-- معدل نجاح FCM Tokens
SELECT 
  device_type,
  COUNT(*) as total_tokens,
  COUNT(*) FILTER (WHERE is_active = true) as active_tokens
FROM user_fcm_tokens 
GROUP BY device_type;
```

---

## 🎉 النظام جاهز!

بمجرد تنفيذ الخطوات أعلاه، ستحصل على:

✅ **إشعارات تلقائية** عند كل تغيير في حالة البلاغ  
✅ **قوالب احترافية** باللغة العربية مع إيموجي مناسبة  
✅ **تكامل كامل** مع FCM للإشعارات الفورية  
✅ **تسجيل ومراقبة** شاملة للنظام  
✅ **دعم أجهزة متعددة** لكل مستخدم  

**🔥 النظام يعمل تلقائياً بدون أي تدخل إضافي!**

كل ما عليك فعله هو تعيين `FCM_SERVER_KEY` والنظام سيبدأ العمل فوراً! 🚀