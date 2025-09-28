import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/admin_notification_entity.dart';
import '../cubit/admin_notifications_cubit.dart';

class NotificationCreationDialog extends StatefulWidget {
  final Function(BulkNotificationData) onNotificationCreated;

  const NotificationCreationDialog({
    super.key,
    required this.onNotificationCreated,
  });

  @override
  State<NotificationCreationDialog> createState() =>
      _NotificationCreationDialogState();
}

class _NotificationCreationDialogState
    extends State<NotificationCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _titleArController = TextEditingController();
  final _bodyController = TextEditingController();
  final _bodyArController = TextEditingController();

  NotificationType _selectedType = NotificationType.general;
  NotificationPriority _selectedPriority = NotificationPriority.normal;
  TargetType _selectedTargetType = TargetType.all;
  String? _selectedGovernorate;
  String? _selectedUserType;
  DateTime? _scheduledAt;
  bool _sendImmediately = true;

  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الشرقية',
    'القليوبية',
    'كفر الشيخ',
    'الغربية',
    'المنوفية',
    'البحيرة',
  ];

  final List<String> _userTypes = [
    'مواطن عادي',
    'موظف حكومي',
    'صحفي',
    'مسؤول محلي',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        constraints: BoxConstraints(maxWidth: 600.w, maxHeight: 700.h),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.notification_add,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'إنشاء إشعار جديد',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title fields
                      _buildTextField(
                        controller: _titleController,
                        label: 'العنوان',
                        hint: 'أدخل عنوان الإشعار',
                        required: true,
                        maxLines: 2,
                      ),

                      SizedBox(height: 16.h),

                      _buildTextField(
                        controller: _titleArController,
                        label: 'العنوان بالعربية (اختياري)',
                        hint: 'أدخل العنوان بالعربية',
                        maxLines: 2,
                      ),

                      SizedBox(height: 16.h),

                      // Body fields
                      _buildTextField(
                        controller: _bodyController,
                        label: 'المحتوى',
                        hint: 'أدخل محتوى الإشعار',
                        required: true,
                        maxLines: 4,
                      ),

                      SizedBox(height: 16.h),

                      _buildTextField(
                        controller: _bodyArController,
                        label: 'المحتوى بالعربية (اختياري)',
                        hint: 'أدخل المحتوى بالعربية',
                        maxLines: 4,
                      ),

                      SizedBox(height: 24.h),

                      // Settings
                      Text(
                        'إعدادات الإشعار',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Type and Priority
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<NotificationType>(
                              label: 'النوع',
                              value: _selectedType,
                              items:
                                  NotificationType.values
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type.arabicName),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() => _selectedType = value!);
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildDropdown<NotificationPriority>(
                              label: 'الأولوية',
                              value: _selectedPriority,
                              items:
                                  NotificationPriority.values
                                      .map(
                                        (priority) => DropdownMenuItem(
                                          value: priority,
                                          child: Text(priority.arabicName),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() => _selectedPriority = value!);
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Target selection
                      _buildDropdown<TargetType>(
                        label: 'الجمهور المستهدف',
                        value: _selectedTargetType,
                        items:
                            TargetType.values
                                .map(
                                  (target) => DropdownMenuItem(
                                    value: target,
                                    child: Text(target.arabicName),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTargetType = value!;
                            _selectedGovernorate = null;
                            _selectedUserType = null;
                          });
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Target-specific options
                      if (_selectedTargetType == TargetType.governorate) ...[
                        _buildDropdown<String>(
                          label: 'المحافظة',
                          value: _selectedGovernorate,
                          items:
                              _governorates
                                  .map(
                                    (gov) => DropdownMenuItem(
                                      value: gov,
                                      child: Text(gov),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() => _selectedGovernorate = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                      ] else if (_selectedTargetType ==
                          TargetType.userType) ...[
                        _buildDropdown<String>(
                          label: 'نوع المستخدم',
                          value: _selectedUserType,
                          items:
                              _userTypes
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() => _selectedUserType = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // Scheduling options
                      SwitchListTile(
                        title: const Text('إرسال فوري'),
                        subtitle: Text(
                          _sendImmediately
                              ? 'سيتم الإرسال فوراً'
                              : 'سيتم جدولة الإرسال',
                        ),
                        value: _sendImmediately,
                        onChanged: (value) {
                          setState(() => _sendImmediately = value);
                        },
                        activeColor: const Color(0xFF2E7D32),
                      ),

                      if (!_sendImmediately) ...[
                        SizedBox(height: 16.h),
                        InkWell(
                          onTap: _selectScheduledTime,
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule),
                                SizedBox(width: 12.w),
                                Text(
                                  _scheduledAt != null
                                      ? 'موعد الإرسال: ${_formatDateTime(_scheduledAt!)}'
                                      : 'اختر موعد الإرسال',
                                  style: TextStyle(
                                    color:
                                        _scheduledAt != null
                                            ? Colors.black87
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: _createNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      _sendImmediately ? 'إرسال الآن' : 'جدولة الإرسال',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
          validator:
              required
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'هذا الحقل مطلوب';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectScheduledTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _scheduledAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _createNotification() {
    if (!_formKey.currentState!.validate()) return;

    // Validate target-specific fields
    if (_selectedTargetType == TargetType.governorate &&
        _selectedGovernorate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار المحافظة')));
      return;
    }

    if (_selectedTargetType == TargetType.userType &&
        _selectedUserType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار نوع المستخدم')));
      return;
    }

    if (!_sendImmediately && _scheduledAt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار موعد الإرسال')));
      return;
    }

    // Get target value
    dynamic targetValue;
    switch (_selectedTargetType) {
      case TargetType.all:
        targetValue = 'all';
        break;
      case TargetType.governorate:
        targetValue = _selectedGovernorate;
        break;
      case TargetType.userType:
        targetValue = _selectedUserType;
        break;
      case TargetType.specificUsers:
        targetValue = []; // Would need user selection UI
        break;
    }

    final notificationData = BulkNotificationData(
      title: _titleController.text.trim(),
      titleAr:
          _titleArController.text.trim().isNotEmpty
              ? _titleArController.text.trim()
              : null,
      body: _bodyController.text.trim(),
      bodyAr:
          _bodyArController.text.trim().isNotEmpty
              ? _bodyArController.text.trim()
              : null,
      type: _selectedType,
      priority: _selectedPriority,
      targetType: _selectedTargetType,
      targetValue: targetValue,
      scheduledAt: _sendImmediately ? null : _scheduledAt,
      sendImmediately: _sendImmediately,
    );

    Navigator.pop(context);
    widget.onNotificationCreated(notificationData);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
