-- Sample news data for testing

-- First, insert categories (these already exist from your SQL file)
INSERT INTO "public"."news_categories" ("id", "name", "name_ar", "icon", "color", "is_active", "created_at") 
VALUES 
  (1, 'Security', 'أمن', 'security', '#FF5722', true, '2024-09-19 13:02:49.743333'),
  (2, 'Crime', 'جرائم', 'crime', '#F44336', true, '2024-09-19 13:02:49.743333'),
  (3, 'Operations', 'عمليات', 'operations', '#9C27B0', true, '2024-09-19 13:02:49.743333'),
  (4, 'Public Safety', 'السلامة العامة', 'safety', '#009688', true, '2024-09-19 13:02:49.743333')
ON CONFLICT (id) DO NOTHING;

-- Now insert sample news articles
INSERT INTO "public"."news_articles" 
("id", "title", "title_ar", "content_text", "content_text_ar", "summary", "image_url", "category_id", "status", "is_published", "is_featured", "view_count", "published_at", "created_at", "updated_at")
VALUES 
(
  'news-001', 
  'Security Operation in Cairo', 
  'عملية أمنية في القاهرة',
  'A major security operation was conducted in downtown Cairo to ensure public safety.',
  'تم تنفيذ عملية أمنية كبرى في وسط القاهرة لضمان السلامة العامة.',
  'Security forces conduct successful operation in Cairo',
  'https://example.com/image1.jpg',
  1,
  'published',
  true,
  true,
  150,
  '2024-09-19 10:00:00',
  '2024-09-19 09:00:00',
  '2024-09-19 09:30:00'
),
(
  'news-002',
  'Crime Prevention Campaign',
  'حملة منع الجريمة',
  'New crime prevention measures are being implemented across the city.',
  'يتم تنفيذ تدابير جديدة لمنع الجريمة في جميع أنحاء المدينة.',
  'City launches comprehensive crime prevention initiative',
  'https://example.com/image2.jpg',
  2,
  'published',
  true,
  true,
  89,
  '2024-09-19 08:00:00',
  '2024-09-19 07:00:00',
  '2024-09-19 07:30:00'
),
(
  'news-003',
  'Emergency Response Exercise',
  'تمرين الاستجابة للطوارئ',
  'Emergency services conducted a comprehensive response exercise.',
  'أجرت خدمات الطوارئ تمريناً شاملاً للاستجابة.',
  'Emergency services test response capabilities',
  'https://example.com/image3.jpg',
  3,
  'published',
  true,
  false,
  67,
  '2024-09-19 07:00:00',
  '2024-09-19 06:00:00',
  '2024-09-19 06:30:00'
),
(
  'news-004',
  'Public Safety Awareness Program',
  'برنامج التوعية بالسلامة العامة',
  'A new public safety awareness program has been launched.',
  'تم إطلاق برنامج جديد للتوعية بالسلامة العامة.',
  'New awareness program promotes public safety',
  'https://example.com/image4.jpg',
  4,
  'published',
  true,
  true,
  234,
  '2024-09-19 06:00:00',
  '2024-09-19 05:00:00',
  '2024-09-19 05:30:00'
),
(
  'news-005',
  'Community Policing Initiative',
  'مبادرة الشرطة المجتمعية',
  'Local police are implementing a new community policing approach.',
  'تنفذ الشرطة المحلية نهجاً جديداً للشرطة المجتمعية.',
  'Police strengthen community relations',
  'https://example.com/image5.jpg',
  1,
  'published',
  true,
  false,
  112,
  '2024-09-18 20:00:00',
  '2024-09-18 19:00:00',
  '2024-09-18 19:30:00'
)
ON CONFLICT (id) DO NOTHING;