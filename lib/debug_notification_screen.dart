import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/simple_fcm_service.dart';

class DebugNotificationScreen extends StatefulWidget {
  const DebugNotificationScreen({super.key});

  @override
  State<DebugNotificationScreen> createState() =>
      _DebugNotificationScreenState();
}

class _DebugNotificationScreenState extends State<DebugNotificationScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _createTestNotifications() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating test notifications...';
    });

    try {
      // Get current user
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Create test notifications
      final notifications = [
        {
          'user_id': userId,
          'title': 'Welcome to NetRu',
          'title_ar': 'مرحباً بك في نترو',
          'body':
              'Welcome to the NetRu application. You can now submit and track reports.',
          'body_ar':
              'مرحباً بك في تطبيق نترو. يمكنك الآن تقديم ومتابعة البلاغات.',
          'notification_type': 'system',
          'is_read': false,
          'priority': 'normal',
        },
        {
          'user_id': userId,
          'title': 'Report Status Update',
          'title_ar': 'تحديث حالة البلاغ',
          'body':
              'Your report #12345 has been updated to "Under Investigation".',
          'body_ar': 'تم تحديث بلاغك رقم #12345 إلى "قيد التحقيق".',
          'notification_type': 'report_update',
          'is_read': false,
          'priority': 'high',
        },
        {
          'user_id': userId,
          'title': 'System Maintenance',
          'title_ar': 'صيانة النظام',
          'body':
              'The system will be under maintenance from 2:00 AM to 4:00 AM.',
          'body_ar':
              'سيكون النظام تحت الصيانة من الساعة 2:00 صباحاً إلى 4:00 صباحاً.',
          'notification_type': 'system',
          'is_read': true,
          'priority': 'low',
        },
        {
          'user_id': userId,
          'title': 'New News Article',
          'title_ar': 'مقال إخباري جديد',
          'body': 'Check out the latest security news in your area.',
          'body_ar': 'تصفح أحدث الأخبار الأمنية في منطقتك.',
          'notification_type': 'news',
          'is_read': false,
          'priority': 'normal',
        },
      ];

      await _supabase.from('notifications').insert(notifications);

      setState(() {
        _statusMessage =
            '✅ Successfully created ${notifications.length} test notifications!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFcmTokenRegistration() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing FCM token registration...';
    });

    try {
      // Import and test FCM service
      final fcmService = SimpleFcmService();
      final token = await fcmService.getFcmTokenAndRegister();

      if (token != null) {
        setState(() {
          _statusMessage =
              '✅ FCM Token registered successfully!\nToken: ${token.substring(0, 50)}...';
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = '❌ Failed to get FCM token';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ FCM Token Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing all notifications...';
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      await _supabase.from('notifications').delete().eq('user_id', userId);

      setState(() {
        _statusMessage = '✅ All notifications cleared!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkNotifications() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking notifications...';
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final notifications = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _statusMessage =
            '📊 Found ${notifications.length} notifications for current user';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Notifications'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Notification Debug Tools',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current User: ${_supabase.auth.currentUser?.id ?? "Not logged in"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (_statusMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _statusMessage.startsWith('✅')
                                  ? Colors.green.withOpacity(0.1)
                                  : _statusMessage.startsWith('❌')
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _statusMessage.startsWith('✅')
                                    ? Colors.green
                                    : _statusMessage.startsWith('❌')
                                    ? Colors.red
                                    : Colors.blue,
                          ),
                        ),
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color:
                                _statusMessage.startsWith('✅')
                                    ? Colors.green.shade800
                                    : _statusMessage.startsWith('❌')
                                    ? Colors.red.shade800
                                    : Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  _buildActionButton(
                    icon: Icons.add_alert,
                    label: 'Create Test Notifications',
                    onPressed: _isLoading ? null : _createTestNotifications,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.search,
                    label: 'Check Existing Notifications',
                    onPressed: _isLoading ? null : _checkNotifications,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.delete_sweep,
                    label: 'Clear All Notifications',
                    onPressed: _isLoading ? null : _clearAllNotifications,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.cloud_upload,
                    label: 'Test FCM Token Registration',
                    onPressed: _isLoading ? null : _testFcmTokenRegistration,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 24),
                  _buildActionButton(
                    icon: Icons.notifications,
                    label: 'Go to Notifications Screen',
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/notifications',
                        arguments: _supabase.auth.currentUser?.id,
                      );
                    },
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
