-- Database schema for news system

-- Create news_categories table if it doesn't exist
CREATE TABLE IF NOT EXISTS "public"."news_categories" (
    "id" integer NOT NULL,
    "name" varchar(255) NOT NULL,
    "name_ar" varchar(255),
    "description" text,
    "icon" varchar(255),
    "color" varchar(7),
    "is_active" boolean DEFAULT true,
    "display_order" integer DEFAULT 0,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

-- Create news_articles table if it doesn't exist
CREATE TABLE IF NOT EXISTS "public"."news_articles" (
    "id" varchar(255) NOT NULL,
    "title" varchar(500) NOT NULL,
    "title_ar" varchar(500),
    "content_text" text,
    "content_text_ar" text,
    "summary" text,
    "summary_en" text,
    "image_url" varchar(1000),
    "external_id" varchar(255),
    "external_url" varchar(1000),
    "source_url" varchar(1000),
    "source_name" varchar(255),
    "category_id" integer,
    "status" varchar(50) DEFAULT 'draft',
    "is_published" boolean DEFAULT false,
    "is_featured" boolean DEFAULT false,
    "view_count" integer DEFAULT 0,
    "published_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("category_id") REFERENCES "public"."news_categories"("id") ON DELETE SET NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_news_articles_category_id ON "public"."news_articles"("category_id");
CREATE INDEX IF NOT EXISTS idx_news_articles_published_at ON "public"."news_articles"("published_at");
CREATE INDEX IF NOT EXISTS idx_news_articles_is_published ON "public"."news_articles"("is_published");
CREATE INDEX IF NOT EXISTS idx_news_articles_is_featured ON "public"."news_articles"("is_featured");
CREATE INDEX IF NOT EXISTS idx_news_articles_status ON "public"."news_articles"("status");

-- Insert categories
INSERT INTO "public"."news_categories" ("id", "name", "name_ar", "icon", "color", "is_active", "created_at") 
VALUES 
  (1, 'Security', 'أمن', 'security', '#FF5722', true, CURRENT_TIMESTAMP),
  (2, 'Crime', 'جرائم', 'crime', '#F44336', true, CURRENT_TIMESTAMP),
  (3, 'Operations', 'عمليات', 'operations', '#9C27B0', true, CURRENT_TIMESTAMP),
  (4, 'Public Safety', 'السلامة العامة', 'safety', '#009688', true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  name_ar = EXCLUDED.name_ar,
  icon = EXCLUDED.icon,
  color = EXCLUDED.color,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

-- Insert sample news articles
INSERT INTO "public"."news_articles" 
("id", "title", "title_ar", "content_text", "content_text_ar", "summary", "image_url", "category_id", "status", "is_published", "is_featured", "view_count", "published_at", "created_at", "updated_at")
VALUES 
(
  'news-001', 
  'Security Operation in Cairo', 
  'عملية أمنية في القاهرة',
  'A major security operation was conducted in downtown Cairo to ensure public safety. The operation involved multiple security agencies working together to maintain order and protect citizens.',
  'تم تنفيذ عملية أمنية كبرى في وسط القاهرة لضمان السلامة العامة. شملت العملية وكالات أمنية متعددة تعمل معاً للحفاظ على النظام وحماية المواطنين.',
  'Security forces conduct successful operation in Cairo',
  'https://images.unsplash.com/photo-1590004953392-5aba2e72269a?w=500',
  1,
  'published',
  true,
  true,
  150,
  CURRENT_TIMESTAMP - INTERVAL '1 hour',
  CURRENT_TIMESTAMP - INTERVAL '2 hours',
  CURRENT_TIMESTAMP - INTERVAL '1 hour'
),
(
  'news-002',
  'Crime Prevention Campaign',
  'حملة منع الجريمة',
  'New crime prevention measures are being implemented across the city to reduce criminal activities and improve community safety.',
  'يتم تنفيذ تدابير جديدة لمنع الجريمة في جميع أنحاء المدينة لتقليل الأنشطة الإجرامية وتحسين سلامة المجتمع.',
  'City launches comprehensive crime prevention initiative',
  'https://images.unsplash.com/photo-1570829460005-c840387bb1ca?w=500',
  2,
  'published',
  true,
  true,
  89,
  CURRENT_TIMESTAMP - INTERVAL '2 hours',
  CURRENT_TIMESTAMP - INTERVAL '3 hours',
  CURRENT_TIMESTAMP - INTERVAL '2 hours'
),
(
  'news-003',
  'Emergency Response Exercise',
  'تمرين الاستجابة للطوارئ',
  'Emergency services conducted a comprehensive response exercise to test their preparedness for various emergency scenarios.',
  'أجرت خدمات الطوارئ تمريناً شاملاً للاستجابة لاختبار استعدادهم لسيناريوهات الطوارئ المختلفة.',
  'Emergency services test response capabilities',
  'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=500',
  3,
  'published',
  true,
  false,
  67,
  CURRENT_TIMESTAMP - INTERVAL '3 hours',
  CURRENT_TIMESTAMP - INTERVAL '4 hours',
  CURRENT_TIMESTAMP - INTERVAL '3 hours'
),
(
  'news-004',
  'Public Safety Awareness Program',
  'برنامج التوعية بالسلامة العامة',
  'A new public safety awareness program has been launched to educate citizens about safety measures and emergency procedures.',
  'تم إطلاق برنامج جديد للتوعية بالسلامة العامة لتثقيف المواطنين حول تدابير السلامة وإجراءات الطوارئ.',
  'New awareness program promotes public safety',
  'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=500',
  4,
  'published',
  true,
  true,
  234,
  CURRENT_TIMESTAMP - INTERVAL '4 hours',
  CURRENT_TIMESTAMP - INTERVAL '5 hours',
  CURRENT_TIMESTAMP - INTERVAL '4 hours'
),
(
  'news-005',
  'Community Policing Initiative',
  'مبادرة الشرطة المجتمعية',
  'Local police are implementing a new community policing approach to strengthen relationships with residents and improve neighborhood safety.',
  'تنفذ الشرطة المحلية نهجاً جديداً للشرطة المجتمعية لتعزيز العلاقات مع السكان وتحسين سلامة الأحياء.',
  'Police strengthen community relations',
  'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
  1,
  'published',
  true,
  false,
  112,
  CURRENT_TIMESTAMP - INTERVAL '5 hours',
  CURRENT_TIMESTAMP - INTERVAL '6 hours',
  CURRENT_TIMESTAMP - INTERVAL '5 hours'
),
(
  'news-006',
  'Traffic Safety Campaign',
  'حملة السلامة المرورية',
  'New traffic safety measures are being introduced to reduce accidents and improve road safety for all users.',
  'يتم تقديم تدابير جديدة للسلامة المرورية لتقليل الحوادث وتحسين سلامة الطرق لجميع المستخدمين.',
  'Enhanced traffic safety measures implemented',
  'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=500',
  4,
  'published',
  true,
  true,
  78,
  CURRENT_TIMESTAMP - INTERVAL '6 hours',
  CURRENT_TIMESTAMP - INTERVAL '7 hours',
  CURRENT_TIMESTAMP - INTERVAL '6 hours'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  title_ar = EXCLUDED.title_ar,
  content_text = EXCLUDED.content_text,
  content_text_ar = EXCLUDED.content_text_ar,
  summary = EXCLUDED.summary,
  image_url = EXCLUDED.image_url,
  category_id = EXCLUDED.category_id,
  status = EXCLUDED.status,
  is_published = EXCLUDED.is_published,
  is_featured = EXCLUDED.is_featured,
  updated_at = CURRENT_TIMESTAMP;