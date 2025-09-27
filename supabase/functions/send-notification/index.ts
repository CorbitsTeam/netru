import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Allow CORS
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-admin-secret"
};

// Init Supabase with service_role key
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"); // ✅
const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

// FCM Config
const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");
const fcmUrl = "https://fcm.googleapis.com/fcm/send";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 🔑 تحقق أن اللي بينادي هو الأدمن
    const adminSecret = req.headers.get("x-admin-secret");
    if (adminSecret !== Deno.env.get("ADMIN_SECRET")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 📥 استقبل البيانات
    const { user_ids = [], governorate, user_type, send_to_all = false, notification } = await req.json();

    let targetTokens: string[] = [];
    let targetUserIds: string[] = [];

    // حدد مين هيستقبل الإشعارات
    if (send_to_all) {
      const { data: tokens } = await supabase
        .from("user_fcm_tokens")
        .select("fcm_token, user_id")
        .eq("is_active", true);
      tokens?.forEach((t) => {
        targetTokens.push(t.fcm_token);
        targetUserIds.push(t.user_id);
      });
    } else if (governorate) {
      const { data: users } = await supabase
        .from("users")
        .select("id, user_fcm_tokens!inner(fcm_token)")
        .eq("governorate", governorate)
        .eq("user_fcm_tokens.is_active", true);
      users?.forEach((u) => {
        targetUserIds.push(u.id);
        u.user_fcm_tokens.forEach((t: any) => targetTokens.push(t.fcm_token));
      });
    } else if (user_type) {
      const { data: users } = await supabase
        .from("users")
        .select("id, user_fcm_tokens!inner(fcm_token)")
        .eq("user_type", user_type)
        .eq("user_fcm_tokens.is_active", true);
      users?.forEach((u) => {
        targetUserIds.push(u.id);
        u.user_fcm_tokens.forEach((t: any) => targetTokens.push(t.fcm_token));
      });
    } else if (user_ids.length > 0) {
      const { data: tokens } = await supabase
        .from("user_fcm_tokens")
        .select("fcm_token, user_id")
        .in("user_id", user_ids)
        .eq("is_active", true);
      tokens?.forEach((t) => {
        targetTokens.push(t.fcm_token);
        targetUserIds.push(t.user_id);
      });
    }

    // شيل الدوبلكيت
    targetTokens = [...new Set(targetTokens)];
    targetUserIds = [...new Set(targetUserIds)];

    if (targetTokens.length === 0) {
      return new Response(JSON.stringify({ success: false, error: "No tokens found" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 📤 ابني الـ payload
    const fcmPayload = {
      registration_ids: targetTokens,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: {
        ...notification.data,
        timestamp: new Date().toISOString(),
      },
    };

    // 🔥 بعت لـ FCM
    const fcmResponse = await fetch(fcmUrl, {
      method: "POST",
      headers: {
        "Authorization": `key=${fcmServerKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(fcmPayload),
    });

    const fcmResult = await fcmResponse.json();

    // 💾 خزّن في قاعدة البيانات
    const notificationsToSave = targetUserIds.map((uid) => ({
      user_id: uid,
      title: notification.title,
      body: notification.body,
      notification_type: notification.data?.type || "general",
      data: notification.data || {},
      is_sent: true,
      sent_at: new Date().toISOString(),
    }));

    await supabase.from("notifications").insert(notificationsToSave);

    return new Response(JSON.stringify({ success: true, fcm_result: fcmResult, saved: notificationsToSave.length }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (err) {
    console.error("❌ Error in send-notification:", err);
    return new Response(JSON.stringify({ success: false, error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

