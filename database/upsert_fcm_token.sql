-- ============================================
-- FCM Token Upsert Functions for Netru App
-- ============================================
-- These functions bypass RLS policies and handle FCM token registration
-- Run this script in Supabase SQL Editor

-- 1. Main upsert function (UUID parameter)
CREATE OR REPLACE FUNCTION upsert_fcm_token(
    p_user_id UUID,
    p_fcm_token TEXT,
    p_device_type TEXT DEFAULT 'android',
    p_device_id TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER -- This bypasses RLS policies
AS $$
DECLARE
    token_id UUID;
    existing_count INTEGER;
BEGIN
    -- Log the upsert attempt
    RAISE INFO 'Upserting FCM token for user: % device: %', p_user_id, p_device_type;
    
    -- First, try to update existing token for this user and device type
    UPDATE user_fcm_tokens 
    SET 
        fcm_token = p_fcm_token,
        is_active = true,
        last_used = NOW(),
        app_version = COALESCE(p_app_version, app_version)
    WHERE 
        user_id = p_user_id 
        AND device_type = p_device_type
    RETURNING id INTO token_id;
    
    GET DIAGNOSTICS existing_count = ROW_COUNT;
    
    -- If no existing token was updated, insert a new one
    IF existing_count = 0 THEN
        INSERT INTO user_fcm_tokens (
            user_id,
            fcm_token,
            device_type,
            device_id,
            app_version,
            is_active,
            last_used,
            created_at
        ) VALUES (
            p_user_id,
            p_fcm_token,
            p_device_type,
            COALESCE(p_device_id, 'device_' || EXTRACT(EPOCH FROM NOW())::bigint::text),
            p_app_version,
            true,
            NOW(),
            NOW()
        ) RETURNING id INTO token_id;
        
        RAISE INFO 'Inserted new FCM token with ID: %', token_id;
    ELSE
        RAISE INFO 'Updated existing FCM token with ID: %', token_id;
    END IF;
    
    -- Deactivate other tokens for this user and device type (keep only latest)
    UPDATE user_fcm_tokens 
    SET is_active = false 
    WHERE 
        user_id = p_user_id 
        AND device_type = p_device_type 
        AND id != token_id;
        
    RETURN token_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error upserting FCM token: %', SQLERRM;
        RETURN NULL;
END;
$$;

-- 2. String-based user_id function (more flexible)
CREATE OR REPLACE FUNCTION upsert_fcm_token_str(
    p_user_id TEXT,
    p_fcm_token TEXT,
    p_device_type TEXT DEFAULT 'android',
    p_device_id TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_uuid UUID;
BEGIN
    -- Validate and convert user_id to UUID
    BEGIN
        user_uuid := p_user_id::UUID;
    EXCEPTION
        WHEN invalid_text_representation THEN
            RAISE WARNING 'Invalid user ID format: %', p_user_id;
            RETURN NULL;
    END;
    
    -- Call the main upsert function
    RETURN upsert_fcm_token(
        user_uuid,
        p_fcm_token,
        p_device_type,
        p_device_id,
        p_app_version
    );
END;
$$;

-- 3. Batch cleanup function (optional)
CREATE OR REPLACE FUNCTION cleanup_old_fcm_tokens(days_old INTEGER DEFAULT 30)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_fcm_tokens 
    WHERE 
        is_active = false 
        AND last_used < NOW() - INTERVAL '1 day' * days_old;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE INFO 'Cleaned up % old FCM tokens', deleted_count;
    RETURN deleted_count;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION upsert_fcm_token(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION upsert_fcm_token_str(TEXT, TEXT, TEXT, TEXT, TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION cleanup_old_fcm_tokens(INTEGER) TO authenticated;

-- Test the functions (uncomment to test)
-- SELECT upsert_fcm_token_str(
--     'fdadf54e-2dd4-4a2b-97e3-d320529bf688'::text,
--     'test_token_12345',
--     'android',
--     'test_device_123',
--     '1.0.0'
-- );

RAISE INFO 'FCM token upsert functions created successfully!';