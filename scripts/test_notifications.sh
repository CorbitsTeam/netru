#!/bin/bash

# 🧪 Test Notification System - اختبار نظام الإشعارات

echo "🧪 اختبار نظام الإشعارات..."
echo "🧪 Testing notification system..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ "$2" = "success" ]; then
        echo -e "${GREEN}✅ $1${NC}"
    elif [ "$2" = "warning" ]; then
        echo -e "${YELLOW}⚠️  $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
    fi
}

echo ""
echo "🔍 فحص المتطلبات الأساسية..."
echo "🔍 Checking basic requirements..."

# Check if supabase is running
if curl -s http://127.0.0.1:54321 &> /dev/null; then
    print_status "Supabase يعمل على المنفذ 54321" "success"
else
    print_status "Supabase غير نشط - يرجى تشغيله بـ: supabase start" "error"
    exit 1
fi

# Check if Edge Function exists
if [ -f "supabase/functions/send-fcm-notification/index.ts" ]; then
    print_status "Edge Function موجود" "success"
else
    print_status "Edge Function غير موجود" "error"
    exit 1
fi

# Check .env file
if [ -f "supabase/.env" ]; then
    if grep -q "FIREBASE_PROJECT_ID=your_firebase_project_id_here" supabase/.env; then
        print_status "FIREBASE_PROJECT_ID يحتاج تحديث في supabase/.env" "warning"
        echo "   احصل على Project ID من Firebase Console → Project Settings → General"
    elif grep -q "FIREBASE_SERVICE_ACCOUNT=" supabase/.env; then
        print_status "Firebase v1 API محدّث في supabase/.env" "success"
    else
        print_status "Firebase configuration غير مكتمل" "warning"
    fi
else
    print_status "ملف supabase/.env غير موجود" "error"
    exit 1
fi

echo ""
echo "🚀 اختبار Edge Function..."
echo "🚀 Testing Edge Function..."

# Get Supabase anon key (you'll need to replace this)
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

# Test Edge Function with sample data
RESPONSE=$(curl -s -X POST "http://127.0.0.1:54321/functions/v1/send-fcm-notification" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ANON_KEY" \
  -d '{
    "fcm_token": "test_token_12345",
    "title": "اختبار النظام",
    "body": "هذا اختبار لنظام الإشعارات"
  }')

echo "📋 استجابة Edge Function:"
echo "$RESPONSE"

# Check response
if echo "$RESPONSE" | grep -q '"success":false'; then
    if echo "$RESPONSE" | grep -q "Firebase configuration not available"; then
        print_status "Firebase Service Account غير محدد - شغل سكريبت الإعداد" "error"
        echo ""
        echo "📝 خطوات الإصلاح:"
        echo "1. شغل: ./scripts/setup_firebase_service_account.sh"
        echo "2. تأكد من وجود firebase-service-account.json"
        echo "3. أعد نشر Edge Function:"
        echo "   supabase functions deploy send-fcm-notification --no-verify-jwt"
    else
        print_status "خطأ آخر في Edge Function" "error"
    fi
elif echo "$RESPONSE" | grep -q '"success":true'; then
    print_status "Edge Function يعمل بشكل صحيح مع Firebase v1 API!" "success"
elif echo "$RESPONSE" | grep -q "HTML"; then
    print_status "Edge Function يُرجع HTML بدلاً من JSON - يحتاج إعادة نشر" "error"
else
    print_status "استجابة غير متوقعة من Edge Function" "warning"
fi

echo ""
echo "📊 فحص قاعدة البيانات..."
echo "📊 Checking database..."

# Check database tables (this would require psql or supabase CLI)
echo "📋 للتحقق من الجداول المطلوبة:"
echo "📋 To check required tables:"
echo "   supabase db inspect"

echo ""
echo "📱 فحص Firebase Configuration..."
echo "📱 Checking Firebase Configuration..."

if [ -f "android/app/google-services.json" ]; then
    print_status "google-services.json موجود للـ Android" "success"
else
    print_status "google-services.json مفقود للـ Android" "warning"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_status "GoogleService-Info.plist موجود للـ iOS" "success"
else
    print_status "GoogleService-Info.plist مفقود للـ iOS" "warning"
fi

echo ""
echo "🎯 ملخص الاختبار / Test Summary:"
echo "=================================="
echo ""
echo "المطلوب لإصلاح نظام الإشعارات (Firebase v1 API):"
echo "Required to fix notification system (Firebase v1 API):"
echo ""
echo "1. � إعداد Firebase Service Account:"
echo "   ./scripts/setup_firebase_service_account.sh"
echo "2. � تحديث dependencies:"
echo "   flutter pub get"
echo "3. � إعادة نشر Edge Function"
echo "4. 🧪 اختبار النظام من التطبيق"
echo ""
echo "📞 لمزيد من المساعدة، راجع: FIREBASE_V1_SETUP.md"