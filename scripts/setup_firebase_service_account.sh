#!/bin/bash

# 🔐 سكريبت إعداد Firebase Service Account
# Firebase Service Account Setup Script

echo "🔐 إعداد Firebase Service Account لنظام الإشعارات..."
echo "🔐 Setting up Firebase Service Account for notification system..."

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
print_step "الخطوة 1: فحص المتطلبات الأساسية"
print_step "Step 1: Checking basic requirements"

# Check if Firebase CLI is installed
if command -v firebase &> /dev/null; then
    print_success "Firebase CLI متوفر"
    firebase --version
else
    print_warning "Firebase CLI غير مثبت"
    echo "لتثبيته: npm install -g firebase-tools"
    echo "To install: npm install -g firebase-tools"
fi

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "يجب تشغيل السكريبت من المجلد الرئيسي للمشروع"
    print_error "Please run this script from the project root directory"
    exit 1
fi

echo ""
print_step "الخطوة 2: إعداد Firebase Service Account"
print_step "Step 2: Setting up Firebase Service Account"

echo ""
echo "🔐 لإعداد Firebase Service Account، اتبع هذه الخطوات:"
echo "🔐 To setup Firebase Service Account, follow these steps:"
echo ""
echo "1. اذهب إلى Firebase Console:"
echo "   Go to Firebase Console:"
echo "   https://console.firebase.google.com"
echo ""
echo "2. اختر مشروع Netru"
echo "   Select your Netru project"
echo ""
echo "3. اذهب إلى Project Settings (⚙️)"
echo "   Go to Project Settings (⚙️)"
echo ""
echo "4. اختر تبويب Service accounts"
echo "   Select Service accounts tab"
echo ""
echo "5. اضغط على 'Generate new private key'"
echo "   Click 'Generate new private key'"
echo ""
echo "6. احفظ الملف باسم: firebase-service-account.json"
echo "   Save the file as: firebase-service-account.json"
echo ""

echo ""
print_step "الخطوة 3: إضافة Service Account إلى المشروع"
print_step "Step 3: Adding Service Account to project"

SERVICE_ACCOUNT_FILE="firebase-service-account.json"

if [ -f "$SERVICE_ACCOUNT_FILE" ]; then
    print_success "Service Account file found: $SERVICE_ACCOUNT_FILE"
    
    # Extract project ID from service account file
    PROJECT_ID=$(cat $SERVICE_ACCOUNT_FILE | grep '"project_id"' | sed 's/.*"project_id": *"\([^"]*\)".*/\1/')
    
    if [ ! -z "$PROJECT_ID" ]; then
        print_success "Project ID found: $PROJECT_ID"
        
        # Update .env file
        echo "🔧 تحديث ملف .env..."
        echo "🔧 Updating .env file..."
        
        # Read the JSON file and escape it for .env
        SERVICE_ACCOUNT_JSON=$(cat $SERVICE_ACCOUNT_FILE | tr -d '\n' | sed 's/"/\\"/g')
        
        # Update supabase/.env
        if [ -f "supabase/.env" ]; then
            # Remove old entries
            sed -i.bak '/FIREBASE_PROJECT_ID=/d' supabase/.env
            sed -i.bak '/FIREBASE_SERVICE_ACCOUNT=/d' supabase/.env
            
            # Add new entries
            echo "FIREBASE_PROJECT_ID=$PROJECT_ID" >> supabase/.env
            echo "FIREBASE_SERVICE_ACCOUNT=$SERVICE_ACCOUNT_JSON" >> supabase/.env
            
            print_success "تم تحديث supabase/.env بنجاح"
            print_success "supabase/.env updated successfully"
        else
            print_warning "ملف supabase/.env غير موجود"
            print_warning "supabase/.env file not found"
        fi
        
        # Update Flutter service
        print_step "تحديث Flutter notification service..."
        print_step "Updating Flutter notification service..."
        
        FLUTTER_SERVICE_FILE="lib/core/services/flutter_notification_service.dart"
        if [ -f "$FLUTTER_SERVICE_FILE" ]; then
            # Replace project ID placeholder
            sed -i.bak "s/your_project_id_here/$PROJECT_ID/g" "$FLUTTER_SERVICE_FILE"
            print_success "تم تحديث Flutter service"
            print_success "Flutter service updated"
        fi
        
    else
        print_error "لم يتم العثور على project_id في الملف"
        print_error "project_id not found in the file"
    fi
    
