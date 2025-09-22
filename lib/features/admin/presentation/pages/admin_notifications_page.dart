import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/mobile_admin_drawer.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedType;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<int> _selectedNotifications = [];

  final List<String> _notificationTypes = ['عام', 'تحديث بلاغ', 'تحقق مستخدم', 'نظام'];
  final List<String> _statusOptions = ['مرسل', 'مجدول', 'مسودة', 'فشل'];

  // Mock notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'تحديث مهم في النظام',
      'content': 'تم تحديث النظام بميزات جديدة ومحسنة لتجربة أفضل',
      'type': 'نظام',
      'status': 'مرسل',
      'recipients': 1250,
      'sentDate': DateTime.now().subtract(const Duration(hours: 2)),
      'deliveryRate': 98.5,
    },
    {
      'id': 2,
      'title': 'تذكير بتحديث البيانات',
      'content': 'يرجى تحديث بياناتك الشخصية للحصول على خدمة أفضل',
      'type': 'عام',
      'status': 'مجدول',
      'recipients': 800,
      'sentDate': DateTime.now().add(const Duration(hours: 5)),
      'deliveryRate': 0.0,
    },
    {
      'id': 3,
      'title': 'تم قبول طلب التحقق',
      'content': 'تهانينا! تم قبول طلب التحقق الخاص بك',
      'type': 'تحقق مستخدم',
      'status': 'مرسل',
      'recipients': 50,
      'sentDate': DateTime.now().subtract(const Duration(hours: 1)),
      'deliveryRate': 100.0,
    },
    {
      'id': 4,
      'title': 'تحديث حالة البلاغ',
      'content': 'تم تحديث حالة البلاغ الخاص بك إلى "قيد المراجعة"',
      'type': 'تحديث بلاغ',
      'status': 'مسودة',
      'recipients': 0,
      'sentDate': null,
      'deliveryRate': 0.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'إدارة الإشعارات',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics, size: 24.sp),
            onPressed: _showAnalytics,
            tooltip: 'إحصائيات',
          ),
          IconButton(
            icon: Icon(Icons.send, size: 24.sp),
            onPressed: _showBulkNotificationDialog,
            tooltip: 'إرسال جماعي',
          ),
        ],
      ),
      drawer: const MobileAdminDrawer(selectedRoute: '/admin/notifications'),
      body: Column(
        children: [
          _buildStatsCards(),
          _buildTabSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateNotificationDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'إجمالي الإشعارات',
              '${_notifications.length}',
              Icons.notifications,
              Colors.blue,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'مرسلة',
              '${_notifications.where((n) => n['status'] == 'مرسل').length}',
              Icons.send,
              Colors.green,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'مجدولة',
              '${_notifications.where((n) => n['status'] == 'مجدول').length}',
              Icons.schedule,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Expanded(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
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
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 14.sp),
              tabs: const [
                Tab(text: 'جميع الإشعارات'),
                Tab(text: 'المجدولة'),
                Tab(text: 'المسودات'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllNotificationsTab(),
                _buildScheduledNotificationsTab(),
                _buildDraftsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllNotificationsTab() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildFiltersPanel(),
          SizedBox(height: 16.h),
          _buildBulkActionsPanel(),
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildScheduledNotificationsTab() {
    final scheduledNotifications = _notifications.where((n) => n['status'] == 'مجدول').toList();
    
    return Container(
      padding: EdgeInsets.all(16.w),
      child: scheduledNotifications.isEmpty
          ? _buildEmptyState('لا توجد إشعارات مجدولة', Icons.schedule)
          : ListView.separated(
              itemCount: scheduledNotifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) =>
                  _buildNotificationCard(scheduledNotifications[index], index),
            ),
    );
  }

  Widget _buildDraftsTab() {
    final drafts = _notifications.where((n) => n['status'] == 'مسودة').toList();
    
    return Container(
      padding: EdgeInsets.all(16.w),
      child: drafts.isEmpty
          ? _buildEmptyState('لا توجد مسودات', Icons.drafts)
          : ListView.separated(
              itemCount: drafts.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) => _buildNotificationCard(drafts[index], index),
            ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.filter_list, size: 20.sp, color: Colors.grey[700]),
              SizedBox(width: 8.w),
              Text(
                'الفلاتر',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: Text('مسح الكل', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildFilterChip(
                'النوع',
                _selectedType,
                _notificationTypes,
                (value) => setState(() => _selectedType = value),
              ),
              _buildFilterChip(
                'الحالة',
                _selectedStatus,
                _statusOptions,
                (value) => setState(() => _selectedStatus = value),
              ),
              _buildDateRangeChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return InkWell(
      onTap: () => _showFilterBottomSheet(label, selectedValue, options, onChanged),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selectedValue != null ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selectedValue != null ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedValue ?? label,
              style: TextStyle(
                fontSize: 12.sp,
                color: selectedValue != null ? Colors.blue : Colors.grey[700],
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down,
              size: 16.sp,
              color: selectedValue != null ? Colors.blue : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeChip() {
    String dateText = 'التاريخ';
    if (_startDate != null && _endDate != null) {
      dateText = '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}';
    }

    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _startDate != null ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: _startDate != null ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dateText,
              style: TextStyle(
                fontSize: 12.sp,
                color: _startDate != null ? Colors.blue : Colors.grey[700],
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.date_range,
              size: 16.sp,
              color: _startDate != null ? Colors.blue : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionsPanel() {
    if (_selectedNotifications.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist, color: Colors.blue, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            'تم تحديد ${_selectedNotifications.length} إشعار',
            style: TextStyle(fontSize: 14.sp, color: Colors.blue[700]),
          ),
          const Spacer(),
          Row(
            children: [
              _buildBulkActionButton('إرسال', Icons.send, _bulkSend),
              SizedBox(width: 8.w),
              _buildBulkActionButton('حذف', Icons.delete, _bulkDelete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      ),
      icon: Icon(icon, size: 16.sp),
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.separated(
      itemCount: _notifications.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _buildNotificationCard(_notifications[index], index),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final bool isSelected = _selectedNotifications.contains(notification['id']);

    return InkWell(
      onLongPress: () => _toggleNotificationSelection(notification['id']),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isSelected)
                  Icon(Icons.check_circle, color: Colors.blue, size: 20.sp)
                else
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: _getTypeColor(notification['type']).withOpacity(0.1),
                    child: Icon(
                      _getTypeIcon(notification['type']),
                      color: _getTypeColor(notification['type']),
                      size: 20.sp,
                    ),
                  ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${notification['recipients']} مستلم',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleNotificationAction(notification, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('عرض')),
                    const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    if (notification['status'] == 'مسودة' || notification['status'] == 'مجدول')
                      const PopupMenuItem(value: 'send', child: Text('إرسال الآن')),
                    const PopupMenuItem(value: 'duplicate', child: Text('تكرار')),
                    const PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              notification['content'],
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildStatusBadge(notification['type'], _getTypeColor(notification['type'])),
                SizedBox(width: 8.w),
                _buildStatusBadge(notification['status'], _getStatusColor(notification['status'])),
                if (notification['status'] == 'مرسل' && notification['deliveryRate'] > 0)
                  ...[
                    SizedBox(width: 8.w),
                    _buildStatusBadge(
                      '${notification['deliveryRate']}% تسليم',
                      notification['deliveryRate'] >= 95 ? Colors.green : Colors.orange,
                    ),
                  ],
                const Spacer(),
                Text(
                  notification['sentDate'] != null
                      ? _formatDate(notification['sentDate'])
                      : 'غير محدد',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'عام':
        return Icons.campaign;
      case 'تحديث بلاغ':
        return Icons.update;
      case 'تحقق مستخدم':
        return Icons.verified_user;
      case 'نظام':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'عام':
        return Colors.blue;
      case 'تحديث بلاغ':
        return Colors.green;
      case 'تحقق مستخدم':
        return Colors.orange;
      case 'نظام':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مرسل':
        return Colors.green;
      case 'مجدول':
        return Colors.orange;
      case 'مسودة':
        return Colors.grey;
      case 'فشل':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      final futureDiff = date.difference(now);
      if (futureDiff.inDays > 0) {
        return 'خلال ${futureDiff.inDays} يوم';
      } else if (futureDiff.inHours > 0) {
        return 'خلال ${futureDiff.inHours} ساعة';
      } else {
        return 'خلال ${futureDiff.inMinutes} دقيقة';
      }
    } else {
      if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ساعة';
      } else {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
    }
  }

  void _showFilterBottomSheet(
    String title,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ...options.map(
              (option) => ListTile(
                title: Text(option),
                trailing: selectedValue == option
                    ? Icon(Icons.check, color: Colors.blue, size: 20.sp)
                    : null,
                onTap: () {
                  onChanged(selectedValue == option ? null : option);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _toggleNotificationSelection(int notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
    });
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'إحصائيات الإشعارات',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 300.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnalyticRow('إجمالي الإشعارات المرسلة', '2,347'),
              _buildAnalyticRow('معدل التسليم', '97.8%'),
              _buildAnalyticRow('معدل القراءة', '85.2%'),
              _buildAnalyticRow('الإشعارات اليوم', '23'),
              _buildAnalyticRow('الإشعارات المجدولة', '8'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateNotificationDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String? selectedType;
    String? selectedTarget;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          title: Text(
            'إنشاء إشعار جديد',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 350.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان الإشعار',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: 'محتوى الإشعار',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'نوع الإشعار',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    value: selectedType,
                    items: _notificationTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) => setModalState(() => selectedType = value),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'المجموعة المستهدفة',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    value: selectedTarget,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('جميع المستخدمين')),
                      DropdownMenuItem(value: 'citizens', child: Text('المواطنين فقط')),
                      DropdownMenuItem(value: 'foreigners', child: Text('الأجانب فقط')),
                      DropdownMenuItem(value: 'verified', child: Text('المحققين فقط')),
                    ],
                    onChanged: (value) => setModalState(() => selectedTarget = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الإشعار كمسودة')),
                );
              },
              child: const Text('حفظ كمسودة'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال الإشعار بنجاح')),
                );
              },
              child: const Text('إرسال الآن'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'إرسال جماعي',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 350.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إرسال إشعار لعدة مجموعات من المستخدمين',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  labelText: 'عنوان الإشعار',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  labelText: 'محتوى الإشعار',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال الإشعارات بنجاح')),
              );
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _bulkSend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'إرسال الإشعارات',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد إرسال ${_selectedNotifications.length} إشعار؟',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedNotifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال الإشعارات المحددة')),
              );
            },
            child: Text(
              'إرسال',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _bulkDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'حذف الإشعارات',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد حذف ${_selectedNotifications.length} إشعار؟',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedNotifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الإشعارات المحددة')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'حذف',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationAction(Map<String, dynamic> notification, String action) {
    switch (action) {
      case 'view':
        _viewNotificationDetails(notification);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعديل الإشعار: ${notification['title']}')),
        );
        break;
      case 'send':
        _sendNotificationNow(notification);
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تكرار الإشعار')),
        );
        break;
      case 'delete':
        _deleteNotification(notification);
        break;
    }
  }

  void _viewNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'تفاصيل الإشعار',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('العنوان: ${notification['title']}'),
              SizedBox(height: 8.h),
              Text('النوع: ${notification['type']}'),
              SizedBox(height: 8.h),
              Text('الحالة: ${notification['status']}'),
              SizedBox(height: 8.h),
              Text('عدد المستلمين: ${notification['recipients']}'),
              SizedBox(height: 8.h),
              if (notification['deliveryRate'] > 0)
                Text('معدل التسليم: ${notification['deliveryRate']}%'),
              SizedBox(height: 8.h),
              Text('المحتوى: ${notification['content']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _sendNotificationNow(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'إرسال الإشعار',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد إرسال الإشعار: ${notification['title']}؟',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال الإشعار')),
              );
            },
            child: Text(
              'إرسال',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'حذف الإشعار',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد حذف الإشعار: ${notification['title']}؟',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الإشعار')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'حذف',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
