import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/admin_notification_entity.dart';
import '../cubit/admin_notifications_cubit.dart';

class NotificationFiltersWidget extends StatefulWidget {
  final NotificationFilters? filters;
  final Function(NotificationFilters) onFiltersChanged;

  const NotificationFiltersWidget({
    super.key,
    this.filters,
    required this.onFiltersChanged,
  });

  @override
  State<NotificationFiltersWidget> createState() =>
      _NotificationFiltersWidgetState();
}

class _NotificationFiltersWidgetState extends State<NotificationFiltersWidget> {
  late NotificationFilters _currentFilters;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters ?? const NotificationFilters();
    _searchController.text = _currentFilters.searchQuery ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'البحث في الإشعارات...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _updateFilters(searchQuery: '');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            onChanged: (value) {
              _updateFilters(searchQuery: value.isEmpty ? null : value);
            },
          ),

          SizedBox(height: 16.h),

          // Filter chips
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildFilterChip(
                'النوع',
                _currentFilters.type?.arabicName,
                () => _showTypeFilter(),
              ),
              _buildFilterChip(
                'الأولوية',
                _currentFilters.priority?.arabicName,
                () => _showPriorityFilter(),
              ),
              _buildFilterChip(
                'الحالة',
                _currentFilters.status,
                () => _showStatusFilter(),
              ),
              _buildFilterChip(
                'التاريخ',
                _getDateRangeText(),
                () => _showDateRangePicker(),
              ),
              if (_hasActiveFilters()) ...[
                SizedBox(width: 8.w),
                ActionChip(
                  label: const Text('مسح الفلاتر'),
                  onPressed: _clearAllFilters,
                  backgroundColor: Colors.red[50],
                  labelStyle: TextStyle(color: Colors.red[600]),
                  side: BorderSide(color: Colors.red[200]!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, VoidCallback onTap) {
    final hasValue = value != null && value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: hasValue ? const Color(0xFF2E7D32) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: hasValue ? const Color(0xFF2E7D32) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasValue ? '$label: $value' : label,
              style: TextStyle(
                color: hasValue ? Colors.white : Colors.grey[700],
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: hasValue ? Colors.white : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختيار نوع الإشعار',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ...NotificationType.values.map(
                  (type) => ListTile(
                    title: Text(type.arabicName),
                    leading: Radio<NotificationType>(
                      value: type,
                      groupValue: _currentFilters.type,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _updateFilters(type: value);
                      },
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('الكل'),
                  leading: Radio<NotificationType?>(
                    value: null,
                    groupValue: _currentFilters.type,
                    onChanged: (value) {
                      Navigator.pop(context);
                      _updateFilters(type: value);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPriorityFilter() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختيار الأولوية',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ...NotificationPriority.values.map(
                  (priority) => ListTile(
                    title: Text(priority.arabicName),
                    leading: Radio<NotificationPriority>(
                      value: priority,
                      groupValue: _currentFilters.priority,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _updateFilters(priority: value);
                      },
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('الكل'),
                  leading: Radio<NotificationPriority?>(
                    value: null,
                    groupValue: _currentFilters.priority,
                    onChanged: (value) {
                      Navigator.pop(context);
                      _updateFilters(priority: value);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showStatusFilter() {
    const statuses = ['مرسل', 'مجدول', 'مسودة', 'فشل'];

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختيار الحالة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ...statuses.map(
                  (status) => ListTile(
                    title: Text(status),
                    leading: Radio<String>(
                      value: status,
                      groupValue: _currentFilters.status,
                      onChanged: (value) {
                        Navigator.pop(context);
                        _updateFilters(status: value);
                      },
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('الكل'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: _currentFilters.status,
                    onChanged: (value) {
                      Navigator.pop(context);
                      _updateFilters(status: value);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange:
          _currentFilters.startDate != null && _currentFilters.endDate != null
              ? DateTimeRange(
                start: _currentFilters.startDate!,
                end: _currentFilters.endDate!,
              )
              : null,
    );

    if (picked != null) {
      _updateFilters(startDate: picked.start, endDate: picked.end);
    }
  }

  void _updateFilters({
    NotificationType? type,
    NotificationPriority? priority,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        type: type,
        priority: priority,
        status: status,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
      );
    });

    widget.onFiltersChanged(_currentFilters);
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _currentFilters = const NotificationFilters();
    });
    widget.onFiltersChanged(_currentFilters);
  }

  bool _hasActiveFilters() {
    return _currentFilters.type != null ||
        _currentFilters.priority != null ||
        _currentFilters.status != null ||
        _currentFilters.startDate != null ||
        _currentFilters.endDate != null ||
        (_currentFilters.searchQuery != null &&
            _currentFilters.searchQuery!.isNotEmpty);
  }

  String? _getDateRangeText() {
    if (_currentFilters.startDate != null && _currentFilters.endDate != null) {
      return '${_formatDate(_currentFilters.startDate!)} - ${_formatDate(_currentFilters.endDate!)}';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
