-- Supabase RPC Functions for Admin Dashboard Analytics

-- Function to get reports count by governorate
CREATE OR REPLACE FUNCTION get_reports_by_governorate()
RETURNS TABLE(governorate TEXT, count BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(u.governorate, 'غير محدد') as governorate,
    COUNT(r.id) as count
  FROM reports r
  LEFT JOIN users u ON r.user_id = u.id
  GROUP BY u.governorate
  ORDER BY count DESC;
END;
$$;

-- Function to get reports count by type
CREATE OR REPLACE FUNCTION get_reports_by_type()
RETURNS TABLE(type_name TEXT, count BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(rt.name, r.report_type_custom, 'غير محدد') as type_name,
    COUNT(r.id) as count
  FROM reports r
  LEFT JOIN report_types rt ON r.report_type_id = rt.id
  GROUP BY rt.name, r.report_type_custom
  ORDER BY count DESC;
END;
$$;

-- Function to get reports count by status
CREATE OR REPLACE FUNCTION get_reports_by_status()
RETURNS TABLE(status TEXT, count BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.report_status as status,
    COUNT(r.id) as count
  FROM reports r
  GROUP BY r.report_status
  ORDER BY count DESC;
END;
$$;

-- Function to get report trends over time
CREATE OR REPLACE FUNCTION get_report_trends(start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS TABLE(date DATE, status TEXT, count BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    DATE(r.submitted_at) as date,
    r.report_status as status,
    COUNT(r.id) as count
  FROM reports r
  WHERE r.submitted_at BETWEEN start_date AND end_date
  GROUP BY DATE(r.submitted_at), r.report_status
  ORDER BY date DESC, status;
END;
$$;

-- Function to get user statistics
CREATE OR REPLACE FUNCTION get_user_statistics()
RETURNS TABLE(
  total_users BIGINT,
  citizen_users BIGINT,
  foreigner_users BIGINT,
  admin_users BIGINT,
  pending_verifications BIGINT,
  verified_users BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) as total_users,
    COUNT(*) FILTER (WHERE user_type = 'citizen') as citizen_users,
    COUNT(*) FILTER (WHERE user_type = 'foreigner') as foreigner_users,
    COUNT(*) FILTER (WHERE user_type = 'admin') as admin_users,
    COUNT(*) FILTER (WHERE verification_status = 'pending') as pending_verifications,
    COUNT(*) FILTER (WHERE verification_status = 'verified') as verified_users
  FROM users;
END;
$$;

-- Function to get report statistics
CREATE OR REPLACE FUNCTION get_report_statistics()
RETURNS TABLE(
  total_reports BIGINT,
  pending_reports BIGINT,
  under_investigation_reports BIGINT,
  resolved_reports BIGINT,
  rejected_reports BIGINT,
  anonymous_reports BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) as total_reports,
    COUNT(*) FILTER (WHERE report_status = 'pending') as pending_reports,
    COUNT(*) FILTER (WHERE report_status = 'under_investigation') as under_investigation_reports,
    COUNT(*) FILTER (WHERE report_status = 'resolved') as resolved_reports,
    COUNT(*) FILTER (WHERE report_status = 'rejected') as rejected_reports,
    COUNT(*) FILTER (WHERE is_anonymous = true) as anonymous_reports
  FROM reports;
END;
$$;

-- Function to get recent activity for dashboard
CREATE OR REPLACE FUNCTION get_recent_activity(limit_count INTEGER DEFAULT 10)
RETURNS TABLE(
  activity_type TEXT,
  description TEXT,
  user_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  (
    SELECT 
      'report' as activity_type,
      'تم تقديم بلاغ جديد: ' || LEFT(r.report_details, 50) || '...' as description,
      r.reporter_first_name || ' ' || r.reporter_last_name as user_name,
      r.submitted_at as created_at
    FROM reports r
    ORDER BY r.submitted_at DESC
    LIMIT limit_count / 2
  )
  UNION ALL
  (
    SELECT 
      'user' as activity_type,
      'انضمام مستخدم جديد' as description,
      u.full_name as user_name,
      u.created_at as created_at
    FROM users u
    WHERE u.user_type != 'admin'
    ORDER BY u.created_at DESC
    LIMIT limit_count / 2
  )
  ORDER BY created_at DESC
  LIMIT limit_count;
END;
$$;

-- Function to get comprehensive dashboard data in one call
CREATE OR REPLACE FUNCTION get_dashboard_summary()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'report_stats', (SELECT row_to_json(t) FROM (SELECT * FROM get_report_statistics()) t),
    'user_stats', (SELECT row_to_json(t) FROM (SELECT * FROM get_user_statistics()) t),
    'reports_by_governorate', (SELECT json_agg(row_to_json(t)) FROM (SELECT * FROM get_reports_by_governorate()) t),
    'reports_by_type', (SELECT json_agg(row_to_json(t)) FROM (SELECT * FROM get_reports_by_type()) t),
    'reports_by_status', (SELECT json_agg(row_to_json(t)) FROM (SELECT * FROM get_reports_by_status()) t),
    'recent_activity', (SELECT json_agg(row_to_json(t)) FROM (SELECT * FROM get_recent_activity(10)) t)
  ) INTO result;
  
  RETURN result;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION get_reports_by_governorate() TO authenticated;
GRANT EXECUTE ON FUNCTION get_reports_by_type() TO authenticated;
GRANT EXECUTE ON FUNCTION get_reports_by_status() TO authenticated;
GRANT EXECUTE ON FUNCTION get_report_trends(TIMESTAMP, TIMESTAMP) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_statistics() TO authenticated;
GRANT EXECUTE ON FUNCTION get_report_statistics() TO authenticated;
GRANT EXECUTE ON FUNCTION get_recent_activity(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_dashboard_summary() TO authenticated;