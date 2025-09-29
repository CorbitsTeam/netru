// ============================================
// Admin Notification Management Edge Function
// ============================================
// This function provides admin notification management and analytics
// Path: supabase/functions/notification-analytics/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
}

// Initialize Supabase client
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!
const supabase = createClient(supabaseUrl, supabaseAnonKey)

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const url = new URL(req.url)
    const action = url.searchParams.get('action') || 'analytics'
    
    // Route based on action
    switch (action) {
      case 'analytics':
        return await handleAnalytics(req)
      case 'get_notifications':
        return await handleGetNotifications(req)
      case 'send_bulk':
        return await handleSendBulk(req)
      case 'create_notification':
        return await handleCreateNotification(req)
      case 'delete_notification':
        return await handleDeleteNotification(req)
      case 'mark_read':
        return await handleMarkRead(req)
      case 'get_governorates':
        return await handleGetGovernorates(req)
      case 'schedule_notification':
        return await handleScheduleNotification(req)
      case 'get_scheduled':
        return await handleGetScheduled(req)
      case 'cancel_scheduled':
        return await handleCancelScheduled(req)
      default:
        return await handleAnalytics(req)
    }

  } catch (error: any) {
    console.error('❌ Function error:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Function processing failed'
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})

// Handle analytics requests
async function handleAnalytics(req: Request) {
  const url = new URL(req.url)
  const type = url.searchParams.get('type') || 'overview'
  const startDate = url.searchParams.get('start_date')
  const endDate = url.searchParams.get('end_date')
  const governorate = url.searchParams.get('governorate')

  console.log('📊 Analytics request:', { type, startDate, endDate, governorate })

  let result: any = {}

  switch (type) {
    case 'overview':
      result = await getOverviewStats(startDate, endDate)
      break
    case 'daily':
      result = await getDailyStats(startDate, endDate)
      break
    case 'hourly':
      result = await getHourlyStats(startDate, endDate)
      break
    case 'governorate':
      result = await getGovernorateStats(startDate, endDate)
      break
    case 'type_breakdown':
      result = await getTypeBreakdown(startDate, endDate)
      break
    case 'delivery_rates':
      result = await getDeliveryRates(startDate, endDate, governorate)
      break
    default:
      result = await getOverviewStats(startDate, endDate)
  }

  return new Response(
    JSON.stringify({
      success: true,
      data: result,
      generated_at: new Date().toISOString()
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    }
  )
}

// Handle get all notifications
async function handleGetNotifications(req: Request) {
  const url = new URL(req.url)
  const page = parseInt(url.searchParams.get('page') || '1')
  const limit = parseInt(url.searchParams.get('limit') || '20')
  const type = url.searchParams.get('type')
  const priority = url.searchParams.get('priority')
  const status = url.searchParams.get('status')
  const search = url.searchParams.get('search')
  const userId = url.searchParams.get('user_id')

  let query = supabase
    .from('notifications')
    .select(`
      *,
      users!inner (
        id,
        full_name,
        username,
        governorate,
        user_type
      )
    `)
    .order('created_at', { ascending: false })

  // Apply filters
  if (type) {
    query = query.eq('notification_type', type)
  }
  
  if (priority) {
    query = query.eq('priority', priority)
  }

  if (status) {
    switch (status) {
      case 'sent':
        query = query.eq('is_sent', true)
        break
      case 'scheduled':
        query = query.eq('is_sent', false).not('sent_at', 'is', null)
        break
      case 'draft':
        query = query.eq('is_sent', false).is('sent_at', null)
        break
      case 'failed':
        query = query.eq('is_sent', false).is('sent_at', null)
        break
    }
  }

  if (search) {
    query = query.or(`title.ilike.%${search}%,body.ilike.%${search}%`)
  }

  if (userId) {
    query = query.eq('user_id', userId)
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
  if (priority) countQuery = countQuery.eq('priority', priority)
  if (search) countQuery = countQuery.or(`title.ilike.%${search}%,body.ilike.%${search}%`)
  if (userId) countQuery = countQuery.eq('user_id', userId)

  const { count: totalCount } = await countQuery

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
      }
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle bulk notification sending
async function handleSendBulk(req: Request) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  const body = await req.json()
  const {
    title,
    title_ar,
    body: messageBody,
    body_ar,
    notification_type = 'general',
    priority = 'normal',
    target_type,
    target_value,
    data
  } = body

  console.log('📤 Bulk notification request:', { title, target_type, target_value })

  // Get target users based on target_type
  let userIds: string[] = []

  switch (target_type) {
    case 'all':
      const { data: allUsers } = await supabase
        .from('users')
        .select('id')
      userIds = allUsers?.map((user: any) => user.id) || []
      break

    case 'governorate':
      const { data: govUsers } = await supabase
        .from('users')
        .select('id')
        .eq('governorate', target_value)
      userIds = govUsers?.map((user: any) => user.id) || []
      break

    case 'user_type':
      const { data: typeUsers } = await supabase
        .from('users')
        .select('id')
        .eq('user_type', target_value)
      userIds = typeUsers?.map((user: any) => user.id) || []
      break

    case 'specific_users':
      userIds = Array.isArray(target_value) ? target_value : [target_value]
      break

    default:
      throw new Error('Invalid target type')
  }

  if (userIds.length === 0) {
    throw new Error('No users found for the specified target')
  }

  // Create notifications for all target users
  const notifications = userIds.map(userId => ({
    user_id: userId,
    title,
    title_ar,
    body: messageBody,
    body_ar,
    notification_type,
    priority,
    data,
    is_sent: true,
    is_read: false,
    sent_at: new Date().toISOString(),
    created_at: new Date().toISOString()
  }))

  // Insert notifications in batches to avoid payload limits
  const batchSize = 100
  let insertedCount = 0
  const insertedNotifications: any[] = []

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

    insertedCount += batch.length
    if (insertedBatch) {
      insertedNotifications.push(...insertedBatch)
    }
  }

  // Send FCM notifications for immediate delivery
  try {
    await sendFCMNotifications(userIds, {
      title,
      body: messageBody,
      data: data || {}
    })
  } catch (fcmError) {
    console.error('FCM sending error:', fcmError)
    // Continue even if FCM fails, as we've saved to database
  }

  return new Response(
    JSON.stringify({
      success: true,
      message: `تم إرسال ${insertedCount} إشعار بنجاح`,
      recipient_count: insertedCount,
      target_users: userIds.length
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle single notification creation
async function handleCreateNotification(req: Request) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  const body = await req.json()
  const {
    user_id,
    title,
    title_ar,
    body: messageBody,
    body_ar,
    notification_type = 'general',
    priority = 'normal',
    reference_id,
    reference_type,
    data
  } = body

  const { data: notification, error } = await supabase
    .from('notifications')
    .insert({
      user_id,
      title,
      title_ar,
      body: messageBody,
      body_ar,
      notification_type,
      priority,
      reference_id,
      reference_type,
      data,
      is_sent: true,
      is_read: false,
      sent_at: new Date().toISOString(),
      created_at: new Date().toISOString()
    })
    .select()
    .single()

  if (error) {
    throw new Error(`Failed to create notification: ${error.message}`)
  }

  return new Response(
    JSON.stringify({
      success: true,
      message: 'تم إنشاء الإشعار بنجاح',
      data: notification
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle notification deletion
async function handleDeleteNotification(req: Request) {
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

  return new Response(
    JSON.stringify({
      success: true,
      message: 'تم حذف الإشعار بنجاح'
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle mark notification as read
async function handleMarkRead(req: Request) {
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

// Handle get governorates list
async function handleGetGovernorates(req: Request) {
  const { data: governorates, error } = await supabase
    .from('governorates')
    .select('name')
    .order('name')

  if (error) {
    throw new Error(`Failed to fetch governorates: ${error.message}`)
  }

  const governoratesList = governorates?.map((gov: any) => gov.name) || []

  return new Response(
    JSON.stringify({
      success: true,
      data: governoratesList
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle schedule notification
async function handleScheduleNotification(req: Request) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  const body = await req.json()
  const {
    title,
    title_ar,
    body: messageBody,
    body_ar,
    notification_type = 'general',
    priority = 'normal',
    target_type,
    target_value,
    scheduled_at,
    data
  } = body

  console.log('📅 Schedule notification request:', { title, target_type, scheduled_at })

  // Get target users based on target_type
  let userIds: string[] = []

  switch (target_type) {
    case 'all':
      const { data: allUsers } = await supabase
        .from('users')
        .select('id')
      userIds = allUsers?.map((user: any) => user.id) || []
      break

    case 'governorate':
      const { data: govUsers } = await supabase
        .from('users')
        .select('id')
        .eq('governorate', target_value)
      userIds = govUsers?.map((user: any) => user.id) || []
      break

    case 'user_type':
      const { data: typeUsers } = await supabase
        .from('users')
        .select('id')
        .eq('user_type', target_value)
      userIds = typeUsers?.map((user: any) => user.id) || []
      break

    case 'specific_users':
      userIds = Array.isArray(target_value) ? target_value : [target_value]
      break

    default:
      throw new Error('Invalid target type')
  }

  if (userIds.length === 0) {
    throw new Error('No users found for the specified target')
  }

  // Create scheduled notifications
  const notifications = userIds.map(userId => ({
    user_id: userId,
    title,
    title_ar,
    body: messageBody,
    body_ar,
    notification_type,
    priority,
    data,
    is_sent: false,
    is_read: false,
    sent_at: scheduled_at,
    created_at: new Date().toISOString()
  }))

  // Insert scheduled notifications
  const { data: insertedNotifications, error } = await supabase
    .from('notifications')
    .insert(notifications)
    .select()

  if (error) {
    throw new Error(`Failed to schedule notifications: ${error.message}`)
  }

  return new Response(
    JSON.stringify({
      success: true,
      message: `تم جدولة ${userIds.length} إشعار للإرسال في ${new Date(scheduled_at).toLocaleString('ar-EG')}`,
      scheduled_count: userIds.length,
      scheduled_at
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle get scheduled notifications
async function handleGetScheduled(req: Request) {
  const { data: scheduledNotifications, error } = await supabase
    .from('notifications')
    .select(`
      *,
      users!inner (
        full_name,
        username,
        governorate
      )
    `)
    .eq('is_sent', false)
    .not('sent_at', 'is', null)
    .gte('sent_at', new Date().toISOString())
    .order('sent_at', { ascending: true })

  if (error) {
    throw new Error(`Failed to fetch scheduled notifications: ${error.message}`)
  }

  return new Response(
    JSON.stringify({
      success: true,
      data: scheduledNotifications || []
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Handle cancel scheduled notification
async function handleCancelScheduled(req: Request) {
  if (req.method !== 'DELETE') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  const url = new URL(req.url)
  const notificationId = url.searchParams.get('notification_id')

  if (!notificationId) {
    throw new Error('notification_id is required')
  }

  // Check if notification is scheduled and not sent yet
  const { data: notification, error: fetchError } = await supabase
    .from('notifications')
    .select('is_sent, sent_at')
    .eq('id', notificationId)
    .single()

  if (fetchError) {
    throw new Error(`Failed to fetch notification: ${fetchError.message}`)
  }

  if (notification.is_sent) {
    throw new Error('Cannot cancel a notification that has already been sent')
  }

  const { error } = await supabase
    .from('notifications')
    .delete()
    .eq('id', notificationId)

  if (error) {
    throw new Error(`Failed to cancel scheduled notification: ${error.message}`)
  }

  return new Response(
    JSON.stringify({
      success: true,
      message: 'تم إلغاء الإشعار المجدول بنجاح'
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

// Overview statistics
async function getOverviewStats(startDate?: string | null, endDate?: string | null) {
  const dateFilter = buildDateFilter(startDate, endDate)

  // Total notifications
  const { count: totalNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // Sent notifications
  const { count: sentNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('is_sent', true)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // Scheduled notifications (drafts with scheduled time)
  const { count: scheduledNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('is_sent', false)
    .not('sent_at', 'is', null)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // Draft notifications
  const { count: draftNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('is_sent', false)
    .is('sent_at', null)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // Read notifications
  const { count: readNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('is_read', true)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // High priority notifications
  const { count: highPriorityNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .in('priority', ['high', 'urgent'])
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // Calculate rates
  const deliveryRate = totalNotifications ? (sentNotifications! / totalNotifications!) * 100 : 0
  const openRate = sentNotifications ? (readNotifications! / sentNotifications!) * 100 : 0

  // Get type breakdown
  const { data: typeData } = await supabase
    .from('notifications')
    .select('notification_type')
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  const notificationsByType: Record<string, number> = {}
  typeData?.forEach((notification: any) => {
    const type = notification.notification_type || 'general'
    notificationsByType[type] = (notificationsByType[type] || 0) + 1
  })

  // Get priority breakdown
  const { data: priorityData } = await supabase
    .from('notifications')
    .select('priority')
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  const notificationsByPriority: Record<string, number> = {}
  priorityData?.forEach((notification: any) => {
    const priority = notification.priority || 'normal'
    notificationsByPriority[priority] = (notificationsByPriority[priority] || 0) + 1
  })

  return {
    total_notifications: totalNotifications || 0,
    sent_notifications: sentNotifications || 0,
    scheduled_notifications: scheduledNotifications || 0,
    draft_notifications: draftNotifications || 0,
    failed_notifications: (totalNotifications || 0) - (sentNotifications || 0) - (scheduledNotifications || 0) - (draftNotifications || 0),
    read_notifications: readNotifications || 0,
    high_priority_notifications: highPriorityNotifications || 0,
    delivery_rate: Math.round(deliveryRate * 100) / 100,
    open_rate: Math.round(openRate * 100) / 100,
    click_rate: 0, // Would need additional tracking
    notifications_by_type: notificationsByType,
    notifications_by_priority: notificationsByPriority,
  }
}

// Daily statistics
async function getDailyStats(startDate?: string | null, endDate?: string | null) {
  const dateFilter = buildDateFilter(startDate, endDate)

  const { data: dailyStats } = await supabase
    .from('notifications')
    .select(`
      created_at,
      is_sent,
      is_read
    `)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)
    .order('created_at')

  // Group by date
  const statsMap: Record<string, any> = {}
  
  dailyStats?.forEach((notification: any) => {
    const date = new Date(notification.created_at).toISOString().split('T')[0]
    
    if (!statsMap[date]) {
      statsMap[date] = {
        date,
        sent: 0,
        delivered: 0,
        opened: 0,
        clicked: 0,
        failed: 0
      }
    }
    
    statsMap[date].delivered++
    if (notification.is_sent) {
      statsMap[date].sent++
    } else {
      statsMap[date].failed++
    }
    if (notification.is_read) {
      statsMap[date].opened++
    }
  })

  return Object.values(statsMap)
}

// Hourly statistics for specified date range
async function getHourlyStats(startDate?: string | null, endDate?: string | null) {
  const dateFilter = buildDateFilter(startDate, endDate, 'today')

  const { data: hourlyData } = await supabase
    .from('notifications')
    .select(`
      created_at,
      is_sent,
      is_read
    `)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // Group by hour
  const hourlyStats: Record<number, any> = {}
  
  for (let i = 0; i < 24; i++) {
    hourlyStats[i] = {
      hour: i,
      sent: 0,
      delivered: 0,
      delivery_rate: 0
    }
  }

  hourlyData?.forEach((notification: any) => {
    const hour = new Date(notification.created_at).getHours()
    
    hourlyStats[hour].delivered++
    if (notification.is_sent) {
      hourlyStats[hour].sent++
    }
  })

  // Calculate delivery rates
  Object.values(hourlyStats).forEach((stat: any) => {
    stat.delivery_rate = stat.delivered > 0 ? (stat.sent / stat.delivered) * 100 : 0
    stat.delivery_rate = Math.round(stat.delivery_rate * 100) / 100
  })

  return Object.values(hourlyStats)
}

// Governorate breakdown
async function getGovernorateStats(startDate?: string | null, endDate?: string | null) {
  const dateFilter = buildDateFilter(startDate, endDate)

  const { data: governorateStats } = await supabase
    .from('notifications')
    .select(`
      user_id,
      is_sent,
      is_read,
      users!inner (
        governorate
      )
    `)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // Process results to group by governorate
  const stats: Record<string, any> = {}
  
  governorateStats?.forEach((notification: any) => {
    const governorate = notification.users?.governorate || 'غير محدد'
    
    if (!stats[governorate]) {
      stats[governorate] = {
        total: 0,
        sent: 0,
        read: 0,
        delivery_rate: 0,
        open_rate: 0
      }
    }
    
    stats[governorate].total++
    if (notification.is_sent) stats[governorate].sent++
    if (notification.is_read) stats[governorate].read++
  })

  // Calculate rates
  Object.keys(stats).forEach(governorate => {
    const stat = stats[governorate]
    stat.delivery_rate = stat.total > 0 ? (stat.sent / stat.total) * 100 : 0
    stat.open_rate = stat.sent > 0 ? (stat.read / stat.sent) * 100 : 0
    stat.delivery_rate = Math.round(stat.delivery_rate * 100) / 100
    stat.open_rate = Math.round(stat.open_rate * 100) / 100
  })

  // Convert to array format for easier processing
  const deliveryRateByGovernorate: Record<string, number> = {}
  Object.keys(stats).forEach(governorate => {
    deliveryRateByGovernorate[governorate] = stats[governorate].delivery_rate
  })

  return {
    by_governorate: stats,
    delivery_rate_by_governorate: deliveryRateByGovernorate
  }
}

// Notification type breakdown
async function getTypeBreakdown(startDate?: string | null, endDate?: string | null) {
  const dateFilter = buildDateFilter(startDate, endDate)

  const { data: typeStats } = await supabase
    .from('notifications')
    .select('notification_type, is_sent, is_read')
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  const breakdown: Record<string, any> = {}
  
  typeStats?.forEach((notification: any) => {
    const type = notification.notification_type || 'general'
    
    if (!breakdown[type]) {
      breakdown[type] = {
        total: 0,
        sent: 0,
        read: 0
      }
    }
    
    breakdown[type].total++
    if (notification.is_sent) breakdown[type].sent++
    if (notification.is_read) breakdown[type].read++
  })

  return breakdown
}

// Delivery rates analysis
async function getDeliveryRates(
  startDate?: string | null, 
  endDate?: string | null,
  governorate?: string | null
) {
  const dateFilter = buildDateFilter(startDate, endDate)
  
  let query = supabase
    .from('notifications')
    .select(`
      created_at,
      is_sent,
      is_read,
      priority,
      users!inner (governorate, user_type)
    `)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  if (governorate) {
    query = query.eq('users.governorate', governorate)
  }

  const { data: notifications } = await query

  // Group by priority
  const priorityStats: Record<string, any> = {}
  
  notifications?.forEach((notification: any) => {
    const priority = notification.priority || 'normal'
    
    if (!priorityStats[priority]) {
      priorityStats[priority] = {
        total: 0,
        sent: 0,
        read: 0,
        delivery_rate: 0,
        open_rate: 0
      }
    }
    
    priorityStats[priority].total++
    if (notification.is_sent) priorityStats[priority].sent++
    if (notification.is_read) priorityStats[priority].read++
  })

  // Calculate rates
  Object.keys(priorityStats).forEach(priority => {
    const stat = priorityStats[priority]
    stat.delivery_rate = stat.total > 0 ? (stat.sent / stat.total) * 100 : 0
    stat.open_rate = stat.sent > 0 ? (stat.read / stat.sent) * 100 : 0
    stat.delivery_rate = Math.round(stat.delivery_rate * 100) / 100
    stat.open_rate = Math.round(stat.open_rate * 100) / 100
  })

  return {
    by_priority: priorityStats,
    total_analyzed: notifications?.length || 0
  }
}

// Helper function to build date filters
function buildDateFilter(
  startDate?: string | null, 
  endDate?: string | null,
  defaultRange: 'week' | 'month' | 'today' = 'month'
) {
  const now = new Date()
  let start: string
  let end: string

  if (startDate && endDate) {
    start = startDate
    end = endDate
  } else {
    switch (defaultRange) {
      case 'today':
        start = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString()
        end = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1).toISOString()
        break
      case 'week':
        start = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString()
        end = now.toISOString()
        break
      case 'month':
      default:
        start = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate()).toISOString()
        end = now.toISOString()
        break
    }
  }

  return { start, end }
}

// FCM notification sending helper function
async function sendFCMNotifications(userIds: string[], payload: {
  title: string
  body: string
  data: Record<string, any>
}) {
  // Get FCM tokens for users
  const { data: fcmTokens } = await supabase
    .from('user_fcm_tokens')
    .select('token')
    .in('user_id', userIds)
    .eq('is_active', true)

  if (!fcmTokens || fcmTokens.length === 0) {
    console.log('No FCM tokens found for users')
    return
  }

  const tokens = fcmTokens.map((tokenRecord: any) => tokenRecord.token)

  // Call FCM service (would need to implement FCM Admin SDK)
  console.log(`📱 Would send FCM to ${tokens.length} tokens:`, {
    title: payload.title,
    body: payload.body,
    tokens: tokens.length
  })

  // Note: Actual FCM implementation would go here
  // This would require Firebase Admin SDK setup
}