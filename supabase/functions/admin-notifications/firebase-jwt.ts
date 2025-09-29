// ============================================
// Firebase JWT Helper for FCM Authentication
// ============================================

/**
 * Create a JWT token for Firebase service account authentication
 */
export async function createFirebaseJWT(
  privateKey: string,
  clientEmail: string
): Promise<string> {
  try {
    // Clean and parse the private key
    const cleanPrivateKey = privateKey
      .replace(/\\n/g, '\n')
      .replace(/"/g, '')
      .trim()

    // Import the private key
    const pemKey = `-----BEGIN PRIVATE KEY-----\n${cleanPrivateKey}\n-----END PRIVATE KEY-----`
    
    const keyData = await crypto.subtle.importKey(
      'pkcs8',
      new TextEncoder().encode(pemKey),
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256',
      },
      false,
      ['sign']
    )

    // Create JWT header
    const header = {
      alg: 'RS256',
      typ: 'JWT'
    }

    // Create JWT payload
    const now = Math.floor(Date.now() / 1000)
    const payload = {
      iss: clientEmail,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://oauth2.googleapis.com/token',
      exp: now + 3600, // 1 hour
      iat: now
    }

    // Encode header and payload
    const encodedHeader = base64urlEscape(JSON.stringify(header))
    const encodedPayload = base64urlEscape(JSON.stringify(payload))
    
    // Create the signing input
    const signingInput = `${encodedHeader}.${encodedPayload}`
    const signingInputBytes = new TextEncoder().encode(signingInput)

    // Sign the JWT
    const signature = await crypto.subtle.sign(
      'RSASSA-PKCS1-v1_5',
      keyData,
      signingInputBytes
    )

    // Encode the signature
    const encodedSignature = base64urlEscapeBytes(new Uint8Array(signature))

    // Return the complete JWT
    return `${signingInput}.${encodedSignature}`

  } catch (error: any) {
    console.error('Error creating Firebase JWT:', error)
    throw new Error(`Failed to create Firebase JWT: ${error.message}`)
  }
}

/**
 * Get Firebase access token using service account JWT
 */
export async function getFirebaseAccessToken(
  privateKey: string,
  clientEmail: string
): Promise<string | null> {
  try {
    // Create JWT assertion
    const jwt = await createFirebaseJWT(privateKey, clientEmail)

    // Exchange JWT for access token
    const response = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt
      })
    })

    if (response.ok) {
      const data = await response.json()
      return data.access_token
    } else {
      const errorText = await response.text()
      console.error('Failed to get access token:', errorText)
      return null
    }
  } catch (error) {
    console.error('Error getting Firebase access token:', error)
    return null
  }
}

/**
 * Simple base64url encoding without padding for strings
 */
function base64urlEscape(str: string): string {
  return btoa(str)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '')
}

/**
 * Simple base64url encoding without padding for byte arrays
 */
function base64urlEscapeBytes(bytes: Uint8Array): string {
  let binaryString = ''
  for (let i = 0; i < bytes.length; i++) {
    binaryString += String.fromCharCode(bytes[i])
  }
  return btoa(binaryString)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '')
}