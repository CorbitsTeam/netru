# 🔔 نظام الإشعارات المتطور - تطبيق نترو

## 📖 نظرة عامة

تم تطوير نظام إشعارات شامل ومتطور لتطبيق نترو يدعم:
- إشعارات تلقائية عند تغيير حالة البلاغات
- إشعارات تعيين المحققين
- قوالب إشعارات احترافية باللغة العربية
- دعم FCM للإشعارات الفورية
- تكامل كامل مع Supabase Edge Functions

## ✅ المميزات المُنجزة

### 1. **نظام FCM Token Management** 🔐
- تسجيل تلقائي لـ FCM Tokens عند تسجيل الدخول
- دعم أجهزة متعددة لنفس المستخدم
- تنظيف تلقائي للرموز القديمة وغير النشطة
- دوال Upsert محسنة في قاعدة البيانات

### 2. **إشعارات تغيير حالة البلاغات** 📋
عندما يقوم المسؤول بتحديث حالة البلاغ، يتم إرسال إشعار تلقائي للمبلغ حسب الحالة:

#### الحالات المدعومة:
- **📩 تم الاستلام (received)**: إشعار بتأكيد استلام البلاغ
- **🔍 قيد التحقيق (under_investigation)**: إشعار ببدء التحقيق
- **✅ تم الحل (resolved)**: إشعار بحل البلاغ بنجاح
- **❌ مرفوض (rejected)**: إشعار برفض البلاغ مع الأسباب
- **🔒 مُغلق (closed)**: إشعار بإغلاق البلاغ نهائياً
- **⏳ في الانتظار (pending)**: إشعار بوضع البلاغ في قائمة الانتظار

### 3. **إشعارات تعيين المحققين** 👨‍💼
- إشعار للمبلغ عند تعيين محقق لقضيته
- إشعار للمحقق عند تكليفه بقضية جديدة
- معلومات شاملة عن القضية والأولوية

### 4. **Edge Function محسنة** 🚀
تم إنشاء `send-bulk-notifications` Edge Function جديدة تدعم:
- إرسال FCM حقيقي (ليس محاكاة)
- دعم أنواع إشعارات متعددة
- تسجيل مفصل للأخطاء والنجاحات
- تحديث حالة الإشعارات في قاعدة البيانات

### 5. **قوالب إشعارات احترافية** 🎨
خدمة `NotificationTemplateService` توفر:
- قوالب احترافية باللغة العربية
- رسائل مفصلة ومفيدة للمستخدم
- دعم المعلومات الإضافية (اسم المحقق، الوقت المتوقع، إلخ)
- إيموجي مناسبة لكل نوع إشعار

### 6. **معالجة الإشعارات الواردة** 📱
تحسين `NotificationService` لدعم:
- التوجيه التلقائي للصفحة المناسبة عند النقر على الإشعار
- دعم أنواع إشعارات متعددة
- تسجيل مفصل للتنقل والأخطاء

## 🔧 الإعداد والتكوين

### 1. متطلبات Supabase

#### قاعدة البيانات:
تأكد من وجود الجداول التالية:
```sql
-- جدول المستخدمين
users (id, first_name, last_name, user_type, ...)

-- جدول البلاغات
reports (id, user_id, reporter_first_name, reporter_last_name, case_number, ...)

-- جدول الإشعارات
notifications (id, user_id, title, body, notification_type, ...)

-- جدول رموز FCM
user_fcm_tokens (id, user_id, fcm_token, device_type, is_active, ...)
```

#### Edge Functions:
1. **تفعيل `send-bulk-notifications` Function**:
```bash
supabase functions deploy send-bulk-notifications
```

2. **تعيين متغيرات البيئة**:
```bash
supabase secrets set FCM_SERVER_KEY=your_fcm_server_key
```

### 2. إعداد Firebase

#### الحصول على FCM Server Key:
1. اذهب إلى Firebase Console
2. اختر مشروعك
3. Settings → Cloud Messaging
4. انسخ Server Key وأضفه لـ Supabase Secrets

### 3. تفعيل الإشعارات في التطبيق

#### في `main.dart`:
```dart
await NotificationService().init();
await SimpleFcmService().init();
```

## 📋 كيفية الاستخدام

### 1. إرسال إشعار عند تغيير حالة البلاغ

