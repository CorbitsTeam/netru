/// <reference types="https://esm.sh/@types/web@0.0.99/index.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-admin-secret',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          persistSession: false,
        },
      }
    )

    // Check admin secret authentication (bypass Supabase Auth completely)
    const adminSecret = req.headers.get('x-admin-secret')
    const expectedAdminSecret = Deno.env.get('ADMIN_SECRET') || 'netru-admin-2025'
    
    if (!adminSecret || adminSecret !== expectedAdminSecret) {
      console.error('❌ Admin secret authentication failed')
      return new Response(
        JSON.stringify({ error: 'Unauthorized - Invalid admin secret' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    
    console.log('✅ Admin secret authentication successful')

    const requestData = await req.json()
    const { 
      title, 
      titleAr, 
      body, 
      bodyAr, 
      targetType, // 'all', 'governorate', 'user_type', 'specific_users'
      targetValue, // governorate name, user_type value, or array of user_ids
      notificationType = 'general',
      priority = 'normal',
      data = {},
      userIds = [] // Direct user IDs for backward compatibility
    } = requestData

    let targetUsers = []

    // Handle direct userIds (backward compatibility)
    if (userIds && userIds.length > 0) {
      targetUsers = userIds.map(id => ({ id }))
    } else {
      // Build target user list based on targetType
      switch (targetType) {
        case 'all':
          const { data: allUsers } = await supabaseClient
            .from('users')
            .select('id')
          targetUsers = allUsers || []
          break
          
        case 'governorate':
          const { data: govUsers } = await supabaseClient
            .from('users')
            .select('id')
            .eq('governorate', targetValue)
          targetUsers = govUsers || []
          break
          
        case 'user_type':
          const { data: typeUsers } = await supabaseClient
            .from('users')
            .select('id')
            .eq('user_type', targetValue)
          targetUsers = typeUsers || []
          break
          
        case 'specific_users':
          targetUsers = Array.isArray(targetValue) 
            ? targetValue.map(id => ({ id }))
            : [{ id: targetValue }]
          break
          
        default:
          throw new Error('Invalid target type or missing userIds')
      }
    }

    if (targetUsers.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No target users found' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`📱 Sending notifications to ${targetUsers.length} users`)

    // First, create an admin notification record
    const { data: adminNotification, error: adminNotificationError } = await supabaseClient
      .from('admin_notifications')
      .insert({
        title: title,
        title_ar: titleAr,
        body: body,
        body_ar: bodyAr,
        type: notificationType,
        priority: priority,
        target_type: targetType,
        target_value: targetValue,
        data: data,
        created_by: 'admin', // Since we're using admin secret authentication
        status: 'sent',
        sent_count: targetUsers.length,
        sent_at: new Date().toISOString()
      })
      .select()
      .single()

    if (adminNotificationError) {
      throw adminNotificationError
    }

    console.log(`📝 Created admin notification record: ${adminNotification.id}`)

    // Create notifications for all target users
    const notifications = targetUsers.map(targetUser => ({
      user_id: targetUser.id,
      title: title,
      title_ar: titleAr,
      body: body,
      body_ar: bodyAr,
      notification_type: notificationType,
      priority: priority,
      data: data,
      is_read: false,
      is_sent: false,
      admin_notification_id: adminNotification.id,
      created_at: new Date().toISOString()
    }))

    const { data: createdNotifications, error: notificationError } = await supabaseClient
      .from('notifications')
      .insert(notifications)
      .select()

    if (notificationError) {
      throw notificationError
    }

    console.log(`📝 Created ${createdNotifications.length} user notifications`)

    // Get FCM tokens for push notifications
    const { data: fcmTokens } = await supabaseClient
      .from('user_fcm_tokens')
      .select('fcm_token, user_id, device_type')
      .in('user_id', targetUsers.map(u => u.id))
      .eq('is_active', true)

    console.log(`🔑 Found ${fcmTokens?.length || 0} active FCM tokens`)

    // Send FCM push notifications using Firebase Admin SDK
    const fcmResults = []
    const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')
    
    for (const tokenData of fcmTokens || []) {
      try {
        if (!FCM_SERVER_KEY) {
          console.warn('⚠️ FCM_SERVER_KEY not configured, skipping push notification')
          fcmResults.push({
            user_id: tokenData.user_id,
            token: tokenData.fcm_token,
            success: false,
            error: 'FCM server key not configured'
          })
          continue
        }

        const fcmPayload = {
          to: tokenData.fcm_token,
          notification: {
            title: title,
            body: body,
            sound: 'default',
            badge: '1'
          },
          data: {
            ...data,
            notification_type: notificationType,
            priority: priority,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          },
          android: {
            notification: {
              channel_id: 'default_channel',
              icon: 'ic_notification',
              color: '#2196F3'
            }
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
                'content-available': 1
              }
            }
          }
        }

        // Send FCM request
        const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
          method: 'POST',
          headers: {
            'Authorization': `key=${FCM_SERVER_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(fcmPayload),
        })

        const fcmResult = await fcmResponse.json()

        if (fcmResponse.ok && fcmResult.success === 1) {
          fcmResults.push({
            user_id: tokenData.user_id,
            token: tokenData.fcm_token,
            success: true,
            message_id: fcmResult.results?.[0]?.message_id || `msg_${Date.now()}`
          })
          console.log(`✅ FCM sent successfully to user ${tokenData.user_id}`)
        } else {
          fcmResults.push({
            user_id: tokenData.user_id,
            token: tokenData.fcm_token,
            success: false,
            error: fcmResult.results?.[0]?.error || fcmResult.error || 'Unknown FCM error'
          })
          console.error(`❌ FCM failed for user ${tokenData.user_id}:`, fcmResult)
        }
      } catch (error: any) {
        fcmResults.push({
          user_id: tokenData.user_id,
          token: tokenData.fcm_token,
          success: false,
          error: error?.message || 'Unknown FCM error'
        })
        console.error(`❌ FCM error for user ${tokenData.user_id}:`, error)
      }
    }

    // Update notifications with sent status
    const successfulTokens = fcmResults.filter(r => r.success).map(r => r.user_id)
    const failedTokens = fcmResults.filter(r => !r.success).map(r => r.user_id)
    
    if (successfulTokens.length > 0) {
      await supabaseClient
        .from('notifications')
        .update({ 
          is_sent: true, 
          sent_at: new Date().toISOString() 
        })
        .in('user_id', successfulTokens)
        .eq('admin_notification_id', adminNotification.id)
      
      console.log(`✅ Updated ${successfulTokens.length} notifications as sent`)
    }

    // Update admin notification statistics
    await supabaseClient
      .from('admin_notifications')
      .update({
        delivered_count: successfulTokens.length,
        failed_count: failedTokens.length,
        status: successfulTokens.length > 0 ? 'sent' : 'failed'
      })
      .eq('id', adminNotification.id)

    // Log admin action (we know it's admin because we checked the secret)
    await supabaseClient
      .from('user_logs')
      .insert({
        user_id: 'admin', // Generic admin identifier since we're using secret auth
        action: `Sent bulk notification to ${targetUsers.length} users`,
        ip_address: req.headers.get('x-forwarded-for') || 'unknown'
      })

    const response = {
      success: true,
      notifications_created: createdNotifications.length,
      fcm_results: fcmResults,
      target_users: targetUsers.length,
      successful_sends: fcmResults.filter(r => r.success).length,
      failed_sends: fcmResults.filter(r => !r.success).length,
      summary: {
        total_notifications: createdNotifications.length,
        total_tokens: fcmTokens?.length || 0,
        successful_deliveries: fcmResults.filter(r => r.success).length,
        failed_deliveries: fcmResults.filter(r => !r.success).length,
      }
    }

    console.log('📊 Final Results:', response.summary)

    return new Response(
      JSON.stringify(response),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error: any) {
    console.error('❌ Bulk notification error:', error)
    return new Response(
      JSON.stringify({ 
        error: error?.message || 'Unknown error',
        details: error?.stack || 'No stack trace available'
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      }
    )
  }
})