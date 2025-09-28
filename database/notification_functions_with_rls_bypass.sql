-- Database functions for notification system with RLS bypass
-- These functions should be executed by a database admin

-- Function to create a notification bypassing RLS
CREATE OR REPLACE FUNCTION create_notification_bypass_rls(
  p_user_id UUID,
  p_title TEXT,
  p_title_ar TEXT DEFAULT NULL,
  p_body TEXT,
  p_body_ar TEXT DEFAULT NULL,
  p_type TEXT DEFAULT 'system',
  p_reference_id TEXT DEFAULT NULL,
  p_reference_type TEXT DEFAULT NULL,
  p_priority TEXT DEFAULT 'normal',
  p_data JSONB DEFAULT NULL
)
RETURNS notifications
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  new_notification notifications;
BEGIN
  -- Insert the notification with elevated privileges
  INSERT INTO notifications (
    user_id,
    title,
    title_ar,
    body,
    body_ar,
    notification_type,
    reference_id,
    reference_type,
    priority,
    data,
    is_read,
    is_sent,
    created_at
  ) VALUES (
    p_user_id,
    p_title,
    p_title_ar,
    p_body,
    p_body_ar,
    p_type,
    p_reference_id,
    p_reference_type,
    p_priority,
    p_data,
    false,
    false,
    NOW()
  ) RETURNING * INTO new_notification;
  
  RETURN new_notification;
END;
$$;

-- Function to create bulk notifications bypassing RLS
CREATE OR REPLACE FUNCTION create_bulk_notifications_bypass_rls(
  notifications_data JSONB
)
RETURNS SETOF notifications
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  notification_item JSONB;
  new_notification notifications;
BEGIN
  -- Loop through each notification in the array
  FOR notification_item IN SELECT * FROM jsonb_array_elements(notifications_data)
  LOOP
    -- Insert each notification with elevated privileges
    INSERT INTO notifications (
      user_id,
      title,
      title_ar,
      body,
      body_ar,
      notification_type,
      reference_id,
      reference_type,
      priority,
      data,
      is_read,
      is_sent,
      created_at
    ) VALUES (
      (notification_item->>'user_id')::UUID,
      notification_item->>'title',
      notification_item->>'title_ar',
      notification_item->>'body',
      notification_item->>'body_ar',
      COALESCE(notification_item->>'notification_type', 'system'),
      notification_item->>'reference_id',
      notification_item->>'reference_type',
      COALESCE(notification_item->>'priority', 'normal'),
      notification_item->'data',
      COALESCE((notification_item->>'is_read')::boolean, false),
      COALESCE((notification_item->>'is_sent')::boolean, false),
      NOW()
    ) RETURNING * INTO new_notification;
    
    RETURN NEXT new_notification;
  END LOOP;
  
  RETURN;
END;
$$;

-- Function to get user notifications (used for testing)
CREATE OR REPLACE FUNCTION get_user_notifications_with_bypass(
  target_user_id UUID,
  page_limit INTEGER DEFAULT 20,
  page_offset INTEGER DEFAULT 0,
  unread_only BOOLEAN DEFAULT false
)
RETURNS SETOF notifications
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF unread_only THEN
    RETURN QUERY
    SELECT * FROM notifications
    WHERE user_id = target_user_id
    AND is_read = false
    ORDER BY created_at DESC
    LIMIT page_limit
    OFFSET page_offset;
  ELSE
    RETURN QUERY
    SELECT * FROM notifications
    WHERE user_id = target_user_id
    ORDER BY created_at DESC
    LIMIT page_limit
    OFFSET page_offset;
  END IF;
END;
$$;

-- Function to get unread count
CREATE OR REPLACE FUNCTION get_unread_notifications_count_with_bypass(
  target_user_id UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  unread_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO unread_count
  FROM notifications
  WHERE user_id = target_user_id
  AND is_read = false;
  
  RETURN unread_count;
END;
$$;

-- Function to mark notification as read
CREATE OR REPLACE FUNCTION mark_notification_read_with_bypass(
  notification_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE notifications
  SET is_read = true,
      read_at = NOW()
  WHERE id = notification_id;
  
  RETURN FOUND;
END;
$$;

-- Function to mark all notifications as read for a user
CREATE OR REPLACE FUNCTION mark_all_notifications_read_with_bypass(
  target_user_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE notifications
  SET is_read = true,
      read_at = NOW()
  WHERE user_id = target_user_id
  AND is_read = false;
  
  RETURN FOUND;
END;
$$;

-- Grant execute permissions to the authenticated role
GRANT EXECUTE ON FUNCTION create_notification_bypass_rls TO authenticated;
GRANT EXECUTE ON FUNCTION create_bulk_notifications_bypass_rls TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_notifications_with_bypass TO authenticated;
GRANT EXECUTE ON FUNCTION get_unread_notifications_count_with_bypass TO authenticated;
GRANT EXECUTE ON FUNCTION mark_notification_read_with_bypass TO authenticated;
GRANT EXECUTE ON FUNCTION mark_all_notifications_read_with_bypass TO authenticated;