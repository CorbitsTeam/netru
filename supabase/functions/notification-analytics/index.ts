// ============================================
// Notification Analytics Edge Function
// ============================================
// This function provides detailed analytics for notifications
// Path: supabase/functions/notification-analytics/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Initialize Supabase client
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!
const supabase = createClient(supabaseUrl, supabaseAnonKey)

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
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

  } catch (error: any) {
    console.error('❌ Analytics error:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Analytics processing failed'
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})

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

  // Scheduled notifications
  const { count: scheduledNotifications } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('is_sent', false)
    .not('sent_at', 'is', null)
    .gte('created_at', dateFilter.start)
    .lte('created_at', dateFilter.end)

  // Failed notifications
  const { count: failedNotifications } = await supabase
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

  // Calculate rates
  const deliveryRate = totalNotifications ? (sentNotifications! / totalNotifications!) * 100 : 0
  const openRate = sentNotifications ? (readNotifications! / sentNotifications!) * 100 : 0

  return {
    total_notifications: totalNotifications || 0,
    sent_notifications: sentNotifications || 0,
    scheduled_notifications: scheduledNotifications || 0,
    failed_notifications: failedNotifications || 0,
    read_notifications: readNotifications || 0,
    delivery_rate: Math.round(deliveryRate * 100) / 100,
    open_rate: Math.round(openRate * 100) / 100,
    click_rate: 0, // Would need additional tracking
  }
}

// Daily statistics
async function getDailyStats(startDate?: string | null, endDate?: string | null) {
  const dateFilter = buildDateFilter(startDate, endDate)

  const { data: dailyStats } = await supabase
    .rpc('get_daily_notification_stats', {
      start_date: dateFilter.start,
      end_date: dateFilter.end
    })

  return dailyStats || []
}

// Hourly statistics for today
async function getHourlyStats(startDate?: string | null, endDate?: string | null) {
  const dateFilter = buildDateFilter(startDate, endDate, 'today')

  const { data: hourlyStats } = await supabase
    .rpc('get_hourly_notification_stats', {
      target_date: dateFilter.start.split('T')[0]
    })

  return hourlyStats || []
}

// Governorate breakdown
async function getGovernorateStats(startDate?: string | null, endDate?: string | null) {
  const dateFilter = buildDateFilter(startDate, endDate)

  const { data: governorateStats } = await supabase
    .from('notifications')
    .select(`
      user_id,
      users!inner (governorate),
      is_sent,
      is_read
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

  return stats
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