import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        auth: {
          persistSession: false,
        },
      }
    )

    // Get the authorization header from the request
    const authHeader = req.headers.get('authorization')!
    const token = authHeader.replace('Bearer ', '')

    await supabaseClient.auth.setSession({
      access_token: token,
      refresh_token: '',
    })

    // Verify user is admin
    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { data: userData } = await supabaseClient
      .from('users')
      .select('user_type')
      .eq('id', user.id)
      .single()

    if (userData?.user_type !== 'admin') {
      return new Response(
        JSON.stringify({ error: 'Admin access required' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { 
      title, 
      titleAr, 
      body, 
      bodyAr, 
      targetType, // 'all', 'governorate', 'user_type', 'specific_users'
      targetValue, // governorate name, user_type value, or array of user_ids
      notificationType = 'general',
      priority = 'normal',
      data = {}
    } = await req.json()

    let targetUsers = []

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
        throw new Error('Invalid target type')
    }

    if (targetUsers.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No target users found' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create notifications for all target users
    const notifications = targetUsers.map(targetUser => ({
      user_id: targetUser.id,
      title,
      title_ar: titleAr,
      body,
      body_ar: bodyAr,
      notification_type: notificationType,
      priority,
      data
    }))

    const { data: createdNotifications, error: notificationError } = await supabaseClient
      .from('notifications')
      .insert(notifications)
      .select()

    if (notificationError) {
      throw notificationError
    }

    // Get FCM tokens for push notifications
    const { data: fcmTokens } = await supabaseClient
      .from('user_fcm_tokens')
      .select('fcm_token, user_id, device_type')
      .in('user_id', targetUsers.map(u => u.id))
      .eq('is_active', true)

    // Send FCM push notifications (simplified version)
    const fcmResults = []
    for (const tokenData of fcmTokens || []) {
      try {
        // Here you would integrate with FCM SDK
        // This is a placeholder for the actual FCM implementation
        const fcmPayload = {
          to: tokenData.fcm_token,
          notification: {
            title: title,
            body: body,
          },
          data: {
            ...data,
            notification_type: notificationType,
            priority
          }
        }
        
        // Simulate FCM response
        fcmResults.push({
          user_id: tokenData.user_id,
          token: tokenData.fcm_token,
          success: true,
          message_id: `msg_${Date.now()}_${Math.random()}`
        })
      } catch (error) {
        fcmResults.push({
          user_id: tokenData.user_id,
          token: tokenData.fcm_token,
          success: false,
          error: error.message
        })
      }
    }

    // Update notifications with sent status
    const successfulTokens = fcmResults.filter(r => r.success).map(r => r.user_id)
    if (successfulTokens.length > 0) {
      await supabaseClient
        .from('notifications')
        .update({ 
          is_sent: true, 
          sent_at: new Date().toISOString() 
        })
        .in('user_id', successfulTokens)
        .in('id', createdNotifications.map(n => n.id))
    }

    // Log admin action
    await supabaseClient
      .from('user_logs')
      .insert({
        user_id: user.id,
        action: `Sent bulk notification to ${targetUsers.length} users (${targetType}: ${targetValue})`,
        ip_address: req.headers.get('x-forwarded-for')
      })

    return new Response(
      JSON.stringify({ 
        success: true,
        notifications_created: createdNotifications.length,
        fcm_results: fcmResults,
        target_users: targetUsers.length,
        successful_sends: fcmResults.filter(r => r.success).length
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      }
    )
  }
})