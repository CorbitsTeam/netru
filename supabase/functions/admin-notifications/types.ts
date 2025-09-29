// ============================================
// Type definitions for Admin Notifications
// ============================================

export interface NotificationRecord {
  id: string
  user_id: string
  title: string
  body: string
  notification_type: string
  reference_id?: string
  reference_type?: string
  data?: Record<string, any>
  is_read: boolean
  fcm_message_id?: string
  created_at: string
  read_at?: string
}

export interface UserRecord {
  id: string
  full_name: string
  email: string
  user_type: string
  is_active: boolean
}

export interface FCMTokenRecord {
  id: string
  user_id: string
  fcm_token: string
  device_type: string
  is_active: boolean
  last_used?: string
}

export interface AdminUser {
  id: string
  user_type: string
  is_active: boolean
  full_name: string
}

export interface AuthResult {
  success: boolean
  user?: AdminUser
  error?: string
}

export interface FCMResult {
  success: boolean
  successCount: number
  failureCount: number
  fcmMessageId?: string
  errors: string[]
}

export interface BulkNotificationRequest {
  title: string
  body: string
  notification_type?: string
  target_type: 'all' | 'user_type' | 'specific_users'
  target_value?: string | string[]
  data?: Record<string, any>
}

export interface CreateNotificationRequest {
  user_id: string
  title: string
  body: string
  notification_type?: string
  reference_id?: string
  reference_type?: string
  data?: Record<string, any>
}

export interface PaginationParams {
  page: number
  limit: number
  total: number
  pages: number
  hasMore: boolean
}

export interface NotificationStats {
  total_notifications: number
  read_notifications: number
  fcm_sent_notifications: number
  recent_notifications: number
  open_rate: string
  fcm_delivery_rate: string
  notifications_by_type: Record<string, number>
}