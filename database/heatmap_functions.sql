-- دوال SQL مفيدة للحصول على إحصائيات التقارير والخريطة الحرارية

-- 1. دالة للحصول على إحصائيات المحافظات
CREATE OR REPLACE FUNCTION get_governorate_stats()
RETURNS TABLE (
  governorate_name TEXT,
  report_count BIGINT,
  center_lat DECIMAL,
  center_lng DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.governorate,
    COUNT(r.id) as report_count,
    CASE u.governorate
      WHEN 'القاهرة' THEN 30.0444::DECIMAL
      WHEN 'الجيزة' THEN 30.0131::DECIMAL
      WHEN 'الإسكندرية' THEN 31.2001::DECIMAL
      WHEN 'الدقهلية' THEN 31.0409::DECIMAL
      WHEN 'البحر الأحمر' THEN 26.0667::DECIMAL
      WHEN 'البحيرة' THEN 30.8481::DECIMAL
      WHEN 'الفيوم' THEN 29.3084::DECIMAL
      WHEN 'الغربية' THEN 30.7618::DECIMAL
      WHEN 'الإسماعيلية' THEN 30.5965::DECIMAL
      WHEN 'المنوفية' THEN 30.5972::DECIMAL
      WHEN 'المنيا' THEN 28.0871::DECIMAL
      WHEN 'القليوبية' THEN 30.1792::DECIMAL
      WHEN 'الوادي الجديد' THEN 25.4519::DECIMAL
      WHEN 'شمال سيناء' THEN 30.2824::DECIMAL
      WHEN 'جنوب سيناء' THEN 28.4693::DECIMAL
      WHEN 'بورسعيد' THEN 31.2653::DECIMAL
      WHEN 'دمياط' THEN 31.8133::DECIMAL
      WHEN 'الشرقية' THEN 30.5965::DECIMAL
      WHEN 'كفر الشيخ' THEN 31.1107::DECIMAL
      WHEN 'مطروح' THEN 31.3543::DECIMAL
      WHEN 'أسوان' THEN 24.0889::DECIMAL
      WHEN 'أسيوط' THEN 27.1783::DECIMAL
      WHEN 'بني سويف' THEN 29.0661::DECIMAL
      WHEN 'سوهاج' THEN 26.5569::DECIMAL
      WHEN 'قنا' THEN 26.1551::DECIMAL
      WHEN 'الأقصر' THEN 25.6872::DECIMAL
      WHEN 'السويس' THEN 29.9668::DECIMAL
      ELSE 30.0444::DECIMAL
    END as center_lat,
    CASE u.governorate
      WHEN 'القاهرة' THEN 31.2357::DECIMAL
      WHEN 'الجيزة' THEN 31.2089::DECIMAL
      WHEN 'الإسكندرية' THEN 29.9187::DECIMAL
      WHEN 'الدقهلية' THEN 31.3785::DECIMAL
      WHEN 'البحر الأحمر' THEN 33.8116::DECIMAL
      WHEN 'البحيرة' THEN 30.3436::DECIMAL
      WHEN 'الفيوم' THEN 30.8428::DECIMAL
      WHEN 'الغربية' THEN 31.0335::DECIMAL
      WHEN 'الإسماعيلية' THEN 32.2715::DECIMAL
      WHEN 'المنوفية' THEN 31.0041::DECIMAL
      WHEN 'المنيا' THEN 30.7618::DECIMAL
      WHEN 'القليوبية' THEN 31.2421::DECIMAL
      WHEN 'الوادي الجديد' THEN 30.5467::DECIMAL
      WHEN 'شمال سيناء' THEN 33.6176::DECIMAL
      WHEN 'جنوب سيناء' THEN 33.9715::DECIMAL
      WHEN 'بورسعيد' THEN 32.3019::DECIMAL
      WHEN 'دمياط' THEN 31.8844::DECIMAL
      WHEN 'الشرقية' THEN 31.5041::DECIMAL
      WHEN 'كفر الشيخ' THEN 30.9388::DECIMAL
      WHEN 'مطروح' THEN 27.2373::DECIMAL
      WHEN 'أسوان' THEN 32.8998::DECIMAL
      WHEN 'أسيوط' THEN 31.1859::DECIMAL
      WHEN 'بني سويف' THEN 31.0994::DECIMAL
      WHEN 'سوهاج' THEN 31.6948::DECIMAL
      WHEN 'قنا' THEN 32.7160::DECIMAL
      WHEN 'الأقصر' THEN 32.6396::DECIMAL
      WHEN 'السويس' THEN 32.5498::DECIMAL
      ELSE 31.2357::DECIMAL
    END as center_lng
  FROM users u
  INNER JOIN reports r ON u.id = r.user_id
  WHERE u.governorate IS NOT NULL
  GROUP BY u.governorate
  ORDER BY report_count DESC;
END;
$$ LANGUAGE plpgsql;

-- 2. دالة للحصول على إحصائيات أنواع التقارير
CREATE OR REPLACE FUNCTION get_report_type_stats()
RETURNS TABLE (
  name TEXT,
  name_ar TEXT,
  count BIGINT,
  priority_level TEXT
) AS $$
BEGIN
  RETURN QUERY
  -- التقارير المرتبطة بأنواع محددة
  SELECT 
    rt.name,
    rt.name_ar,
    COUNT(r.id) as count,
    rt.priority_level
  FROM report_types rt
  INNER JOIN reports r ON rt.id = r.report_type_id
  GROUP BY rt.id, rt.name, rt.name_ar, rt.priority_level
  
  UNION ALL
  
  -- التقارير المخصصة
  SELECT 
    r.report_type_custom as name,
    r.report_type_custom as name_ar,
    COUNT(r.id) as count,
    'medium'::TEXT as priority_level
  FROM reports r
  WHERE r.report_type_custom IS NOT NULL
    AND r.report_type_id IS NULL
  GROUP BY r.report_type_custom
  
  ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;

-- 3. دالة للحصول على تقارير النقاط الساخنة
CREATE OR REPLACE FUNCTION get_hotspot_reports(
  radius_km DECIMAL DEFAULT 5.0,
  min_reports INTEGER DEFAULT 3
)
RETURNS TABLE (
  center_lat DECIMAL,
  center_lng DECIMAL,
  report_count BIGINT,
  governorate_name TEXT,
  severity_level TEXT
) AS $$
BEGIN
  RETURN QUERY
  WITH report_locations AS (
    SELECT 
      r.incident_location_latitude,
      r.incident_location_longitude,
      u.governorate,
      r.priority_level,
      r.id
    FROM reports r
    INNER JOIN users u ON r.user_id = u.id
    WHERE r.incident_location_latitude IS NOT NULL
      AND r.incident_location_longitude IS NOT NULL
  ),
  clustered_reports AS (
    SELECT 
      ROUND(incident_location_latitude, 2) as cluster_lat,
      ROUND(incident_location_longitude, 2) as cluster_lng,
      governorate,
      COUNT(*) as report_count,
      CASE 
        WHEN COUNT(CASE WHEN priority_level IN ('urgent', 'high') THEN 1 END) >= COUNT(*) * 0.6 THEN 'high'
        WHEN COUNT(CASE WHEN priority_level = 'medium' THEN 1 END) >= COUNT(*) * 0.6 THEN 'medium'
        ELSE 'low'
      END as severity_level
    FROM report_locations
    GROUP BY 
      ROUND(incident_location_latitude, 2),
      ROUND(incident_location_longitude, 2),
      governorate
    HAVING COUNT(*) >= min_reports
  )
  SELECT 
    cluster_lat,
    cluster_lng,
    cr.report_count,
    cr.governorate,
    cr.severity_level
  FROM clustered_reports cr
  ORDER BY cr.report_count DESC, cr.severity_level DESC;
END;
$$ LANGUAGE plpgsql;

-- 4. دالة للحصول على الإحصائيات العامة
CREATE OR REPLACE FUNCTION get_general_statistics()
RETURNS TABLE (
  total_reports BIGINT,
  pending_reports BIGINT,
  resolved_reports BIGINT,
  this_month_reports BIGINT,
  last_month_reports BIGINT,
  most_common_type TEXT,
  most_common_type_count BIGINT,
  avg_resolution_days DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  WITH monthly_stats AS (
    SELECT 
      COUNT(*) FILTER (WHERE DATE_TRUNC('month', submitted_at) = DATE_TRUNC('month', CURRENT_DATE)) as this_month,
      COUNT(*) FILTER (WHERE DATE_TRUNC('month', submitted_at) = DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month') as last_month
    FROM reports
  ),
  type_stats AS (
    SELECT 
      COALESCE(rt.name_ar, r.report_type_custom) as type_name,
      COUNT(*) as type_count,
      ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as rank
    FROM reports r
    LEFT JOIN report_types rt ON r.report_type_id = rt.id
    WHERE COALESCE(rt.name_ar, r.report_type_custom) IS NOT NULL
    GROUP BY COALESCE(rt.name_ar, r.report_type_custom)
  ),
  resolution_stats AS (
    SELECT 
      AVG(EXTRACT(EPOCH FROM (resolved_at - submitted_at)) / 86400) as avg_days
    FROM reports
    WHERE resolved_at IS NOT NULL
  )
  SELECT 
    (SELECT COUNT(*) FROM reports)::BIGINT,
    (SELECT COUNT(*) FROM reports WHERE report_status = 'pending')::BIGINT,
    (SELECT COUNT(*) FROM reports WHERE report_status = 'resolved')::BIGINT,
    ms.this_month::BIGINT,
    ms.last_month::BIGINT,
    ts.type_name::TEXT,
    ts.type_count::BIGINT,
    COALESCE(rs.avg_days, 0)::DECIMAL
  FROM monthly_stats ms
  CROSS JOIN (SELECT type_name, type_count FROM type_stats WHERE rank = 1) ts
  CROSS JOIN resolution_stats rs;
END;
$$ LANGUAGE plpgsql;

-- 5. دالة للحصول على تقارير قريبة من موقع معين
CREATE OR REPLACE FUNCTION get_nearby_reports(
  target_lat DECIMAL,
  target_lng DECIMAL,
  radius_km DECIMAL DEFAULT 10.0,
  limit_count INTEGER DEFAULT 50
)
RETURNS TABLE (
  report_id UUID,
  distance_km DECIMAL,
  incident_lat DECIMAL,
  incident_lng DECIMAL,
  report_type TEXT,
  report_status TEXT,
  priority_level TEXT,
  submitted_at TIMESTAMP,
  governorate TEXT,
  city TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    (6371 * acos(
      cos(radians(target_lat)) * 
      cos(radians(r.incident_location_latitude)) * 
      cos(radians(r.incident_location_longitude) - radians(target_lng)) + 
      sin(radians(target_lat)) * 
      sin(radians(r.incident_location_latitude))
    ))::DECIMAL as distance_km,
    r.incident_location_latitude,
    r.incident_location_longitude,
    COALESCE(rt.name_ar, r.report_type_custom) as report_type,
    r.report_status,
    r.priority_level,
    r.submitted_at,
    u.governorate,
    u.city
  FROM reports r
  LEFT JOIN report_types rt ON r.report_type_id = rt.id
  LEFT JOIN users u ON r.user_id = u.id
  WHERE r.incident_location_latitude IS NOT NULL
    AND r.incident_location_longitude IS NOT NULL
    AND (6371 * acos(
      cos(radians(target_lat)) * 
      cos(radians(r.incident_location_latitude)) * 
      cos(radians(r.incident_location_longitude) - radians(target_lng)) + 
      sin(radians(target_lat)) * 
      sin(radians(r.incident_location_latitude))
    )) <= radius_km
  ORDER BY distance_km ASC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- 6. استعلامات مفيدة للتطوير والاختبار

-- إحصائيات سريعة
SELECT 
  COUNT(*) as total_reports,
  COUNT(*) FILTER (WHERE report_status = 'pending') as pending,
  COUNT(*) FILTER (WHERE report_status = 'resolved') as resolved,
  COUNT(*) FILTER (WHERE incident_location_latitude IS NOT NULL) as with_location
FROM reports;

-- أكثر المحافظات نشاطاً
SELECT 
  u.governorate,
  COUNT(r.id) as report_count,
  COUNT(*) FILTER (WHERE r.report_status = 'pending') as pending_count
FROM users u
INNER JOIN reports r ON u.id = r.user_id
WHERE u.governorate IS NOT NULL
GROUP BY u.governorate
ORDER BY report_count DESC;

-- التقارير حسب النوع
SELECT 
  COALESCE(rt.name_ar, r.report_type_custom, 'غير محدد') as report_type,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM reports), 2) as percentage
FROM reports r
LEFT JOIN report_types rt ON r.report_type_id = rt.id
GROUP BY COALESCE(rt.name_ar, r.report_type_custom, 'غير محدد')
ORDER BY count DESC;

-- التقارير الشهرية
SELECT 
  DATE_TRUNC('month', submitted_at) as month,
  COUNT(*) as report_count
FROM reports
WHERE submitted_at >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', submitted_at)
ORDER BY month DESC;

-- النقاط الساخنة (مجمعة حسب المنطقة)
SELECT 
  u.governorate,
  u.city,
  COUNT(r.id) as report_count,
  AVG(r.incident_location_latitude) as avg_lat,
  AVG(r.incident_location_longitude) as avg_lng
FROM reports r
INNER JOIN users u ON r.user_id = u.id
WHERE r.incident_location_latitude IS NOT NULL
  AND r.incident_location_longitude IS NOT NULL
GROUP BY u.governorate, u.city
HAVING COUNT(r.id) >= 5
ORDER BY report_count DESC;