import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

// Allow CORS
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};

// Firebase Configuration for v1 API
const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID");
const firebaseServiceAccount = Deno.env.get("FIREBASE_SERVICE_ACCOUNT"); // JSON string
const fcmV1Url = `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`;

// JWT Helper for service account authentication
async function getAccessToken(): Promise<string | null> {
  try {
    console.log("🔑 Getting Firebase access token...");
    
    if (!firebaseServiceAccount) {
      console.error("❌ FIREBASE_SERVICE_ACCOUNT not configured");
      return null;
    }

    let serviceAccount;
    try {
      serviceAccount = JSON.parse(firebaseServiceAccount);
    } catch (parseError) {
      console.error("❌ Failed to parse FIREBASE_SERVICE_ACCOUNT JSON:", parseError);
      return null;
    }

    if (!serviceAccount.private_key || !serviceAccount.client_email) {
      console.error("❌ Invalid service account: missing private_key or client_email");
      return null;
    }

    console.log("✅ Service account parsed successfully");
    
    const now = Math.floor(Date.now() / 1000);
    const exp = now + 3600; // 1 hour

    // Create JWT header and payload
    const header = {
      alg: "RS256",
      typ: "JWT"
    };

    const payload = {
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: exp
    };

    // Encode header and payload to base64url
    const base64UrlEncode = (obj: any) => {
      return btoa(JSON.stringify(obj))
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
    };

    const encodedHeader = base64UrlEncode(header);
    const encodedPayload = base64UrlEncode(payload);
    const unsignedToken = `${encodedHeader}.${encodedPayload}`;

    // Convert PEM private key to proper format
    console.log("🔧 Processing private key...");
    const pemKey = serviceAccount.private_key;
    const pemHeader = "-----BEGIN PRIVATE KEY-----";
    const pemFooter = "-----END PRIVATE KEY-----";
    const pemContents = pemKey.replace(pemHeader, "").replace(pemFooter, "").replace(/\s/g, "");
    
    // Decode base64 private key
    let binaryDer;
    try {
      binaryDer = Uint8Array.from(atob(pemContents), c => c.charCodeAt(0));
      console.log("✅ Private key decoded successfully");
    } catch (decodeError) {
      console.error("❌ Failed to decode private key:", decodeError);
      return null;
    }

    // Import private key
    let privateKey;
    try {
      privateKey = await crypto.subtle.importKey(
        "pkcs8",
        binaryDer,
        {
          name: "RSASSA-PKCS1-v1_5",
          hash: "SHA-256"
        },
        false,
        ["sign"]
      );
      console.log("✅ Private key imported successfully");
    } catch (importError) {
      console.error("❌ Failed to import private key:", importError);
      return null;
    }

    // Sign the token
    let signature;
    try {
      signature = await crypto.subtle.sign(
        "RSASSA-PKCS1-v1_5",
        privateKey,
        new TextEncoder().encode(unsignedToken)
      );
      console.log("✅ Token signed successfully");
    } catch (signError) {
      console.error("❌ Failed to sign token:", signError);
      return null;
    }

    // Convert signature to base64url
    const signatureArray = new Uint8Array(signature);
    const signatureB64 = btoa(String.fromCharCode(...signatureArray))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
    
    const jwt = `${unsignedToken}.${signatureB64}`;
    console.log("✅ JWT created successfully");

    // Exchange JWT for access token
    console.log("🔄 Exchanging JWT for access token...");
    const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt
      })
    });

    if (!tokenResponse.ok) {
      const errorText = await tokenResponse.text();
      console.error("❌ Failed to get access token:", tokenResponse.status, errorText);
      return null;
    }

    const tokenData = await tokenResponse.json();
    console.log("✅ Access token obtained successfully");
    return tokenData.access_token;
  } catch (error) {
    console.error("❌ Error getting access token:", error);
    return null;
  }
}

serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }

  try {
    console.log(`📥 Received FCM notification request - Method: ${req.method}`);
    console.log(`📥 Request URL: ${req.url}`);
    
    // Ensure it's a POST request
    if (req.method !== "POST") {
      return new Response(JSON.stringify({
        success: false,
        error: "Method not allowed. Use POST."
      }), {
        status: 405,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    
    // Parse request body
    let requestData;
    try {
      requestData = await req.json();
    } catch (parseError) {
      console.error('❌ Failed to parse request JSON:', parseError);
      return new Response(JSON.stringify({
        success: false,
        error: "Invalid JSON in request body"
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    
    const { fcm_token, title, body, data = {} } = requestData;
    
    console.log(`📋 Request data:`, {
      fcm_token: fcm_token?.substring(0, 20) + '...',
      title,
      body
    });

    // Validate required fields
    if (!fcm_token || !title || !body) {
      console.error('❌ Missing required fields');
      return new Response(JSON.stringify({
        success: false,
        error: "Missing required fields: fcm_token, title, body"
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }

    // Check if Firebase configuration is available
    if (!firebaseProjectId || !firebaseServiceAccount) {
      console.error("❌ Firebase configuration not available");
      return new Response(JSON.stringify({
        success: false,
        error: "Firebase configuration not available"
      }), {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }

    console.log(`🚀 Sending FCM notification to token: ${fcm_token.substring(0, 20)}...`);
    console.log(`📋 Title: ${title}`);
    console.log(`📄 Body: ${body.substring(0, 100)}...`);

    // Get access token
    const accessToken = await getAccessToken();
    if (!accessToken) {
      return new Response(JSON.stringify({
        success: false,
        error: "Failed to obtain access token"
      }), {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }

    // Prepare FCM v1 payload
    const fcmMessage = {
      message: {
        token: fcm_token,
        notification: {
          title: title,
          body: body
        },
        android: {
          ttl: "3600s",
          priority: "HIGH",
          notification: {
            title: title,
            body: body,
            sound: "default",
            channel_id: "default",
            notification_priority: "PRIORITY_MAX"
          }
        },
        apns: {
          headers: {
            "apns-expiration": `${Math.floor(Date.now() / 1000) + 3600}` // 1 hour
          },
          payload: {
            aps: {
              alert: {
                title: title,
                body: body
              },
              sound: "default",
              badge: 1,
              "content-available": 1
            }
          }
        },
        data: {
          ...data,
          timestamp: new Date().toISOString(),
          click_action: "FLUTTER_NOTIFICATION_CLICK"
        }
      }
    };

    // Send to FCM v1 API
    console.log(`🔄 Sending to FCM v1 URL: ${fcmV1Url}`);
    console.log(`🔑 Using access token: ${accessToken.substring(0, 20)}...`);
    
    const fcmResponse = await fetch(fcmV1Url, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(fcmMessage)
    });

    console.log(`📊 FCM Response Status: ${fcmResponse.status}`);
    console.log(`📊 FCM Response Headers:`, Object.fromEntries(fcmResponse.headers));
    
    let fcmResult;
    try {
      const responseText = await fcmResponse.text();
      console.log(`📄 FCM Raw Response:`, responseText.substring(0, 500));
      fcmResult = JSON.parse(responseText);
    } catch (parseError) {
      console.error('❌ Failed to parse FCM response as JSON:', parseError);
      const rawResponse = await fcmResponse.text();
      return new Response(JSON.stringify({
        success: false,
        error: "Invalid response from FCM service",
        raw_response: rawResponse
      }), {
        status: 502,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }

    if (fcmResponse.ok) {
      console.log("✅ FCM v1 notification sent successfully");
      return new Response(JSON.stringify({
        success: true,
        message: "Notification sent successfully",
        fcm_result: fcmResult
      }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    } else {
      console.error("❌ FCM v1 request failed:", fcmResponse.status, fcmResult);
      return new Response(JSON.stringify({
        success: false,
        error: "FCM request failed",
        status: fcmResponse.status,
        fcm_result: fcmResult
      }), {
        status: fcmResponse.status,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
  } catch (error) {
    console.error("❌ Error in send-fcm-notification:", error);
    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : String(error)
    }), {
      status: 500,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  }
});