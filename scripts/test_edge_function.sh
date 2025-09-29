#!/bin/bash

# 🧪 اختبار Edge Function مباشرة
# Direct Edge Function test

echo "🧪 اختبار Edge Function للإشعارات..."
echo "🧪 Testing Edge Function for notifications..."

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

# Test Edge Function with a dummy token
echo ""
print_step "اختبار Edge Function مع بيانات تجريبية"
print_step "Testing Edge Function with dummy data"

DUMMY_FCM_TOKEN="test-token-123"
TEST_TITLE="🧪 اختبار الإشعارات"
TEST_BODY="هذا اختبار لنظام الإشعارات"

echo "🔄 إرسال طلب اختبار..."
echo "🔄 Sending test request..."

# Get project URL from Supabase
PROJECT_URL="https://yesjtlgciywmwrdpjqsr.supabase.co"
FUNCTION_URL="$PROJECT_URL/functions/v1/send-fcm-notification"

echo "📡 URL: $FUNCTION_URL"

# Get the actual anon key
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inllc2p0bGdjaXl3bXdyZHBqcXNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjcyNzc3NjQsImV4cCI6MjA0Mjg1Mzc2NH0.1DYP9rHOaGFXhaMpgBRJ9l3qhLEk3nUNY9b0FkKs9bM"

# Test with curl
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST \
  "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ANON_KEY" \
  -d "{
    \"fcm_token\": \"$DUMMY_FCM_TOKEN\",
    \"title\": \"$TEST_TITLE\",
    \"body\": \"$TEST_BODY\",
    \"data\": {
      \"test\": true,
      \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
    }
  }")

# Extract HTTP status
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1 | sed 's/.*HTTP_STATUS://')
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo ""
echo "📊 النتيجة:"
echo "📊 Result:"
echo "HTTP Status: $HTTP_STATUS"
echo "Response: $RESPONSE_BODY"

if [ "$HTTP_STATUS" = "200" ]; then
    if echo "$RESPONSE_BODY" | grep -q '"success":true'; then
        print_success "Edge Function يعمل بنجاح!"
        print_success "Edge Function works successfully!"
    else
        print_warning "Edge Function يستجيب لكن قد تكون هناك مشكلة في الإعداد"
        print_warning "Edge Function responds but there might be a configuration issue"
    fi
elif [ "$HTTP_STATUS" = "500" ]; then
    print_error "خطأ في الخادم - مشكلة في Firebase Service Account"
    print_error "Server error - Firebase Service Account issue"
    
    if echo "$RESPONSE_BODY" | grep -q "Failed to obtain access token"; then
        echo ""
        echo "🔍 التشخيص:"
        echo "🔍 Diagnosis:"
        echo "المشكلة في Firebase Service Account JSON"
        echo "Issue with Firebase Service Account JSON"
        echo ""
        echo "الحلول المقترحة:"
        echo "Suggested solutions:"
        echo "1. تأكد من صحة private_key في Service Account"
        echo "   Make sure private_key in Service Account is valid"
        echo "2. تأكد من أن JSON مُنسق بشكل صحيح"
        echo "   Make sure JSON is properly formatted"
        echo "3. جرب إنشاء Service Account جديد"
        echo "   Try creating a new Service Account"
    fi
else
    print_error "فشل في الوصول إلى Edge Function"
    print_error "Failed to reach Edge Function"
fi

echo ""
print_step "الخطوات التالية:"
print_step "Next steps:"

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Edge Function يعمل - اختبر من التطبيق الآن"
    echo "✅ Edge Function works - test from the app now"
else
    echo "❌ يحتاج إصلاح Firebase Service Account"
    echo "❌ Need to fix Firebase Service Account"
    echo ""
    echo "📝 تحقق من:"
    echo "📝 Check:"
    echo "1. FIREBASE_SERVICE_ACCOUNT في Supabase secrets"
    echo "2. صحة private_key في JSON"
    echo "3. صحة client_email في JSON"
fi

echo ""
echo "🔍 للمزيد من التشخيص، راقب Supabase Functions logs:"
echo "🔍 For more diagnosis, monitor Supabase Functions logs:"
echo "https://supabase.com/dashboard/project/yesjtlgciywmwrdpjqsr/functions"