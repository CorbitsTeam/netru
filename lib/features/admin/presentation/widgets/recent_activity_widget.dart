import 'package:flutter/material.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityWidget({Key? key, required this.activities})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'النشاط الأخير',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity log
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'لا توجد أنشطة حديثة',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length > 5 ? 5 : activities.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return _buildActivityItem(context, activity);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem activity) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: activity.type.color.withOpacity(0.1),
        child: Icon(activity.type.icon, color: activity.type.color, size: 20),
      ),
      title: Text(
        activity.title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.description != null) ...[
            const SizedBox(height: 4),
            Text(
              activity.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            _formatTimeAgo(activity.timestamp),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
      trailing:
          activity.hasAction
              ? IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  // Handle activity action
                },
              )
              : null,
      onTap:
          activity.hasAction
              ? () {
                // Handle activity tap
              }
              : null,
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'منذ لحظات';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class ActivityItem {
  final String id;
  final String title;
  final String? description;
  final ActivityType type;
  final DateTime timestamp;
  final bool hasAction;
  final Map<String, dynamic>? metadata;

  ActivityItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.timestamp,
    this.hasAction = false,
    this.metadata,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      type: ActivityType.fromString(json['type'] ?? 'general'),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      hasAction: json['has_action'] ?? false,
      metadata: json['metadata'],
    );
  }
}

enum ActivityType {
  reportCreated,
  reportUpdated,
  reportAssigned,
  reportResolved,
  userRegistered,
  userVerified,
  notificationSent,
  systemUpdate,
  general;

  IconData get icon {
    switch (this) {
      case ActivityType.reportCreated:
        return Icons.add_circle;
      case ActivityType.reportUpdated:
        return Icons.edit;
      case ActivityType.reportAssigned:
        return Icons.assignment_ind;
      case ActivityType.reportResolved:
        return Icons.check_circle;
      case ActivityType.userRegistered:
        return Icons.person_add;
      case ActivityType.userVerified:
        return Icons.verified_user;
      case ActivityType.notificationSent:
        return Icons.notifications;
      case ActivityType.systemUpdate:
        return Icons.system_update;
      case ActivityType.general:
        return Icons.info;
    }
  }

  Color get color {
    switch (this) {
      case ActivityType.reportCreated:
        return Colors.blue;
      case ActivityType.reportUpdated:
        return Colors.orange;
      case ActivityType.reportAssigned:
        return Colors.purple;
      case ActivityType.reportResolved:
        return Colors.green;
      case ActivityType.userRegistered:
        return Colors.indigo;
      case ActivityType.userVerified:
        return Colors.teal;
      case ActivityType.notificationSent:
        return Colors.amber;
      case ActivityType.systemUpdate:
        return Colors.grey;
      case ActivityType.general:
        return Colors.blueGrey;
    }
  }

  static ActivityType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'report_created':
        return ActivityType.reportCreated;
      case 'report_updated':
        return ActivityType.reportUpdated;
      case 'report_assigned':
        return ActivityType.reportAssigned;
      case 'report_resolved':
        return ActivityType.reportResolved;
      case 'user_registered':
        return ActivityType.userRegistered;
      case 'user_verified':
        return ActivityType.userVerified;
      case 'notification_sent':
        return ActivityType.notificationSent;
      case 'system_update':
        return ActivityType.systemUpdate;
      default:
        return ActivityType.general;
    }
  }
}

class ActivityFilter extends StatefulWidget {
  final List<ActivityType> selectedTypes;
  final Function(List<ActivityType>) onFilterChanged;

  const ActivityFilter({
    Key? key,
    required this.selectedTypes,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<ActivityFilter> createState() => _ActivityFilterState();
}

class _ActivityFilterState extends State<ActivityFilter> {
  late List<ActivityType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تصفية النشاط',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  ActivityType.values.map((type) {
                    final isSelected = _selectedTypes.contains(type);
                    return FilterChip(
                      label: Text(_getTypeName(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTypes.add(type);
                          } else {
                            _selectedTypes.remove(type);
                          }
                        });
                        widget.onFilterChanged(_selectedTypes);
                      },
                      selectedColor: type.color.withOpacity(0.3),
                      checkmarkColor: type.color,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypes = List.from(ActivityType.values);
                    });
                    widget.onFilterChanged(_selectedTypes);
                  },
                  child: const Text('تحديد الكل'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypes.clear();
                    });
                    widget.onFilterChanged(_selectedTypes);
                  },
                  child: const Text('إلغاء التحديد'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.reportCreated:
        return 'بلاغ جديد';
      case ActivityType.reportUpdated:
        return 'تحديث بلاغ';
      case ActivityType.reportAssigned:
        return 'تعيين بلاغ';
      case ActivityType.reportResolved:
        return 'حل بلاغ';
      case ActivityType.userRegistered:
        return 'تسجيل مستخدم';
      case ActivityType.userVerified:
        return 'تحقق مستخدم';
      case ActivityType.notificationSent:
        return 'إرسال إشعار';
      case ActivityType.systemUpdate:
        return 'تحديث نظام';
      case ActivityType.general:
        return 'عام';
    }
  }
}
