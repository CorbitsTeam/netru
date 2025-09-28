import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/helpers/database_setup_helper.dart';

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
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading notifications...';
    });

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _statusMessage = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      final notifications = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      setState(() {
        _notifications = notifications;
        _statusMessage = 'Found ${notifications.length} notifications';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading notifications: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestNotifications() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating test notifications...';
    });

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _statusMessage = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      await DatabaseSetupHelper.insertTestNotifications(currentUser.id);
      await _loadNotifications();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error creating test notifications: $e';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _createTestNotifications,
                            child: const Text('Create Test Notifications'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _loadNotifications,
                            child: const Text('Refresh'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notifications List
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications (${_notifications.length}):',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            _notifications.isEmpty
                                ? const Center(
                                  child: Text('No notifications found'),
                                )
                                : ListView.builder(
                                  itemCount: _notifications.length,
                                  itemBuilder: (context, index) {
                                    final notification = _notifications[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        title: Text(
                                          notification['title'] ?? 'No Title',
                                          style: TextStyle(
                                            fontWeight:
                                                notification['is_read']
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification['body'] ?? 'No Body',
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Type: ${notification['notification_type']} | '
                                              'Read: ${notification['is_read']}',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        leading: Icon(
                                          notification['is_read']
                                              ? Icons.notifications_none
                                              : Icons.notifications_active,
                                          color:
                                              notification['is_read']
                                                  ? Colors.grey
                                                  : Colors.blue,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
