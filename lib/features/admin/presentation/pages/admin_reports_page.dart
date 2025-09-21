import 'package:flutter/material.dart';
import '../widgets/admin_sidebar.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({Key? key}) : super(key: key);

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  String? _selectedStatus;
  String? _selectedGovernorate;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedRoute: '/admin/reports'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilters(),
                Expanded(child: _buildReportsContent()),
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
                    'إدارة البلاغات',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'عرض وإدارة جميع البلاغات المرسلة',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showBulkActionsDialog();
              },
              icon: const Icon(Icons.more_horiz),
              label: const Text('إجراءات متعددة'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                _exportReports();
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
                flex: 3,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'البحث في البلاغات...',
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
                    labelText: 'الحالة',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('معلق')),
                    DropdownMenuItem(
                      value: 'under_investigation',
                      child: Text('قيد التحقيق'),
                    ),
                    DropdownMenuItem(value: 'resolved', child: Text('محلول')),
                    DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
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
                    // Add more governorates
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGovernorate = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'نوع البلاغ',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: 'infrastructure',
                      child: Text('بنية تحتية'),
                    ),
                    DropdownMenuItem(value: 'security', child: Text('أمني')),
                    DropdownMenuItem(value: 'health', child: Text('صحي')),
                    DropdownMenuItem(
                      value: 'environmental',
                      child: Text('بيئي'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
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
                        : 'اختر فترة زمنية',
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

  Widget _buildReportsContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'إجمالي البلاغات',
                  '1,234',
                  Icons.report,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'معلقة',
                  '56',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'قيد التحقيق',
                  '78',
                  Icons.search,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'محلولة',
                  '1,100',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Reports Table
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
                            'عنوان البلاغ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'المستخدم',
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
                            'الحالة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'التاريخ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 100,
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
                      itemCount: 10, // Replace with actual data
                      itemBuilder: (context, index) {
                        return _buildReportRow(index);
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

  Widget _buildReportRow(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Checkbox(value: false, onChanged: (value) {}),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بلاغ رقم ${index + 1}: مشكلة في البنية التحتية',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Text(
                  'وصف مختصر للبلاغ يظهر هنا...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Expanded(child: Text('أحمد محمد')),
          const Expanded(child: Text('بنية تحتية')),
          const Expanded(child: Text('القاهرة')),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'معلق',
                style: TextStyle(color: Colors.orange, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Expanded(child: Text('2024/01/15')),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 16),
                  onPressed: () => _viewReport(index),
                  tooltip: 'عرض',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => _editReport(index),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  icon: const Icon(Icons.assignment_ind, size: 16),
                  onPressed: () => _assignReport(index),
                  tooltip: 'تعيين',
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      _selectedStatus = null;
      _selectedGovernorate = null;
      _selectedType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    // Apply filters logic
    print('Applying filters...');
  }

  void _showBulkActionsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إجراءات متعددة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.assignment_ind),
                  title: const Text('تعيين محقق'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('تغيير الحالة'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.send),
                  title: const Text('إرسال إشعار'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _exportReports() {
    // Export reports logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري تصدير البلاغات...')));
  }

  void _viewReport(int index) {
    // Navigate to report details
  }

  void _editReport(int index) {
    // Navigate to edit report
  }

  void _assignReport(int index) {
    // Show assign report dialog
    _showAssignReportDialog(index);
  }

  void _showAssignReportDialog(int reportIndex) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تعيين محقق'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'اختر المحقق',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'investigator1',
                      child: Text('محمد أحمد - محقق رئيسي'),
                    ),
                    DropdownMenuItem(
                      value: 'investigator2',
                      child: Text('سارة محمود - محققة'),
                    ),
                    DropdownMenuItem(
                      value: 'investigator3',
                      child: Text('خالد علي - محقق مساعد'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
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
                    const SnackBar(content: Text('تم تعيين المحقق بنجاح')),
                  );
                },
                child: const Text('تعيين'),
              ),
            ],
          ),
    );
  }
}
