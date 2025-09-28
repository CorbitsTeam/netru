-- Function to create user notifications (simple version)
CREATE OR REPLACE FUNCTION create_user_notification(
  user_id UUID,
  title TEXT,
  title_ar TEXT DEFAULT NULL,
  body TEXT,
  body_ar TEXT DEFAULT NULL,
  notification_type TEXT DEFAULT 'system',
  is_read BOOLEAN DEFAULT FALSE,
  priority TEXT DEFAULT 'normal'
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
    NOW(),
    NOW()
  );
  
  RETURN new_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_user_notification TO authenticated;