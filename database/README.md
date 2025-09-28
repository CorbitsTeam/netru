# Notification System Database Setup

This directory contains SQL functions and scripts needed for the notification system to work properly with Supabase Row Level Security (RLS) policies.

## Files

### `notification_functions_with_rls_bypass.sql`
Contains database functions that can bypass RLS policies for the notification system. These functions should be executed by a database administrator.

**Functions included:**
- `create_notification_bypass_rls()` - Creates a single notification bypassing RLS
- `create_bulk_notifications_bypass_rls()` - Creates multiple notifications in bulk bypassing RLS
- `get_user_notifications_with_bypass()` - Retrieves user notifications bypassing RLS
- `get_unread_notifications_count_with_bypass()` - Gets unread count bypassing RLS
- `mark_notification_read_with_bypass()` - Marks notification as read bypassing RLS
- `mark_all_notifications_read_with_bypass()` - Marks all user notifications as read bypassing RLS

## Setup Instructions

1. Connect to your Supabase database as an admin user
2. Execute the SQL in `notification_functions_with_rls_bypass.sql`
3. Ensure the functions are created successfully
4. Verify that the `authenticated` role has execute permissions on these functions

## Usage

The Flutter app will automatically try to use these bypass functions first, falling back to standard functions or direct queries if they're not available.

## RLS Policy Issues

If you're experiencing "row-level security policy" violations when creating notifications, it means:

1. The RLS policies on the `notifications` table are too restrictive
2. The bypass functions haven't been created yet
3. The current user doesn't have proper permissions

The bypass functions in this script should resolve these issues by using `SECURITY DEFINER` to run with elevated privileges.

## Testing

After setting up the functions, test the notification system by:

1. Creating a new report (should send admin notifications)
2. Viewing notifications in the app
3. Checking the console logs for successful notification creation

## Troubleshooting

If notifications still don't work:

1. Check if the functions were created: `\df` in psql
2. Verify permissions: `\z notifications` in psql
3. Check RLS policies: `SELECT * FROM pg_policies WHERE tablename = 'notifications';`
4. Look at the Flutter app logs for specific error messages