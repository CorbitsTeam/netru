#!/bin/bash

# Netru App Project Cleanup Script
# تاريخ: 12 سبتمبر 2025

echo "🧹 بدء تنظيف مشروع Netru App..."

# الانتقال لمجلد المشروع
PROJECT_DIR="/Users/ayman/StudioProjects/netru_app"
cd "$PROJECT_DIR" || exit 1

echo "📁 المجلد الحالي: $(pwd)"

# إنشاء backup قبل التنظيف
echo "💾 إنشاء backup..."
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "../$BACKUP_DIR"

# نسخ الملفات المهمة للbackup
cp -r lib "../$BACKUP_DIR/"
cp pubspec.yaml "../$BACKUP_DIR/"
cp analysis_options.yaml "../$BACKUP_DIR/"

echo "✅ تم إنشاء backup في: ../$BACKUP_DIR"

# تنظيف ملفات build و cache
echo "🗄️ تنظيف ملفات build..."
flutter clean

echo "🧹 حذف ملفات .disabled..."
find . -name "*.disabled" -type f -delete

echo "📱 حذف ملفات iOS/Android المؤقتة..."
# حذف ملفات Pods القديمة
rm -rf ios/Pods/
rm -rf ios/.symlinks/

# حذف ملفات Android build
rm -rf android/.gradle/
rm -rf android/app/.cxx/

echo "🔍 البحث عن ملفات Assets غير المستخدمة..."

# قائمة بالصور المحتمل عدم استخدامها
UNUSED_ASSETS=()

# فحص ملفات الصور
for img in assets/images/*.{png,jpg,jpeg,gif}; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        # البحث عن استخدام الصورة في الكود
        if ! grep -r "$filename" lib/ >/dev/null 2>&1; then
            UNUSED_ASSETS+=("$img")
        fi
    fi
done

if [ ${#UNUSED_ASSETS[@]} -gt 0 ]; then
    echo "⚠️ الملفات التالية قد تكون غير مستخدمة:"
    printf '%s\n' "${UNUSED_ASSETS[@]}"
    
    read -p "هل تريد حذف هذه الملفات؟ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for asset in "${UNUSED_ASSETS[@]}"; do
            echo "🗑️ حذف: $asset"
            rm "$asset"
        done
    fi
else
    echo "✅ جميع ملفات Assets مستخدمة"
fi

# تنظيف dependencies
echo "📦 فحص dependencies..."
flutter pub get
flutter pub deps

# إنشاء تقرير التنظيف
echo "📊 إنشاء تقرير التنظيف..."
cat > "analysis/cleanup-log.txt" << EOF
تقرير تنظيف مشروع Netru App
التاريخ: $(date)
==================================

الملفات المحذوفة:
- ملفات .disabled: $(find . -name "*.disabled" 2>/dev/null | wc -l)
- ملفات build مؤقتة: تم تنظيفها
- ملفات iOS Pods: تم تنظيفها
- ملفات Android .gradle: تم تنظيفها

حالة Assets:
- ملفات محتملة غير مستخدمة: ${#UNUSED_ASSETS[@]}

حالة Dependencies:
- flutter pub get: منتهية
- المشروع جاهز للتطوير

الخطوات التالية:
1. اختبار build للمشروع
2. التأكد من عمل جميع الميزات
3. إضافة Unit Tests حسب الحاجة
EOF

echo "✅ تم إنشاء تقرير في: analysis/cleanup-log.txt"

# اختبار build للتأكد من سلامة المشروع
echo "🔨 اختبار build للمشروع..."
if flutter analyze --no-fatal-infos --no-fatal-warnings; then
    echo "✅ المشروع يمر بالتحليل بنجاح"
else
    echo "⚠️ هناك مشاكل في التحليل - راجع التقرير"
fi

echo ""
echo "🎉 انتهى تنظيف المشروع!"
echo "📁 Backup موجود في: ../$BACKUP_DIR"
echo "📊 راجع تقرير التنظيف في: analysis/cleanup-log.txt"
echo ""
echo "الخطوات التالية:"
echo "1. flutter run للاختبار"
echo "2. اختبار جميع الميزات الجديدة"
echo "3. إضافة Unit Tests حسب الحاجة"
