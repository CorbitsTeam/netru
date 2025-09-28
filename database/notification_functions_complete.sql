-- Essential notification functions for NetRu app

-- 1. Function to create user notifications
CREATE OR REPLACE FUNCTION create_user_notification(
  user_id UUID,
  title TEXT,
  title_ar TEXT DEFAULT NULL,
  body TEXT,
  body_ar TEXT DEFAULT NULL,
  notification_type TEXT DEFAULT 'system',
  is_read BOOLEAN DEFAULT FALSE,
  priority TEXT DEFAULT 'normal',
  report_id UUID DEFAULT NULL,
  additional_data JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  new_id UUID;
BEGIN
  -- Generate new UUID
  new_id := gen_random_uuid();
  
  -- Insert notification
  INSERT INTO notifications (
    id,
    user_id,
    title,
    title_ar,
    body,
    body_ar,
    notification_type,
    is_read,
    priority,
    report_id,
    data,
    created_at,
    updated_at
  ) VALUES (
    new_id,
    user_id,
    title,
    COALESCE(title_ar, title),
    body,
    COALESCE(body_ar, body),
    notification_type,
    is_read,
    priority,
    report_id,
    additional_data,
    NOW(),
    NOW()
  );
  
  RETURN new_id;
END;
$$;

-- 2. Function to get user notifications (bypass RLS)
CREATE OR REPLACE FUNCTION get_user_notifications_bypass_rls(
  target_user_id UUID,
  limit_count INT DEFAULT 50,
  offset_count INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  title TEXT,
  title_ar TEXT,
  body TEXT,
  body_ar TEXT,
  notification_type TEXT,
  is_read BOOLEAN,
  priority TEXT,
  report_id UUID,
  data JSONB,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    n.id,
    n.user_id,
    n.title,
    n.title_ar,
    n.body,
    n.body_ar,
    n.notification_type,
    n.is_read,
    n.priority,
    n.report_id,
    n.data,
    n.created_at,
    n.updated_at
  FROM notifications n
  WHERE n.user_id = target_user_id
  ORDER BY n.created_at DESC
  LIMIT limit_count
  OFFSET offset_count;
END;
$$;

-- 3. Function to get unread count (bypass RLS)
CREATE OR REPLACE FUNCTION get_user_unread_count_bypass_rls(
  target_user_id UUID
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  unread_count INT;
BEGIN
  SELECT COUNT(*)
  INTO unread_count
  FROM notifications
  WHERE user_id = target_user_id AND is_read = FALSE;
  
  RETURN COALESCE(unread_count, 0);
END;
$$;

-- 4. Function to mark notification as read
CREATE OR REPLACE FUNCTION mark_notification_read(
  notification_id UUID,
  target_user_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  updated_count INT;
BEGIN
  UPDATE notifications
  SET is_read = TRUE, updated_at = NOW()
  WHERE id = notification_id AND user_id = target_user_id;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  
  RETURN updated_count > 0;
END;
$$;

-- 5. Function to get admin users
CREATE OR REPLACE FUNCTION get_admin_users()
RETURNS TABLE (
  id UUID,
  email TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.email
  FROM auth.users u
  JOIN user_profiles p ON p.user_id = u.id
  WHERE p.user_type = 'admin' OR p.is_admin = true;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION create_user_notification TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_notifications_bypass_rls TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_unread_count_bypass_rls TO authenticated;
GRANT EXECUTE ON FUNCTION mark_notification_read TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_users TO authenticated;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id_created_at 
ON notifications(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id_is_read 
ON notifications(user_id, is_read);

-- Comments
COMMENT ON FUNCTION create_user_notification IS 'Creates a new notification for a user, bypassing RLS';
COMMENT ON FUNCTION get_user_notifications_bypass_rls IS 'Gets user notifications bypassing RLS restrictions';
COMMENT ON FUNCTION get_user_unread_count_bypass_rls IS 'Gets count of unread notifications for a user';
COMMENT ON FUNCTION mark_notification_read IS 'Marks a notification as read for the specified user';
COMMENT ON FUNCTION get_admin_users IS 'Gets all admin users for notification purposes';