يتم تلقائياً عند استدعاء:
```dart
adminReportDataSource.updateReportStatus(
  reportId: "report_id",
  status: "resolved", // أي حالة من الحالات المدعومة
  notes: "تم حل المشكلة بنجاح",
);
```

### 2. إرسال إشعار عند تعيين محقق

يتم تلقائياً عند استدعاء:
```dart
adminReportDataSource.assignReport(
  reportId: "report_id",
  investigatorId: "investigator_id",
  notes: "تم تعيين المحقق أحمد محمد",
);
```

### 3. إرسال إشعارات مجمعة يدوية

```dart
await edgeFunctionsService.sendBulkNotifications(
  userIds: ["user1", "user2", "user3"],
  title: "إشعار عام مهم",
  body: "رسالة الإشعار هنا",
  data: {
    "type": "general",
    "action": "view_announcement",
  },
);
```

### 4. استخدام قوالب الإشعارات المتقدمة

```dart
// قالب ترحيب بمستخدم جديد
final welcomeTemplate = NotificationTemplateService.welcomeUser(
  userName: "أحمد محمد",
  userType: "citizen",
);

// قالب تنبيه أمني
final securityTemplate = NotificationTemplateService.securityAlert(
  alertType: "emergency",
  location: "شارع التحرير، وسط البلد",
  severity: "عالي",
  description: "حادث مروري كبير",
);
```

## 🧪 اختبار النظام

### 1. اختبار FCM Token Registration:
```dart
final token = await SimpleFcmService().getFcmTokenAndRegister();
print("FCM Token: $token");
```

### 2. اختبار إرسال إشعار تجريبي:
```bash
curl -X POST 'https://yesjtlgciywmwrdpjqsr.supabase.co/functions/v1/send-bulk-notifications' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "userIds": ["user_id_here"],
    "title": "اختبار الإشعار",
    "body": "هذا إشعار تجريبي",
    "notificationType": "general"
  }'
```

### 3. مراقبة السجلات:
- راقب سجلات Edge Functions في Supabase Dashboard
- راقب سجلات التطبيق للتأكد من تسجيل FCM Tokens
- تحقق من جدول `notifications` في قاعدة البيانات

## 🔍 استكشاف الأخطاء

### مشاكل شائعة وحلولها:

#### 1. FCM Tokens غير مسجلة:
```dart
// تحقق من إعدادات الأذونات
final hasPermission = await NotificationService().requestNotificationPermissions();
if (!hasPermission) {
  // اطلب من المستخدم تفعيل الإشعارات في إعدادات النظام
}
```

#### 2. إشعارات لا تصل:
- تأكد من وجود FCM_SERVER_KEY في Supabase Secrets
- تحقق من صحة FCM Tokens في قاعدة البيانات
- راجع سجلات Edge Function للأخطاء

#### 3. مشاكل في التوجيه عند النقر:
```dart
// تأكد من وجود البيانات الصحيحة في payload الإشعار
data: {
  "type": "report_status_update",
  "report_id": "actual_report_id",
  "navigation_route": "/report_details",
}
```

## 🚀 التطويرات المستقبلية

### الميزات المقترحة:
1. **إشعارات مجدولة**: إرسال إشعارات في أوقات محددة
2. **إشعارات جماعية متقدمة**: حسب الموقع الجغرافي أو المحافظة
3. **قوالب إشعارات قابلة للتخصيص**: من لوحة التحكم
4. **إحصائيات الإشعارات**: معدلات الفتح والتفاعل
5. **إشعارات صوتية**: للحالات العاجلة

### تحسينات تقنية:
1. **Retry Logic**: إعادة المحاولة للإشعارات الفاشلة
2. **Rate Limiting**: منع الإرسال المفرط
3. **A/B Testing**: اختبار أنواع رسائل مختلفة
4. **Analytics Integration**: ربط مع Google Analytics

## 📞 الدعم

لأي مساعدة أو استفسارات:
1. راجع السجلات في Supabase Dashboard
2. تحقق من جداول قاعدة البيانات المطلوبة
3. تأكد من إعداد FCM بشكل صحيح
4. اختبر Edge Functions من خلال Supabase CLI

---

**ملاحظة**: هذا النظام جاهز للاستخدام الفوري! فقط تأكد من إعداد FCM_SERVER_KEY في Supabase Secrets وكل شيء سيعمل بسلاسة! 🎉