import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'النشاط الأخير',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity log
                  },
                  child: Text('عرض الكل', style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (activities.isEmpty)
              Container(
                padding: EdgeInsets.all(20.w),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48.sp, color: Colors.grey[400]),
                      SizedBox(height: 16.h),
                      Text(
                        'لا يوجد نشاط حديث',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length > 5 ? 5 : activities.length,
                separatorBuilder: (context, index) => Divider(height: 1.h),
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: activity.type.color.withValues(alpha: 0.1),
            child: Icon(
              activity.type.icon,
              color: activity.type.color,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (activity.description != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    activity.description!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4.h),
                Text(
                  _formatTimeAgo(activity.timestamp),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (activity.hasAction)
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
        ],
      ),
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
    super.key,
    required this.selectedTypes,
    required this.onFilterChanged,
  });

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
                      selectedColor: type.color.withValues(alpha: 0.3),
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