else
    print_warning "ملف Service Account غير موجود: $SERVICE_ACCOUNT_FILE"
    print_warning "Service Account file not found: $SERVICE_ACCOUNT_FILE"
    echo ""
    echo "📥 يرجى تحميل الملف من Firebase Console ووضعه في:"
    echo "📥 Please download the file from Firebase Console and place it in:"
    echo "   $(pwd)/$SERVICE_ACCOUNT_FILE"
fi

echo ""
print_step "الخطوة 4: تحديث pubspec.yaml dependencies"
print_step "Step 4: Updating pubspec.yaml dependencies"

# Check if googleapis_auth is in pubspec.yaml
if grep -q "googleapis_auth:" pubspec.yaml; then
    print_success "googleapis_auth dependency موجود"
    print_success "googleapis_auth dependency exists"
else
    print_warning "googleapis_auth dependency مفقود"
    print_warning "googleapis_auth dependency missing"
    echo ""
    echo "أضف هذا إلى pubspec.yaml تحت dependencies:"
    echo "Add this to pubspec.yaml under dependencies:"
    echo "  googleapis_auth: ^1.4.1"
fi

echo ""
print_step "الخطوة 5: نشر Edge Function"
print_step "Step 5: Deploying Edge Function"

if command -v supabase &> /dev/null; then
    if curl -s http://127.0.0.1:54321 &> /dev/null; then
        print_success "Supabase يعمل محلياً"
        print_success "Supabase is running locally"
        
        echo "🚀 نشر Edge Function..."
        echo "🚀 Deploying Edge Function..."
        
        supabase functions deploy send-fcm-notification --no-verify-jwt
        
        if [ $? -eq 0 ]; then
            print_success "تم نشر Edge Function بنجاح"
            print_success "Edge Function deployed successfully"
        else
            print_error "فشل في نشر Edge Function"
            print_error "Failed to deploy Edge Function"
        fi
    else
        print_warning "Supabase غير نشط - شغله بـ: supabase start"
        print_warning "Supabase not running - start it with: supabase start"
    fi
else
    print_warning "Supabase CLI غير مثبت"
    print_warning "Supabase CLI not installed"
fi

echo ""
print_step "ملخص الإعداد / Setup Summary"
echo "=================================="

echo ""
echo "📋 ما تم إعداده:"
echo "📋 What was configured:"
echo ""

if [ -f "$SERVICE_ACCOUNT_FILE" ]; then
    echo "✅ Firebase Service Account"
    echo "✅ Project ID: $PROJECT_ID"
    echo "✅ Environment variables updated"
else
    echo "❌ Firebase Service Account (يحتاج إعداد)"
    echo "❌ Firebase Service Account (needs setup)"
fi

echo ""
echo "📝 الخطوات التالية:"
echo "📝 Next steps:"
echo ""
echo "1. 🔧 تأكد من تحديث pubspec.yaml وتشغيل:"
echo "   Make sure to update pubspec.yaml and run:"
echo "   flutter pub get"
echo ""
echo "2. 🚀 اختبر النظام:"
echo "   Test the system:"
echo "   ./scripts/test_notifications.sh"
echo ""
echo "3. 📱 اختبر من التطبيق:"
echo "   Test from the app:"
echo "   - Update a report status"
echo "   - Check if notification is sent"
echo ""

echo "🎉 انتهى إعداد Firebase Service Account!"
echo "🎉 Firebase Service Account setup complete!"

# Cleanup backup files
rm -f supabase/.env.bak
rm -f lib/core/services/flutter_notification_service.dart.bak