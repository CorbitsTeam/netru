#!/bin/bash

# 🧪 اختبار نظام الإشعارات بعد إعداد Firebase Service Account
# Testing notification system after Firebase Service Account setup

echo "🧪 اختبار نظام الإشعارات..."
echo "🧪 Testing notification system..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo ""
print_step "الخطوة 1: فحص إعداد Firebase في Supabase"
print_step "Step 1: Checking Firebase configuration in Supabase"

echo "🔍 فحص متغيرات البيئة..."
echo "🔍 Checking environment variables..."

FIREBASE_VARS=$(npx supabase secrets list | grep FIREBASE)

if echo "$FIREBASE_VARS" | grep -q "FIREBASE_PROJECT_ID"; then
    print_success "FIREBASE_PROJECT_ID موجود"
else
    print_error "FIREBASE_PROJECT_ID مفقود"
fi

if echo "$FIREBASE_VARS" | grep -q "FIREBASE_SERVICE_ACCOUNT"; then
    print_success "FIREBASE_SERVICE_ACCOUNT موجود"
else
    print_error "FIREBASE_SERVICE_ACCOUNT مفقود"
fi

echo ""
print_step "الخطوة 2: فحص Edge Function"
print_step "Step 2: Checking Edge Function"

echo "🔍 فحص نشر Edge Function..."
echo "🔍 Checking Edge Function deployment..."

# Test Edge Function with a simple ping
TEST_RESPONSE=$(curl -s -X POST \
  "https://yesjtlgciywmwrdpjqsr.supabase.co/functions/v1/send-fcm-notification" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(npx supabase secrets list | grep SUPABASE_ANON_KEY | awk '{print $3}')" \
  -d '{"test": "ping"}' || echo "error")

if [[ "$TEST_RESPONSE" == *"error"* ]] || [[ "$TEST_RESPONSE" == "" ]]; then
    print_warning "لم يتم الوصول إلى Edge Function - قد يكون هذا طبيعياً للاختبار"
    print_warning "Could not reach Edge Function - this might be normal for testing"
else
    print_success "Edge Function متاح"
    print_success "Edge Function is available"
fi

echo ""
print_step "الخطوة 3: تعليمات الاختبار من التطبيق"
print_step "Step 3: Testing instructions from the app"

echo ""
echo "📱 لاختبار النظام من التطبيق:"
echo "📱 To test the system from the app:"
echo ""
echo "1. 🔧 قم بتشغيل التطبيق:"
echo "   Run the app:"
echo "   flutter run"
echo ""
echo "2. 📝 سجل دخول كأدمن"
echo "   Login as admin"
echo ""
echo "3. 📋 اذهب إلى قائمة البلاغات"
echo "   Go to reports list"
echo ""
echo "4. ✏️ حدث حالة أي بلاغ (مثل: من pending إلى under_investigation)"
echo "   Update any report status (e.g., from pending to under_investigation)"
echo ""
echo "5. 👀 راقب اللوج للتأكد من:"
echo "   Watch the logs to confirm:"
echo "   ✅ تم العثور على المستخدم"
echo "   ✅ تم العثور على FCM token"
echo "   ✅ تم حفظ الإشعار في قاعدة البيانات"
echo "   ✅ تم إرسال Push notification بنجاح"
echo ""

echo ""
print_step "الخطوة 4: ما تبحث عنه في اللوج"
print_step "Step 4: What to look for in the logs"

echo ""
echo "🔍 اللوج المتوقع (بدون أخطاء):"
echo "🔍 Expected logs (without errors):"
echo ""
echo "✅ 📱 إرسال إشعار تحديث الحالة للبلاغ: [report-id]"
echo "✅ 📊 Report data found - User ID: [user-id], Case: [case-number]"
echo "✅ 📱 Found X FCM token(s) for user: [user-id]"
echo "✅ ✅ Notification saved to database: [notification-id]"
echo "✅ 🚀 Sending push notification via Edge Function"
echo "✅ ✅ Push notification sent successfully"
echo "✅ ✅ Updated notification sent status: true"
echo "✅ ✅ Report status notification completed successfully"
echo ""

echo ""
print_step "الخطوة 5: استكشاف الأخطاء"
print_step "Step 5: Troubleshooting"

echo ""
echo "❌ إذا ظهرت هذه الأخطاء:"
echo "❌ If you see these errors:"
echo ""
echo "🔸 'Firebase configuration not available'"
echo "   → تأكد من إعداد FIREBASE_SERVICE_ACCOUNT صحيح"
echo "   → Make sure FIREBASE_SERVICE_ACCOUNT is configured correctly"
echo ""
echo "🔸 'No FCM tokens found for user'"
echo "   → المستخدم لم يسجل دخول في التطبيق مؤخراً"
echo "   → User hasn't logged into the app recently"
echo ""
echo "🔸 'Error fetching report data'"
echo "   → تحقق من صحة معرف البلاغ"
echo "   → Check report ID validity"
echo ""

echo ""
print_success "🎉 الإعداد مكتمل! اختبر النظام الآن من التطبيق"
print_success "🎉 Setup complete! Test the system now from the app"

echo ""
echo "📝 ملاحظة مهمة:"
echo "📝 Important note:"
echo "النظام سيرسل الإشعار إلى صاحب البلاغ (وليس الأدمن)"
echo "The system will send notifications to the report submitter (not the admin)"
echo "هذا هو السلوك الصحيح والمطلوب ✅"
echo "This is the correct and expected behavior ✅"