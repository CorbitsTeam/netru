import 'package:flutter/material.dart';
import '../widgets/admin_sidebar.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String? _selectedUserType;
  String? _selectedVerificationStatus;
  String? _selectedGovernorate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedRoute: '/admin/users'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilters(),
                Expanded(child: _buildUsersContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إدارة المستخدمين',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'عرض وإدارة جميع المستخدمين المسجلين',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showBulkNotificationDialog();
              },
              icon: const Icon(Icons.send),
              label: const Text('إرسال إشعار جماعي'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                _exportUsers();
              },
              icon: const Icon(Icons.download),
              label: const Text('تصدير'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'البحث في المستخدمين...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Search logic will be implemented here
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'نوع المستخدم',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedUserType,
                  items: const [
                    DropdownMenuItem(
                      value: 'citizen',
                      child: Text('مواطن مصري'),
                    ),
                    DropdownMenuItem(value: 'foreigner', child: Text('أجنبي')),
                    DropdownMenuItem(value: 'admin', child: Text('مدير')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'حالة التحقق',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedVerificationStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('في الانتظار'),
                    ),
                    DropdownMenuItem(value: 'verified', child: Text('محقق')),
                    DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVerificationStatus = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'المحافظة',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedGovernorate,
                  items: const [
                    DropdownMenuItem(value: 'cairo', child: Text('القاهرة')),
                    DropdownMenuItem(value: 'giza', child: Text('الجيزة')),
                    DropdownMenuItem(
                      value: 'alexandria',
                      child: Text('الإسكندرية'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGovernorate = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDateRange(),
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'
                        : 'اختر فترة التسجيل',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('مسح المرشحات'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('تطبيق'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'إجمالي المستخدمين',
                  '2,567',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'مواطنين',
                  '2,234',
                  Icons.person,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'أجانب',
                  '333',
                  Icons.person_outline,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'طلبات التحقق',
                  '45',
                  Icons.verified_user,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Users Table
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(value: false, onChanged: (value) {}),
                        const SizedBox(width: 12),
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'الاسم والبريد',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'النوع',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'المحافظة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'حالة التحقق',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'تاريخ التسجيل',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'البلاغات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 120,
                          child: Text(
                            'الإجراءات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 15, // Replace with actual data
                      itemBuilder: (context, index) {
                        return _buildUserRow(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(int index) {
    final isEven = index % 2 == 0;
    final verificationStatus = ['pending', 'verified', 'rejected'][index % 3];
    final userType = ['citizen', 'foreigner', 'admin'][index % 3];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[25] : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Checkbox(value: false, onChanged: (value) {}),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Text('ص${index + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مستخدم رقم ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'user${index + 1}@example.com',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getUserTypeColor(userType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getUserTypeLabel(userType),
                style: TextStyle(
                  color: _getUserTypeColor(userType),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Expanded(child: Text('القاهرة')),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getVerificationColor(
                  verificationStatus,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getVerificationLabel(verificationStatus),
                style: TextStyle(
                  color: _getVerificationColor(verificationStatus),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Expanded(child: Text('2024/01/15')),
          Expanded(
            child: Text(
              '${(index + 1) * 3}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 16),
                  onPressed: () => _viewUser(index),
                  tooltip: 'عرض',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => _editUser(index),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  icon: const Icon(Icons.verified_user, size: 16),
                  onPressed: () => _verifyUser(index),
                  tooltip: 'تحقق',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16),
                  onSelected: (value) => _handleUserAction(index, value),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'send_notification',
                          child: Text('إرسال إشعار'),
                        ),
                        const PopupMenuItem(
                          value: 'suspend',
                          child: Text('إيقاف'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('حذف'),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getUserTypeColor(String type) {
    switch (type) {
      case 'citizen':
        return Colors.green;
      case 'foreigner':
        return Colors.orange;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getUserTypeLabel(String type) {
    switch (type) {
      case 'citizen':
        return 'مواطن';
      case 'foreigner':
        return 'أجنبي';
      case 'admin':
        return 'مدير';
      default:
        return 'غير محدد';
    }
  }

  Color _getVerificationColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getVerificationLabel(String status) {
    switch (status) {
      case 'verified':
        return 'محقق';
      case 'pending':
        return 'معلق';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير محدد';
    }
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
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
      _selectedUserType = null;
      _selectedVerificationStatus = null;
      _selectedGovernorate = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    // Apply filters logic
    print('Applying filters...');
  }

  void _showBulkNotificationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إرسال إشعار جماعي'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'المجموعة المستهدفة',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('جميع المستخدمين'),
                      ),
                      DropdownMenuItem(
                        value: 'citizens',
                        child: Text('المواطنين فقط'),
                      ),
                      DropdownMenuItem(
                        value: 'foreigners',
                        child: Text('الأجانب فقط'),
                      ),
                      DropdownMenuItem(
                        value: 'verified',
                        child: Text('المحققين فقط'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'عنوان الإشعار',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'محتوى الإشعار',
                      border: OutlineInputBorder(),
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
                    const SnackBar(content: Text('تم إرسال الإشعار بنجاح')),
                  );
                },
                child: const Text('إرسال'),
              ),
            ],
          ),
    );
  }

  void _exportUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تصدير بيانات المستخدمين...')),
    );
  }

  void _viewUser(int index) {
    // Navigate to user details
  }

  void _editUser(int index) {
    // Navigate to edit user
  }

  void _verifyUser(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تحقق من المستخدم'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('هل تريد الموافقة على تحقق هذا المستخدم؟'),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
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
                    const SnackBar(content: Text('تم رفض التحقق')),
                  );
                },
                child: const Text('رفض'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم الموافقة على التحقق')),
                  );
                },
                child: const Text('موافقة'),
              ),
            ],
          ),
    );
  }

  void _handleUserAction(int index, String action) {
    switch (action) {
      case 'send_notification':
        _showSendNotificationDialog(index);
        break;
      case 'suspend':
        _showSuspendUserDialog(index);
        break;
      case 'delete':
        _showDeleteUserDialog(index);
        break;
    }
  }

  void _showSendNotificationDialog(int userIndex) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إرسال إشعار'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'عنوان الإشعار',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'محتوى الإشعار',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
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
                    const SnackBar(content: Text('تم إرسال الإشعار')),
                  );
                },
                child: const Text('إرسال'),
              ),
            ],
          ),
    );
  }

  void _showSuspendUserDialog(int userIndex) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إيقاف المستخدم'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('هل أنت متأكد من إيقاف هذا المستخدم؟'),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'سبب الإيقاف',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
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
                    const SnackBar(content: Text('تم إيقاف المستخدم')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('إيقاف'),
              ),
            ],
          ),
    );
  }

  void _showDeleteUserDialog(int userIndex) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف المستخدم'),
            content: const Text(
              'هل أنت متأكد من حذف هذا المستخدم؟ لا يمكن التراجع عن هذا الإجراء.',
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
                    const SnackBar(content: Text('تم حذف المستخدم')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }
}
