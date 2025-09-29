// ============================================
// Admin Notifications Management Edge Function
// ============================================
// This function provides comprehensive notification management for admins
// with FCM integration and database persistence
// Path: supabase/functions/admin-notifications/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getFirebaseAccessToken } from './firebase-jwt.ts'
import type { 
  AuthResult, 
  FCMResult, 
  AdminUser,
  NotificationRecord,
  UserRecord,
  FCMTokenRecord 
} from './types.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
}

// Initialize Supabase client
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const supabase = createClient(supabaseUrl, supabaseServiceKey)

// Firebase configuration
const firebaseProjectId = Deno.env.get('FIREBASE_PROJECT_ID')
const firebasePrivateKey = Deno.env.get('FIREBASE_PRIVATE_KEY')
const firebaseClientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Authenticate admin user
    const authResult = await authenticateAdmin(req)
    if (!authResult.success) {
      return new Response(
        JSON.stringify({ success: false, error: authResult.error }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const url = new URL(req.url)
    const action = url.searchParams.get('action') || 'get_notifications'
    
    console.log(`🔔 Admin notifications request: ${action} by user ${authResult.user.id}`)

    // Route based on action
    switch (action) {
      case 'get_notifications':
        return await handleGetNotifications(req, authResult.user)
      case 'create_notification':
        return await handleCreateNotification(req, authResult.user)
      case 'send_bulk':
        return await handleSendBulkNotification(req, authResult.user)
      case 'get_stats':
        return await handleGetStats(req, authResult.user)
      case 'delete_notification':
        return await handleDeleteNotification(req, authResult.user)
      case 'mark_read':
        return await handleMarkRead(req, authResult.user)
      default:
        return await handleGetNotifications(req, authResult.user)
    }

  } catch (error: any) {
    console.error('❌ Admin notifications error:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Internal server error'
      }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

// Authentication helper
async function authenticateAdmin(req: Request): Promise<{
  success: boolean
  user?: any
  error?: string
}> {
  try {
    const authHeader = req.headers.get('authorization')
    if (!authHeader) {
      return { success: false, error: 'Authorization header required' }
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error } = await supabase.auth.getUser(token)

    if (error || !user) {
      return { success: false, error: 'Invalid token' }
    }

    // Check if user is admin
    const { data: userProfile, error: profileError } = await supabase
      .from('users')
      .select('id, user_type, is_active, full_name')
      .eq('id', user.id)
      .single()

    if (profileError || !userProfile) {
      return { success: false, error: 'User profile not found' }
    }

    if (userProfile.user_type !== 'admin' || !userProfile.is_active) {
      return { success: false, error: 'Admin access required' }
    }

    return { success: true, user: userProfile }
  } catch (error: any) {
    return { success: false, error: error.message }
  }
}

// Handle get notifications with pagination
async function handleGetNotifications(req: Request, adminUser: any) {
  const url = new URL(req.url)
  const page = parseInt(url.searchParams.get('page') || '1')
  const limit = parseInt(url.searchParams.get('limit') || '20')
  const type = url.searchParams.get('type')
  const search = url.searchParams.get('search')
  const userId = url.searchParams.get('user_id')
  const status = url.searchParams.get('status')

  let query = supabase
    .from('notifications')
    .select(`
      *,
      users!inner (
        id,
        full_name,
        email,
        user_type
      )
    `)
    .order('created_at', { ascending: false })

  // Apply filters
  if (type) {
    query = query.eq('notification_type', type)
  }

  if (search) {
    query = query.or(`title.ilike.%${search}%,body.ilike.%${search}%`)
  }

  if (userId) {
    query = query.eq('user_id', userId)
  }

  if (status) {
    switch (status) {
      case 'read':
        query = query.eq('is_read', true)
        break
      case 'unread':
        query = query.eq('is_read', false)
        break
      case 'sent':
        query = query.not('fcm_message_id', 'is', null)
        break
    }
  }

  // Pagination
  const offset = (page - 1) * limit
  query = query.range(offset, offset + limit - 1)

  const { data: notifications, error } = await query

  if (error) {
    throw new Error(`Failed to fetch notifications: ${error.message}`)
  }

  // Get total count for pagination
  let countQuery = supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })

  if (type) countQuery = countQuery.eq('notification_type', type)
  if (search) countQuery = countQuery.or(`title.ilike.%${search}%,body.ilike.%${search}%`)
  if (userId) countQuery = countQuery.eq('user_id', userId)

  const { count: totalCount } = await countQuery

  // Log admin action
  await logAdminAction(adminUser.id, 'view_notifications', {
    page,
    limit,
    filters: { type, search, userId, status }
  })

  return new Response(
    JSON.stringify({
      success: true,
      data: notifications || [],
      pagination: {
        page,
        limit,
        total: totalCount || 0,
        pages: Math.ceil((totalCount || 0) / limit),
        hasMore: (totalCount || 0) > page * limit
      },
      generated_at: new Date().toISOString()
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle create single notification
async function handleCreateNotification(req: Request, adminUser: any) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  const body = await req.json()
  const {
    user_id,
    title,
    body: messageBody,
    notification_type = 'general',
    reference_id,
    reference_type,
    data
  } = body

  if (!user_id || !title || !messageBody) {
    throw new Error('user_id, title, and body are required')
  }

  // Create notification in database
  const { data: notification, error: insertError } = await supabase
    .from('notifications')
    .insert({
      user_id,
      title,
      body: messageBody,
      notification_type,
      reference_id,
      reference_type,
      data,
      is_read: false,
      created_at: new Date().toISOString()
    })
    .select()
    .single()

  if (insertError) {
    throw new Error(`Failed to create notification: ${insertError.message}`)
  }

  // Send FCM notification
  const fcmResult = await sendFCMNotification({
    userIds: [user_id],
    title,
    body: messageBody,
    data: data || {},
    notificationId: notification.id
  })

  // Update notification with FCM message ID if successful
  if (fcmResult.fcmMessageId) {
    await supabase
      .from('notifications')
      .update({ fcm_message_id: fcmResult.fcmMessageId })
      .eq('id', notification.id)
  }

  // Log admin action
  await logAdminAction(adminUser.id, 'create_notification', {
    notification_id: notification.id,
    target_user: user_id,
    fcm_sent: fcmResult.success
  })

  return new Response(
    JSON.stringify({
      success: true,
      message: 'تم إنشاء الإشعار بنجاح',
      data: {
        ...notification,
        fcm_message_id: fcmResult.fcmMessageId
      },
      fcm_result: fcmResult
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle bulk notification sending
async function handleSendBulkNotification(req: Request, adminUser: any) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  const body = await req.json()
  const {
    title,
    body: messageBody,
    notification_type = 'general',
    target_type = 'all', // 'all', 'user_type', 'specific_users'
    target_value,
    data
  } = body

  if (!title || !messageBody) {
    throw new Error('title and body are required')
  }

  console.log(`📤 Bulk notification request: ${target_type} by admin ${adminUser.id}`)

  // Get target users based on target_type
  let targetUsers: any[] = []

  switch (target_type) {
    case 'all':
      const { data: allUsers } = await supabase
        .from('users')
        .select('id, full_name, email')
        .eq('is_active', true)
      targetUsers = allUsers || []
      break

    case 'user_type':
      if (!target_value) {
        throw new Error('target_value is required for user_type targeting')
      }
      const { data: typeUsers } = await supabase
        .from('users')
        .select('id, full_name, email')
        .eq('user_type', target_value)
        .eq('is_active', true)
      targetUsers = typeUsers || []
      break

    case 'specific_users':
      if (!Array.isArray(target_value)) {
        throw new Error('target_value must be an array of user IDs for specific_users targeting')
      }
      const { data: specificUsers } = await supabase
        .from('users')
        .select('id, full_name, email')
        .in('id', target_value)
        .eq('is_active', true)
      targetUsers = specificUsers || []
      break

    default:
      throw new Error('Invalid target_type. Must be: all, user_type, or specific_users')
  }

  if (targetUsers.length === 0) {
    throw new Error('No users found for the specified target')
  }

  console.log(`📱 Targeting ${targetUsers.length} users`)

  // Create notifications for all target users
  const notifications = targetUsers.map(user => ({
    user_id: user.id,
    title,
    body: messageBody,
    notification_type,
    data,
    is_read: false,
    created_at: new Date().toISOString()
  }))

  // Insert notifications in batches
  const batchSize = 100
  let insertedNotifications: any[] = []

  for (let i = 0; i < notifications.length; i += batchSize) {
    const batch = notifications.slice(i, i + batchSize)
    const { data: insertedBatch, error } = await supabase
      .from('notifications')
      .insert(batch)
      .select()

    if (error) {
      console.error('Batch insert error:', error)
      continue
    }

    if (insertedBatch) {
      insertedNotifications.push(...insertedBatch)
    }
  }

  // Send FCM notifications
  const userIds = targetUsers.map(user => user.id)
  const fcmResult = await sendFCMNotification({
    userIds,
    title,
    body: messageBody,
    data: data || {},
    notificationId: insertedNotifications[0]?.id
  })

  // Log admin action
  await logAdminAction(adminUser.id, 'send_bulk_notification', {
    target_type,
    target_value,
    notifications_created: insertedNotifications.length,
    fcm_sent: fcmResult.successCount,
    fcm_failed: fcmResult.failureCount
  })

  return new Response(
    JSON.stringify({
      success: true,
      message: `تم إرسال ${insertedNotifications.length} إشعار بنجاح`,
      data: {
        notifications_created: insertedNotifications.length,
        target_users: targetUsers.length,
        fcm_result: fcmResult
      }
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle get statistics
async function handleGetStats(req: Request, adminUser: any) {
  // Total notifications
  const { count: totalNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })

  // Read notifications
  const { count: readNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('is_read', true)

  // FCM sent notifications
  const { count: fcmSentNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .not('fcm_message_id', 'is', null)

  // Notifications by type
  const { data: typeBreakdown } = await supabase
    .from('notifications')
    .select('notification_type')

  const notificationsByType: Record<string, number> = {}
  typeBreakdown?.forEach((notification: any) => {
    const type = notification.notification_type || 'general'
    notificationsByType[type] = (notificationsByType[type] || 0) + 1
  })

  // Recent notifications (last 7 days)
  const sevenDaysAgo = new Date()
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)
  
  const { count: recentNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .gte('created_at', sevenDaysAgo.toISOString())

  // Log admin action
  await logAdminAction(adminUser.id, 'view_stats', {})

  return new Response(
    JSON.stringify({
      success: true,
      data: {
        total_notifications: totalNotifications || 0,
        read_notifications: readNotifications || 0,
        fcm_sent_notifications: fcmSentNotifications || 0,
        recent_notifications: recentNotifications || 0,
        open_rate: totalNotifications ? ((readNotifications || 0) / totalNotifications * 100).toFixed(2) : '0',
        fcm_delivery_rate: totalNotifications ? ((fcmSentNotifications || 0) / totalNotifications * 100).toFixed(2) : '0',
        notifications_by_type: notificationsByType
      }
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle delete notification
async function handleDeleteNotification(req: Request, adminUser: any) {
  if (req.method !== 'DELETE') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  const url = new URL(req.url)
  const notificationId = url.searchParams.get('notification_id')

  if (!notificationId) {
    throw new Error('notification_id is required')
  }

  const { error } = await supabase
    .from('notifications')
    .delete()
    .eq('id', notificationId)

  if (error) {
    throw new Error(`Failed to delete notification: ${error.message}`)
  }

  // Log admin action
  await logAdminAction(adminUser.id, 'delete_notification', {
    notification_id: notificationId
  })

  return new Response(
    JSON.stringify({
      success: true,
      message: 'تم حذف الإشعار بنجاح'
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle mark notification as read
async function handleMarkRead(req: Request, adminUser: any) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  const body = await req.json()
  const { notification_id } = body

  if (!notification_id) {
    throw new Error('notification_id is required')
  }

  const { error } = await supabase
    .from('notifications')
    .update({
      is_read: true,
      read_at: new Date().toISOString()
    })
    .eq('id', notification_id)

  if (error) {
    throw new Error(`Failed to mark notification as read: ${error.message}`)
  }

  return new Response(
    JSON.stringify({
      success: true,
      message: 'تم تحديث حالة الإشعار بنجاح'
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// FCM notification sending function
async function sendFCMNotification({
  userIds,
  title,
  body,
  data,
  notificationId
}: {
  userIds: string[]
  title: string
  body: string
  data: Record<string, any>
  notificationId?: string
}): Promise<{
  success: boolean
  successCount: number
  failureCount: number
  fcmMessageId?: string
  errors: string[]
}> {
  try {
    console.log(`📱 Sending FCM to ${userIds.length} users`)

    // Get FCM tokens for users
    const { data: fcmTokens, error: tokenError } = await supabase
      .from('user_fcm_tokens')
      .select('user_id, fcm_token, device_type')
      .in('user_id', userIds)
      .eq('is_active', true)

    if (tokenError) {
      console.error('Error fetching FCM tokens:', tokenError)
      return {
        success: false,
        successCount: 0,
        failureCount: userIds.length,
        errors: [tokenError.message]
      }
    }

    if (!fcmTokens || fcmTokens.length === 0) {
      console.log('No FCM tokens found for users')
      return {
        success: false,
        successCount: 0,
        failureCount: userIds.length,
        errors: ['No FCM tokens found']
      }
    }

    console.log(`📲 Found ${fcmTokens.length} FCM tokens`)

    // Get Firebase access token
    const accessToken = await getFirebaseAccessToken(firebasePrivateKey!, firebaseClientEmail!)
    if (!accessToken) {
      return {
        success: false,
        successCount: 0,
        failureCount: userIds.length,
        errors: ['Failed to get Firebase access token']
      }
    }

    // Send to each token
    let successCount = 0
    let failureCount = 0
    const errors: string[] = []
    let fcmMessageId: string | undefined

    for (const tokenData of fcmTokens) {
      try {
        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
          {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${accessToken}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              message: {
                token: tokenData.fcm_token,
                notification: {
                  title,
                  body,
                },
                data: {
                  ...data,
                  notification_id: notificationId || '',
                  click_action: 'FLUTTER_NOTIFICATION_CLICK'
                },
                android: {
                  priority: 'high',
                  notification: {
                    sound: 'default',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK'
                  }
                },
                apns: {
                  payload: {
                    aps: {
                      sound: 'default',
                      badge: 1
                    }
                  }
                }
              }
            })
          }
        )

        if (response.ok) {
          const result = await response.json()
          successCount++
          if (!fcmMessageId) {
            fcmMessageId = result.name
          }
          console.log(`✅ FCM sent to ${tokenData.user_id}`)
        } else {
          const errorText = await response.text()
          failureCount++
          errors.push(`Failed for ${tokenData.user_id}: ${errorText}`)
          console.error(`❌ FCM failed for ${tokenData.user_id}:`, errorText)
        }
      } catch (error: any) {
        failureCount++
        errors.push(`Exception for ${tokenData.user_id}: ${error.message}`)
        console.error(`❌ FCM exception for ${tokenData.user_id}:`, error)
      }
    }

    return {
      success: successCount > 0,
      successCount,
      failureCount,
      fcmMessageId,
      errors
    }

  } catch (error: any) {
    console.error('FCM sending error:', error)
    return {
      success: false,
      successCount: 0,
      failureCount: userIds.length,
      errors: [error.message]
    }
  }
}

// Log admin actions
async function logAdminAction(adminId: string, action: string, details: any) {
  try {
    await supabase
      .from('user_logs')
      .insert({
        user_id: adminId,
        action: `admin_${action}`,
        details: details,
        ip_address: null, // Would need to extract from request
        user_agent: null, // Would need to extract from request
        created_at: new Date().toISOString()
      })
  } catch (error) {
    console.error('Failed to log admin action:', error)
    // Don't throw - logging failure shouldn't break the main operation
  }
}