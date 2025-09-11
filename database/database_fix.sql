-- تحديث جداول قاعدة البيانات لإصلاح مشاكل المصادقة

-- إضافة عمود user_type إلى جدول المواطنين إذا لم يكن موجوداً
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='citizens' AND column_name='user_type') THEN
        ALTER TABLE citizens ADD COLUMN user_type TEXT DEFAULT 'citizen';
    END IF;
END $$;

-- إضافة عمود user_type إلى جدول الأجانب إذا لم يكن موجوداً
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='foreigners' AND column_name='user_type') THEN
        ALTER TABLE foreigners ADD COLUMN user_type TEXT DEFAULT 'foreigner';
    END IF;
END $$;

-- تحديث البيانات الموجودة
UPDATE citizens SET user_type = 'citizen' WHERE user_type IS NULL;
UPDATE foreigners SET user_type = 'foreigner' WHERE user_type IS NULL;

-- التأكد من وجود فهارس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_citizens_national_id ON citizens(national_id);
CREATE INDEX IF NOT EXISTS idx_citizens_user_id ON citizens(user_id);
CREATE INDEX IF NOT EXISTS idx_foreigners_passport_number ON foreigners(passport_number);
CREATE INDEX IF NOT EXISTS idx_foreigners_user_id ON foreigners(user_id);

-- التأكد من وجود قيود البيانات
ALTER TABLE citizens 
ADD CONSTRAINT IF NOT EXISTS chk_national_id_format 
CHECK (national_id ~ '^[0-9]{14}$');

-- إضافة تعليقات للجداول
COMMENT ON TABLE citizens IS 'جدول بيانات المواطنين المصريين';
COMMENT ON TABLE foreigners IS 'جدول بيانات الأجانب';
COMMENT ON COLUMN citizens.user_type IS 'نوع المستخدم - دائماً citizen';
COMMENT ON COLUMN foreigners.user_type IS 'نوع المستخدم - دائماً foreigner';
