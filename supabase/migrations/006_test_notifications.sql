-- Insert test notifications for debugging
-- This file is for development/testing purposes only

DO $$
DECLARE
    test_user_id uuid;
BEGIN
    -- Get a test user ID (assuming there's at least one user)
    SELECT id INTO test_user_id FROM users LIMIT 1;
    
    -- Only insert if we found a user and no notifications exist yet
    IF test_user_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM notifications LIMIT 1) THEN
        -- Insert test notifications
        INSERT INTO notifications (
            user_id, 
            title, 
            title_ar, 
            body, 
            body_ar, 
            notification_type, 
            is_read, 
            priority,
            created_at
        ) VALUES 
        (
            test_user_id,
            'Welcome to NetRu',
            'مرحباً بك في نترو',
            'Welcome to the NetRu application. You can now submit and track reports.',
            'مرحباً بك في تطبيق نترو. يمكنك الآن تقديم ومتابعة البلاغات.',
            'system',
            false,
            'normal',
            NOW() - INTERVAL '2 hours'
        ),
        (
            test_user_id,
            'Report Submitted Successfully',
            'تم تقديم البلاغ بنجاح',
            'Your report has been submitted and is now under review.',
            'تم تقديم بلاغك وهو الآن قيد المراجعة.',
            'report_update',
            false,
            'normal',
            NOW() - INTERVAL '1 hour'
        ),
        (
            test_user_id,
            'System Update',
            'تحديث النظام',
            'The system has been updated with new features and improvements.',
            'تم تحديث النظام بميزات وتحسينات جديدة.',
            'system',
            true,
            'low',
            NOW() - INTERVAL '3 hours'
        ),
        (
            test_user_id,
            'New News Article',
            'مقال إخباري جديد',
            'A new news article has been published. Check it out now.',
            'تم نشر مقال إخباري جديد. تصفحه الآن.',
            'news',
            false,
            'normal',
            NOW() - INTERVAL '30 minutes'
        );
        
        RAISE NOTICE 'Test notifications inserted for user: %', test_user_id;
    ELSE
        RAISE NOTICE 'Notifications already exist or no users found - skipping test data insertion';
    END IF;
END $$;