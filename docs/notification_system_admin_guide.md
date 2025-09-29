# دليل نظام إدارة الإشعارات للإدارة

## نظرة عامة
تم تطوير نظام إدارة الإشعارات ليعمل مع جدول واحد موحد للإشعارات ويوفر جميع الوظائف المطلوبة للإدارة.

## الوظائف المتاحة

### 1. عرض جميع الإشعارات
- **المسار**: `?action=get_notifications`
- **المعاملات**:
  - `page`: رقم الصفحة (افتراضي: 1)
  - `limit`: عدد العناصر في الصفحة (افتراضي: 20)
  - `type`: نوع الإشعار (news, reportUpdate, reportComment, system, general)
  - `priority`: أولوية الإشعار (low, normal, high, urgent)
  - `status`: حالة الإشعار (sent, scheduled, draft, failed)
  - `search`: نص البحث في العنوان والمحتوى
  - `user_id`: معرف مستخدم محدد

### 2. إرسال إشعار جماعي
- **المسار**: `?action=send_bulk`
- **الطريقة**: POST
- **البيانات المطلوبة**:
```json
{
  "title": "عنوان الإشعار",
  "title_ar": "العنوان بالعربية (اختياري)",
  "body": "محتوى الإشعار",
  "body_ar": "المحتوى بالعربية (اختياري)",
  "notification_type": "general",
  "priority": "normal",
  "target_type": "all|governorate|user_type|specific_users",
  "target_value": "قيمة الهدف حسب النوع",
  "data": {}
}
```

### 3. إنشاء إشعار فردي
- **المسار**: `?action=create_notification`
- **الطريقة**: POST
- **البيانات المطلوبة**:
```json
{
  "user_id": "معرف المستخدم",
  "title": "عنوان الإشعار",
  "body": "محتوى الإشعار",
  "notification_type": "general",
  "priority": "normal"
}
```

### 4. جدولة إشعار
- **المسار**: `?action=schedule_notification`
- **الطريقة**: POST
- **البيانات المطلوبة**:
```json
{
  "title": "عنوان الإشعار",
  "body": "محتوى الإشعار",
  "target_type": "all",
  "scheduled_at": "2024-01-01T12:00:00Z"
}
```

### 5. عرض الإشعارات المجدولة
- **المسار**: `?action=get_scheduled`
- **الطريقة**: GET

### 6. إلغاء إشعار مجدول
- **المسار**: `?action=cancel_scheduled&notification_id=ID`
- **الطريقة**: DELETE

### 7. حذف إشعار
- **المسار**: `?action=delete_notification&notification_id=ID`
- **الطريقة**: DELETE

### 8. تحديد إشعار كمقروء
- **المسار**: `?action=mark_read`
- **الطريقة**: POST
- **البيانات**: `{"notification_id": "ID"}`

### 9. الحصول على قائمة المحافظات
- **المسار**: `?action=get_governorates`
- **الطريقة**: GET

## إحصائيات الإشعارات

### 1. الإحصائيات العامة
- **المسار**: `?action=analytics&type=overview`
- **البيانات المُعادة**:
  - إجمالي الإشعارات
  - الإشعارات المرسلة
  - الإشعارات المجدولة
  - الإشعارات المسودة
  - الإشعارات المقروءة
  - معدل التسليم
  - معدل الفتح
  - التوزيع حسب النوع والأولوية

### 2. الإحصائيات اليومية
- **المسار**: `?action=analytics&type=daily`
- **المعاملات**: `start_date`, `end_date`

### 3. الإحصائيات بالساعة
- **المسار**: `?action=analytics&type=hourly`
- **المعاملات**: `start_date`, `end_date`

### 4. التوزيع الجغرافي
- **المسار**: `?action=analytics&type=governorate`
- **المعاملات**: `start_date`, `end_date`

### 5. التوزيع حسب النوع
- **المسار**: `?action=analytics&type=type_breakdown`
- **المعاملات**: `start_date`, `end_date`

### 6. معدلات التسليم
- **المسار**: `?action=analytics&type=delivery_rates`
- **المعاملات**: `start_date`, `end_date`, `governorate`

## أنواع الإشعارات المدعومة

- `news`: إشعارات الأخبار
- `reportUpdate`: تحديثات التقارير
- `reportComment`: تعليقات التقارير
- `system`: إشعارات النظام
- `general`: إشعارات عامة

## مستويات الأولوية

- `low`: منخفضة
- `normal`: عادية (افتراضي)
- `high`: عالية
- `urgent`: عاجلة

## أنواع الاستهداف

- `all`: جميع المستخدمين
- `governorate`: مستخدمو محافظة معينة
- `user_type`: نوع مستخدم معين
- `specific_users`: مستخدمون محددون

## مميزات النظام

1. **جدول موحد**: يستخدم جدول `notifications` واحد لجميع الإشعارات
2. **إرسال فوري**: دعم إرسال الإشعارات الفورية لجميع المستخدمين
3. **إرسال مجدول**: إمكانية جدولة الإشعارات لوقت لاحق
4. **تصفية متقدمة**: تصفية الإشعارات حسب معايير متعددة
5. **إحصائيات مفصلة**: تقارير شاملة عن أداء الإشعارات
6. **دعم اللغة العربية**: عناوين ومحتوى بالعربية
7. **إرسال جماعي**: إرسال لآلاف المستخدمين دفعة واحدة
8. **دعم FCM**: تجهيز لإرسال إشعارات فورية عبر Firebase

## الاستخدام من Flutter

```dart
// مثال على استدعاء الدالة من Flutter
final response = await supabase.functions.invoke(
  'notification-analytics',
  body: {
    'action': 'send_bulk',
    'title': 'إشعار مهم',
    'body': 'هذا إشعار مهم لجميع المستخدمين',
    'target_type': 'all',
    'priority': 'high'
  }
);
```

## ملاحظات مهمة

1. يتم حفظ جميع الإشعارات في قاعدة البيانات حتى لو فشل الإرسال الفوري
2. نظام الجدولة يحتاج إلى تطبيق cron job للتنفيذ الفعلي
3. دعم FCM جاهز ولكن يحتاج إعداد Firebase Admin SDK
4. جميع التواريخ تستخدم تنسيق ISO 8601
5. يدعم النظام البحث النصي في العناوين والمحتوى