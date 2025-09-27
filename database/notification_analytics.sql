-- ============================================
-- Notification Analytics SQL Functions
-- ============================================
-- These functions provide analytics for the notification system
-- Run this in Supabase SQL Editor

-- Function to get daily notification statistics
CREATE OR REPLACE FUNCTION get_daily_notification_stats(
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    date DATE,
    total_sent INTEGER,
    total_delivered INTEGER,
    total_opened INTEGER,
    total_clicked INTEGER,
    total_failed INTEGER,
    delivery_rate NUMERIC,
    open_rate NUMERIC
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH daily_stats AS (
        SELECT 
            DATE(n.created_at) as stat_date,
            COUNT(*) as total_notifications,
            COUNT(*) FILTER (WHERE n.is_sent = true) as sent_count,
            COUNT(*) FILTER (WHERE n.is_read = true) as read_count,
            COUNT(*) FILTER (WHERE n.is_sent = false AND n.sent_at IS NULL) as failed_count,
            -- Assuming delivered = sent for now (can be enhanced with FCM delivery receipts)
            COUNT(*) FILTER (WHERE n.is_sent = true) as delivered_count,
            -- Clicked would need additional tracking
            0 as clicked_count
        FROM notifications n
        WHERE DATE(n.created_at) BETWEEN start_date AND end_date
        GROUP BY DATE(n.created_at)
    )
    SELECT 
        ds.stat_date::DATE,
        ds.sent_count::INTEGER,
        ds.delivered_count::INTEGER,
        ds.read_count::INTEGER,
        ds.clicked_count::INTEGER,
        ds.failed_count::INTEGER,
        CASE 
            WHEN ds.total_notifications > 0 
            THEN ROUND((ds.delivered_count * 100.0 / ds.total_notifications), 2)
            ELSE 0 
        END::NUMERIC as delivery_rate,
        CASE 
            WHEN ds.delivered_count > 0 
            THEN ROUND((ds.read_count * 100.0 / ds.delivered_count), 2)
            ELSE 0 
        END::NUMERIC as open_rate
    FROM daily_stats ds
    ORDER BY ds.stat_date;
END;
$$;

-- Function to get hourly notification statistics for a specific date
CREATE OR REPLACE FUNCTION get_hourly_notification_stats(
    target_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    hour INTEGER,
    total_sent INTEGER,
    total_delivered INTEGER,
    delivery_rate NUMERIC
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH hourly_stats AS (
        SELECT 
            EXTRACT(HOUR FROM n.created_at)::INTEGER as stat_hour,
            COUNT(*) as total_notifications,
            COUNT(*) FILTER (WHERE n.is_sent = true) as sent_count,
            COUNT(*) FILTER (WHERE n.is_sent = true) as delivered_count
        FROM notifications n
        WHERE DATE(n.created_at) = target_date
        GROUP BY EXTRACT(HOUR FROM n.created_at)
    )
    SELECT 
        hs.stat_hour,
        hs.sent_count::INTEGER,
        hs.delivered_count::INTEGER,
        CASE 
            WHEN hs.total_notifications > 0 
            THEN ROUND((hs.delivered_count * 100.0 / hs.total_notifications), 2)
            ELSE 0 
        END::NUMERIC as delivery_rate
    FROM hourly_stats hs
    ORDER BY hs.stat_hour;
END;
$$;

-- Function to get notification statistics by governorate
CREATE OR REPLACE FUNCTION get_governorate_notification_stats(
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    governorate_name TEXT,
    total_notifications INTEGER,
    sent_notifications INTEGER,
    read_notifications INTEGER,
    delivery_rate NUMERIC,
    open_rate NUMERIC
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH governorate_stats AS (
        SELECT 
            COALESCE(u.governorate, 'غير محدد') as gov_name,
            COUNT(n.id) as total_count,
            COUNT(n.id) FILTER (WHERE n.is_sent = true) as sent_count,
            COUNT(n.id) FILTER (WHERE n.is_read = true) as read_count
        FROM notifications n
        JOIN users u ON n.user_id = u.id
        WHERE DATE(n.created_at) BETWEEN start_date AND end_date
        GROUP BY u.governorate
    )
    SELECT 
        gs.gov_name::TEXT,
        gs.total_count::INTEGER,
        gs.sent_count::INTEGER,
        gs.read_count::INTEGER,
        CASE 
            WHEN gs.total_count > 0 
            THEN ROUND((gs.sent_count * 100.0 / gs.total_count), 2)
            ELSE 0 
        END::NUMERIC as delivery_rate,
        CASE 
            WHEN gs.sent_count > 0 
            THEN ROUND((gs.read_count * 100.0 / gs.sent_count), 2)
            ELSE 0 
        END::NUMERIC as open_rate
    FROM governorate_stats gs
    ORDER BY gs.total_count DESC;
END;
$$;

-- Function to get notification performance by type
CREATE OR REPLACE FUNCTION get_notification_type_performance(
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    notification_type TEXT,
    total_count INTEGER,
    sent_count INTEGER,
    read_count INTEGER,
    avg_delivery_time_minutes NUMERIC,
    performance_score NUMERIC
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH type_performance AS (
        SELECT 
            n.notification_type,
            COUNT(*) as total,
            COUNT(*) FILTER (WHERE n.is_sent = true) as sent,
            COUNT(*) FILTER (WHERE n.is_read = true) as read,
            AVG(
                CASE 
                    WHEN n.sent_at IS NOT NULL AND n.created_at IS NOT NULL 
                    THEN EXTRACT(EPOCH FROM (n.sent_at - n.created_at)) / 60 
                    ELSE NULL 
                END
            ) as avg_delivery_minutes,
            -- Performance score based on delivery rate and open rate
            (
                (COUNT(*) FILTER (WHERE n.is_sent = true) * 100.0 / GREATEST(COUNT(*), 1)) * 0.6 +
                (COUNT(*) FILTER (WHERE n.is_read = true) * 100.0 / GREATEST(COUNT(*) FILTER (WHERE n.is_sent = true), 1)) * 0.4
            ) as perf_score
        FROM notifications n
        WHERE DATE(n.created_at) BETWEEN start_date AND end_date
        GROUP BY n.notification_type
    )
    SELECT 
        tp.notification_type::TEXT,
        tp.total::INTEGER,
        tp.sent::INTEGER,
        tp.read::INTEGER,
        ROUND(COALESCE(tp.avg_delivery_minutes, 0), 2)::NUMERIC,
        ROUND(tp.perf_score, 2)::NUMERIC
    FROM type_performance tp
    ORDER BY tp.perf_score DESC;
END;
$$;

-- Function to get user engagement metrics
CREATE OR REPLACE FUNCTION get_user_engagement_metrics(
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    metric_name TEXT,
    metric_value NUMERIC,
    metric_description TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    total_users INTEGER;
    active_users INTEGER;
    total_notifications INTEGER;
    read_notifications INTEGER;
BEGIN
    -- Get basic counts
    SELECT COUNT(DISTINCT u.id) INTO total_users FROM users u;
    
    SELECT COUNT(DISTINCT n.user_id) INTO active_users 
    FROM notifications n 
    WHERE DATE(n.created_at) BETWEEN start_date AND end_date;
    
    SELECT COUNT(*) INTO total_notifications 
    FROM notifications n 
    WHERE DATE(n.created_at) BETWEEN start_date AND end_date;
    
    SELECT COUNT(*) INTO read_notifications 
    FROM notifications n 
    WHERE DATE(n.created_at) BETWEEN start_date AND end_date 
    AND n.is_read = true;

    RETURN QUERY
    SELECT 
        'Total Users'::TEXT,
        total_users::NUMERIC,
        'إجمالي عدد المستخدمين المسجلين'::TEXT
    UNION ALL
    SELECT 
        'Active Users'::TEXT,
        active_users::NUMERIC,
        'عدد المستخدمين الذين تلقوا إشعارات'::TEXT
    UNION ALL
    SELECT 
        'Engagement Rate'::TEXT,
        CASE WHEN total_users > 0 THEN ROUND((active_users * 100.0 / total_users), 2) ELSE 0 END::NUMERIC,
        'نسبة المستخدمين المتفاعلين'::TEXT
    UNION ALL
    SELECT 
        'Avg Notifications per User'::TEXT,
        CASE WHEN active_users > 0 THEN ROUND((total_notifications::NUMERIC / active_users), 2) ELSE 0 END::NUMERIC,
        'متوسط الإشعارات لكل مستخدم'::TEXT
    UNION ALL
    SELECT 
        'Overall Open Rate'::TEXT,
        CASE WHEN total_notifications > 0 THEN ROUND((read_notifications * 100.0 / total_notifications), 2) ELSE 0 END::NUMERIC,
        'معدل فتح الإشعارات العام'::TEXT;
END;
$$;

-- Function to get peak notification hours
CREATE OR REPLACE FUNCTION get_peak_notification_hours()
RETURNS TABLE (
    hour_24 INTEGER,
    hour_12 TEXT,
    notification_count INTEGER,
    open_rate NUMERIC,
    recommendation TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH hourly_performance AS (
        SELECT 
            EXTRACT(HOUR FROM n.created_at)::INTEGER as hour_val,
            COUNT(*) as total_notifications,
            COUNT(*) FILTER (WHERE n.is_read = true) as opened_notifications
        FROM notifications n
        WHERE n.created_at >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY EXTRACT(HOUR FROM n.created_at)
    ),
    hour_analysis AS (
        SELECT 
            hp.hour_val,
            CASE 
                WHEN hp.hour_val = 0 THEN '12 ص'
                WHEN hp.hour_val < 12 THEN hp.hour_val || ' ص'
                WHEN hp.hour_val = 12 THEN '12 م'
                ELSE (hp.hour_val - 12) || ' م'
            END as hour_display,
            hp.total_notifications,
            CASE 
                WHEN hp.total_notifications > 0 
                THEN ROUND((hp.opened_notifications * 100.0 / hp.total_notifications), 2)
                ELSE 0 
            END as open_rate_val,
            CASE 
                WHEN hp.total_notifications > (SELECT AVG(total_notifications) FROM hourly_performance) * 1.2
                    AND (hp.opened_notifications * 100.0 / GREATEST(hp.total_notifications, 1)) > 15
                THEN 'وقت مثالي للإرسال'
                WHEN hp.total_notifications > (SELECT AVG(total_notifications) FROM hourly_performance)
                THEN 'وقت جيد للإرسال'
                ELSE 'وقت عادي'
            END as recommendation_text
        FROM hourly_performance hp
    )
    SELECT 
        ha.hour_val,
        ha.hour_display::TEXT,
        ha.total_notifications::INTEGER,
        ha.open_rate_val::NUMERIC,
        ha.recommendation_text::TEXT
    FROM hour_analysis ha
    ORDER BY ha.total_notifications DESC;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_daily_notification_stats(DATE, DATE) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_hourly_notification_stats(DATE) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_governorate_notification_stats(DATE, DATE) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_notification_type_performance(DATE, DATE) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_user_engagement_metrics(DATE, DATE) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_peak_notification_hours() TO authenticated, anon;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id_created_at ON notifications(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_type_created_at ON notifications(notification_type, created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_is_sent_created_at ON notifications(is_sent, created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read_created_at ON notifications(is_read, created_at);

-- Create a view for easy notification analytics access
CREATE OR REPLACE VIEW notification_analytics_summary AS
WITH recent_stats AS (
    SELECT 
        COUNT(*) as total_notifications,
        COUNT(*) FILTER (WHERE is_sent = true) as sent_notifications,
        COUNT(*) FILTER (WHERE is_read = true) as read_notifications,
        COUNT(DISTINCT user_id) as unique_recipients,
        COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_notifications,
        COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as week_notifications
    FROM notifications
    WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT 
    rs.*,
    CASE 
        WHEN rs.total_notifications > 0 
        THEN ROUND((rs.sent_notifications * 100.0 / rs.total_notifications), 2)
        ELSE 0 
    END as delivery_rate,
    CASE 
        WHEN rs.sent_notifications > 0 
        THEN ROUND((rs.read_notifications * 100.0 / rs.sent_notifications), 2)
        ELSE 0 
    END as open_rate,
    CASE 
        WHEN rs.unique_recipients > 0 
        THEN ROUND((rs.total_notifications::NUMERIC / rs.unique_recipients), 2)
        ELSE 0 
    END as avg_notifications_per_user
FROM recent_stats rs;

-- Grant view permissions
GRANT SELECT ON notification_analytics_summary TO authenticated, anon;

RAISE INFO 'Notification analytics functions and views created successfully!';