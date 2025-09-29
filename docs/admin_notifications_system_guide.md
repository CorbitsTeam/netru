# دليل نظام إدارة الإشعارات الشامل

## نظرة عامة
نظام إدارة الإشعارات الشامل مع دعم FCM وقاعدة البيانات. يوفر واجهة برمجة تطبيقات كاملة للإدارة.

## متطلبات النظام

### متغيرات البيئة المطلوبة:
```bash
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your_service_account_email
```

### قاعدة البيانات:
- جدول `notifications` - تخزين الإشعارات
- جدول `user_fcm_tokens` - رموز FCM للمستخدمين
- جدول `users` - بيانات المستخدمين
- جدول `user_logs` - سجل أعمال الإدارة

## الوظائف المتاحة

### 1. عرض الإشعارات (GET)
```
GET /functions/v1/admin-notifications?action=get_notifications
```

**المعاملات:**
- `page`: رقم الصفحة (افتراضي: 1)
- `limit`: عدد العناصر (افتراضي: 20)
- `type`: نوع الإشعار (news, report_update, system, etc.)
- `search`: نص البحث في العنوان والمحتوى
- `user_id`: معرف مستخدم محدد
- `status`: حالة الإشعار (read, unread, sent)

**مثال على الاستجابة:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "title": "عنوان الإشعار",
      "body": "محتوى الإشعار",
      "notification_type": "general",
      "is_read": false,
      "fcm_message_id": "fcm_id",
      "created_at": "2024-01-01T00:00:00Z",
      "users": {
        "id": "uuid",
        "full_name": "اسم المستخدم",
        "email": "email@example.com",
        "user_type": "user"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5,
    "hasMore": true
  }
}
```

### 2. إنشاء إشعار فردي (POST)
```
POST /functions/v1/admin-notifications?action=create_notification
```

**البيانات المطلوبة:**
```json
{
  "user_id": "uuid",
  "title": "عنوان الإشعار",
  "body": "محتوى الإشعار",
  "notification_type": "general",
  "reference_id": "optional_reference",
  "reference_type": "optional_type",
  "data": {
    "custom_field": "value"
  }
}
```

**مثال على الاستجابة:**
```json
{
  "success": true,
  "message": "تم إنشاء الإشعار بنجاح",
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    "title": "عنوان الإشعار",
    "body": "محتوى الإشعار",
    "fcm_message_id": "fcm_message_id"
  },
  "fcm_result": {
    "success": true,
    "successCount": 1,
    "failureCount": 0,
    "errors": []
  }
}
```

### 3. إرسال إشعار جماعي (POST)
```
POST /functions/v1/admin-notifications?action=send_bulk
```

**البيانات المطلوبة:**
```json
{
  "title": "عنوان الإشعار الجماعي",
  "body": "محتوى الإشعار",
  "notification_type": "general",
  "target_type": "all", // "all", "user_type", "specific_users"
  "target_value": null, // للنوع "all"
  "data": {
    "custom_field": "value"
  }
}
```

**أنواع الاستهداف:**

#### إرسال لجميع المستخدمين:
```json
{
  "target_type": "all",
  "target_value": null
}
```

#### إرسال لنوع مستخدم محدد:
```json
{
  "target_type": "user_type",
  "target_value": "admin" // أو "user", "moderator", إلخ
}
```

#### إرسال لمستخدمين محددين:
```json
{
  "target_type": "specific_users",
  "target_value": ["uuid1", "uuid2", "uuid3"]
}
```

**مثال على الاستجابة:**
```json
{
  "success": true,
  "message": "تم إرسال 150 إشعار بنجاح",
  "data": {
    "notifications_created": 150,
    "target_users": 150,
    "fcm_result": {
      "success": true,
      "successCount": 145,
      "failureCount": 5,
      "errors": ["error details..."]
    }
  }
}
```

### 4. عرض الإحصائيات (GET)
```
GET /functions/v1/admin-notifications?action=get_stats
```

**مثال على الاستجابة:**
```json
{
  "success": true,
  "data": {
    "total_notifications": 1500,
    "read_notifications": 1200,
    "fcm_sent_notifications": 1400,
    "recent_notifications": 50,
    "open_rate": "80.00",
    "fcm_delivery_rate": "93.33",
    "notifications_by_type": {
      "general": 800,
      "news": 300,
      "report_update": 200,
      "system": 200
    }
  }
}
```

### 5. حذف إشعار (DELETE)
```
DELETE /functions/v1/admin-notifications?action=delete_notification&notification_id=uuid
```

### 6. تحديد إشعار كمقروء (POST)
```
POST /functions/v1/admin-notifications?action=mark_read
```

**البيانات:**
```json
{
  "notification_id": "uuid"
}
```

## المصادقة
جميع الطلبات تتطلب مصادقة Admin:

```javascript
headers: {
  'Authorization': 'Bearer YOUR_JWT_TOKEN',
  'Content-Type': 'application/json'
}
```

## أمثلة الاستخدام من Flutter

### 1. عرض الإشعارات:
```dart
final response = await supabase.functions.invoke(
  'admin-notifications',
  queryParameters: {
    'action': 'get_notifications',
    'page': '1',
    'limit': '20',
    'type': 'general'
  }
);
```

### 2. إنشاء إشعار فردي:
```dart
final response = await supabase.functions.invoke(
  'admin-notifications',
  queryParameters: {'action': 'create_notification'},
  body: {
    'user_id': 'user-uuid',
    'title': 'إشعار مهم',
    'body': 'تفاصيل الإشعار هنا',
    'notification_type': 'system'
  }
);
```

### 3. إرسال إشعار لجميع المستخدمين:
```dart
final response = await supabase.functions.invoke(
  'admin-notifications',
  queryParameters: {'action': 'send_bulk'},
  body: {
    'title': 'إعلان عام',
    'body': 'هذا إعلان لجميع المستخدمين',
    'target_type': 'all',
    'notification_type': 'general'
  }
);
```

### 4. إرسال إشعار لمجموعة محددة:
```dart
final response = await supabase.functions.invoke(
  'admin-notifications',
  queryParameters: {'action': 'send_bulk'},
  body: {
    'title': 'إشعار للإداريين',
    'body': 'هذا إشعار خاص بالإداريين فقط',
    'target_type': 'user_type',
    'target_value': 'admin',
    'notification_type': 'system'
  }
);
```

## ميزات النظام

### 🔐 الأمان:
- مصادقة Admin فقط
- فحص نوع المستخدم والحالة النشطة
- تسجيل جميع العمليات في user_logs

### 📱 FCM Integration:
- إرسال فوري عبر Firebase Cloud Messaging
- دعم Android و iOS
- تخزين message_id في قاعدة البيانات
- معالجة الأخطاء وإعادة المحاولة

### 📊 التحليلات:
- إحصائيات شاملة للإشعارات
- معدلات الفتح والتسليم
- توزيع حسب النوع
- الإشعارات الحديثة

### 🔍 البحث والفلترة:
- بحث في العنوان والمحتوى
- فلترة حسب النوع والحالة
- فلترة حسب المستخدم
- ترقيم الصفحات

### 📝 التسجيل:
- تسجيل جميع عمليات الإدارة
- تفاصيل العمليات والمعاملات
- تتبع النجاح والفشل

## معالجة الأخطاء
النظام يتعامل مع الأخطاء بشكل احترافي ويعيد رسائل واضحة:

```json
{
  "success": false,
  "error": "وصف الخطأ باللغة المناسبة"
}
```

## حدود النظام
- الحد الأقصى للإشعارات الجماعية: لا يوجد حد (معالجة بالدفعات)
- معدل الطلبات: حسب حدود Supabase Edge Functions
- حجم البيانات: حسب حدود JSON payload

## نصائح للأداء
1. استخدم الترقيم للبيانات الكبيرة
2. استخدم الفلترة لتقليل البيانات المُعادة
3. راقب إحصائيات FCM للتأكد من التسليم
4. نظف الإشعارات القديمة دورياً

هذا النظام يوفر حلاً شاملاً لإدارة الإشعارات مع دعم كامل لـ FCM وقاعدة البيانات.