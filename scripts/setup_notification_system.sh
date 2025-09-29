#!/bin/bash

#!/bin/bash

# � سكريبت إعداد نظام الإشعارات في Netru App
# Setup script for notification system in Netru App

echo "� بدء إعداد نظام الإشعارات..."
echo "🚀 Starting notification system setup..."

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ خطأ: يجب تشغيل السكريبت من المجلد الرئيسي للمشروع"
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

echo ""
echo "📋 الخطوة 1: التحقق من ملفات المشروع..."
echo "📋 Step 1: Checking project files..."

# 1. نشر Edge Function
echo "📤 نشر Edge Function..."
if command -v supabase &> /dev/null; then
    supabase functions deploy send-fcm-notification
    echo "✅ تم نشر Edge Function بنجاح"
else
    echo "⚠️ Supabase CLI غير مثبت. يرجى تثبيته أولاً"
    echo "npm install -g supabase"
fi

# 2. تذكير بإعداد متغيرات البيئة
echo ""
echo "🔐 تذكير: تأكد من إعداد متغيرات البيئة التالية:"
echo "supabase secrets set FCM_SERVER_KEY=your-fcm-server-key"

# 3. فحص الملفات المطلوبة
echo ""
echo "📋 فحص الملفات المطلوبة..."

files=(
    "supabase/functions/send-fcm-notification/index.ts"
    "lib/core/services/report_notification_service.dart"
    "lib/core/demos/notification_system_demo.dart"
    "test/notification_system_integration_test.dart"
    "docs/notification_system_guide.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file موجود"
    else
        echo "❌ $file مفقود"
    fi
done

# 4. تشغيل اختبارات Flutter
echo ""
echo "🧪 تشغيل اختبارات Flutter..."
if command -v flutter &> /dev/null; then
    flutter test test/notification_system_integration_test.dart
    echo "✅ تم تشغيل الاختبارات"
else
    echo "⚠️ Flutter غير مثبت أو غير متاح في PATH"
fi

# 5. إرشادات الاستخدام
echo ""
echo "📖 === إرشادات الاستخدام ==="
echo ""
echo "1. لاختبار النظام في التطبيق:"
echo "   import 'package:netru_app/core/demos/notification_system_demo.dart';"
echo "   NotificationSystemDemo.runFullTest();"
echo ""
echo "2. لإرسال إشعار عند تحديث حالة البلاغ:"
echo "   final service = ReportNotificationService();"
echo "   await service.sendReportStatusNotification(...);"
echo ""
echo "3. مراجعة الدليل التقني الكامل:"
echo "   docs/notification_system_guide.md"
echo ""
echo "4. اختبار Edge Function مباشرة:"
echo "   curl -X POST 'https://your-project.supabase.co/functions/v1/send-fcm-notification' \\"
echo "     -H 'Authorization: Bearer YOUR_ANON_KEY' \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"fcm_token\":\"test\",\"title\":\"اختبار\",\"body\":\"رسالة اختبار\"}'"
echo ""
echo "✅ === انتهى إعداد نظام الإشعارات ==="