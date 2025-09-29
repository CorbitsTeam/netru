import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
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

    // Set the auth token
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

    const { reportId, assignedTo, assignmentNotes } = await req.json()

    // Start transaction
    const { data: assignment, error: assignError } = await supabaseClient
      .from('report_assignments')
      .insert({
        report_id: reportId,
        assigned_to: assignedTo,
        assigned_by: user.id,
        assignment_notes: assignmentNotes,
        is_active: true
      })
      .select()
      .single()

    if (assignError) {
      throw assignError
    }

    // Update report assigned_to field
    const { error: updateError } = await supabaseClient
      .from('reports')
      .update({ 
        assigned_to: assignedTo,
        updated_at: new Date().toISOString()
      })
      .eq('id', reportId)

    if (updateError) {
      throw updateError
    }

    // Add status history entry - Update to use new status values
    const { error: historyError } = await supabaseClient
      .from('report_status_history')
      .insert({
        report_id: reportId,
        previous_status: null,
        new_status: 'under_review', // Updated to match new AdminReportStatus
        changed_by: user.id,
        change_reason: 'Report assigned to investigator for review',
        notes: assignmentNotes
      })

    if (historyError) {
      throw historyError
    }

    // Log admin action
    await supabaseClient
      .from('user_logs')
      .insert({
        user_id: user.id,
        action: `Assigned report ${reportId} to user ${assignedTo}`,
        ip_address: req.headers.get('x-forwarded-for')
      })

    // Create notification for assigned user
    const { data: assignedUser } = await supabaseClient
      .from('users')
      .select('full_name')
      .eq('id', assignedTo)
      .single()

    await supabaseClient
      .from('notifications')
      .insert({
        user_id: assignedTo,
        title: 'New Report Assignment',
        title_ar: 'تكليف تقرير جديد',
        body: `You have been assigned a new report for investigation`,
        body_ar: `تم تكليفك بتحقيق في تقرير جديد`,
        notification_type: 'report_update',
        reference_id: reportId,
        reference_type: 'report',
        data: {
          report_id: reportId,
          assignment_id: assignment.id
        }
      })

    return new Response(
      JSON.stringify({ 
        success: true, 
        assignment,
        message: `Report assigned to ${assignedUser?.full_name || assignedTo}` 
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