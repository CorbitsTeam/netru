import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/extracted_document_data.dart';

class DataEntryStep extends StatefulWidget {
  final UserType userType;
  final ExtractedDocumentData? extractedData;
  final Function(Map<String, String>) onDataChanged;
  final Map<String, String> currentData;

  const DataEntryStep({
    super.key,
    required this.userType,
    this.extractedData,
    required this.onDataChanged,
    required this.currentData,
  });

  @override
  State<DataEntryStep> createState() => _DataEntryStepState();
}

class _DataEntryStepState extends State<DataEntryStep> {
  late final Map<String, TextEditingController> _controllers;
  bool _isPopulating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _populateFromExtractedData();
    _addControllerListeners();
  }

  void _initializeControllers() {
    _controllers = {
      'fullName': TextEditingController(
        text: widget.currentData['fullName'] ?? '',
      ),
      'nationalId': TextEditingController(
        text: widget.currentData['nationalId'] ?? '',
      ),
      'birthDate': TextEditingController(
        text: widget.currentData['birthDate'] ?? '',
      ),
      'address': TextEditingController(
        text: widget.currentData['address'] ?? '',
      ),
      'phone': TextEditingController(text: widget.currentData['phone'] ?? ''),
      'email': TextEditingController(text: widget.currentData['email'] ?? ''),
      'password': TextEditingController(
        text: widget.currentData['password'] ?? '',
      ),
    };
    if (widget.userType == UserType.foreigner) {
      _controllers.addAll({
        'passportNumber': TextEditingController(
          text: widget.currentData['passportNumber'] ?? '',
        ),
        'nationality': TextEditingController(
          text: widget.currentData['nationality'] ?? '',
        ),
        'passportIssueDate': TextEditingController(
          text: widget.currentData['passportIssueDate'] ?? '',
        ),
        'passportExpiryDate': TextEditingController(
          text: widget.currentData['passportExpiryDate'] ?? '',
        ),
      });
    }
  }

  void _addControllerListeners() {
    // Attach listeners after initial population to avoid firing during build
    _controllers.forEach((key, controller) {
      controller.addListener(() {
        if (_isPopulating)
          return; // ignore changes during programmatic population
        final updatedData = Map<String, String>.from(widget.currentData);
        updatedData[key] = controller.text;

        // Schedule parent update after the current frame to avoid calling setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onDataChanged(updatedData);
        });
      });
    });
  }

  void _populateFromExtractedData() {
    if (widget.extractedData != null) {
      _isPopulating = true;
      final data = widget.extractedData!;

      _controllers['fullName']?.text = data.fullName ?? '';
      _controllers['nationalId']?.text = data.nationalId ?? '';
      _controllers['birthDate']?.text =
          data.birthDate?.toString().split(' ')[0] ?? '';
      _controllers['address']?.text = data.address ?? '';

      if (widget.userType == UserType.foreigner) {
        _controllers['passportNumber']?.text = data.passportNumber ?? '';
        _controllers['nationality']?.text = data.nationality ?? '';
        _controllers['passportIssueDate']?.text =
            data.passportIssueDate?.toString().split(' ')[0] ?? '';
        _controllers['passportExpiryDate']?.text =
            data.passportExpiryDate?.toString().split(' ')[0] ?? '';
      }
      // allow listeners again
      _isPopulating = false;
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Title
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'تأكيد البيانات الشخصية',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: Text(
                  'تأكد من صحة البيانات المستخرجة من المستند وقم بتعديلها إذا لزم الأمر',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Basic Information Section
              _buildSectionTitle('البيانات الأساسية', 0),
              SizedBox(height: 16.h),
              _buildBasicFields(),

              SizedBox(height: 32.h),

              // Contact Information Section
              _buildSectionTitle('بيانات التواصل', 1),
              SizedBox(height: 16.h),
              _buildContactFields(),

              if (widget.userType == UserType.foreigner) ...[
                SizedBox(height: 32.h),
                _buildSectionTitle('بيانات جواز السفر', 2),
                SizedBox(height: 16.h),
                _buildPassportFields(),
              ],

              SizedBox(height: 80.h), // Extra space for bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int index) {
    return FadeInUp(
      duration: Duration(milliseconds: 800 + (index * 100)),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicFields() {
    return Column(
      children: [
        _buildAnimatedField(
          controller: _controllers['fullName']!,
          label: 'الاسم الكامل',
          hint: 'أدخل الاسم الكامل كما هو مكتوب في المستند',
          prefixIcon: Icons.person_outline,
          animationDelay: 0,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'الاسم الكامل مطلوب';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildAnimatedField(
          controller: _controllers['nationalId']!,
          label:
              widget.userType == UserType.citizen
                  ? 'الرقم القومي'
                  : 'رقم الهوية',
          hint:
              widget.userType == UserType.citizen
                  ? 'أدخل الرقم القومي (14 رقم)'
                  : 'أدخل رقم الهوية',
          prefixIcon: Icons.badge_outlined,
          animationDelay: 100,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'رقم الهوية مطلوب';
            }
            final v = value ?? '';
            if (widget.userType == UserType.citizen && v.length != 14) {
              return 'الرقم القومي يجب أن يكون 14 رقم';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildAnimatedField(
          controller: _controllers['birthDate']!,
          label: 'تاريخ الميلاد',
          hint: 'YYYY-MM-DD',
          prefixIcon: Icons.calendar_today_outlined,
          animationDelay: 200,
          readOnly: true,
          onTap: () => _selectDate(context, _controllers['birthDate']!),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'تاريخ الميلاد مطلوب';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildAnimatedField(
          controller: _controllers['address']!,
          label: 'العنوان',
          hint: 'أدخل العنوان كما هو مكتوب في المستند',
          prefixIcon: Icons.location_on_outlined,
          animationDelay: 300,
          maxLines: 1,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'العنوان مطلوب';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        _buildAnimatedField(
          controller: _controllers['phone']!,
          label: 'رقم الهاتف',
          hint: 'أدخل رقم الهاتف',
          prefixIcon: Icons.phone_outlined,
          animationDelay: 400,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'رقم الهاتف مطلوب';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildAnimatedField(
          controller: _controllers['email']!,
          label: 'البريد الإلكتروني',
          hint: 'أدخل البريد الإلكتروني',
          prefixIcon: Icons.email_outlined,
          animationDelay: 500,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'البريد الإلكتروني مطلوب';
            }
            if (!RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(value ?? '')) {
              return 'البريد الإلكتروني غير صحيح';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildAnimatedField(
          controller: _controllers['password']!,
          label: 'كلمة المرور',
          hint: 'أدخل كلمة مرور قوية (6 أحرف على الأقل)',
          prefixIcon: Icons.lock_outline,
          animationDelay: 600,
          obscureText: true,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'كلمة المرور مطلوبة';
            }
            if ((value?.length ?? 0) < 6) {
              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPassportFields() {
    return Column(
      children: [
        _buildAnimatedField(
          controller: _controllers['passportNumber']!,
          label: 'رقم جواز السفر',
          hint: 'أدخل رقم جواز السفر',
          prefixIcon: Icons.assignment_outlined,
          animationDelay: 600,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'رقم جواز السفر مطلوب';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildAnimatedField(
          controller: _controllers['nationality']!,
          label: 'الجنسية',
          hint: 'أدخل الجنسية',
          prefixIcon: Icons.flag_outlined,
          animationDelay: 700,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'الجنسية مطلوبة';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        Row(
          children: [
            Expanded(
              child: _buildAnimatedField(
                controller: _controllers['passportIssueDate']!,
                label: 'تاريخ إصدار الجواز',
                hint: 'YYYY-MM-DD',
                prefixIcon: Icons.calendar_today_outlined,
                animationDelay: 800,
                readOnly: true,
                onTap:
                    () => _selectDate(
                      context,
                      _controllers['passportIssueDate']!,
                    ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'تاريخ إصدار الجواز مطلوب';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: _buildAnimatedField(
                controller: _controllers['passportExpiryDate']!,
                label: 'تاريخ انتهاء الجواز',
                hint: 'YYYY-MM-DD',
                prefixIcon: Icons.calendar_today_outlined,
                animationDelay: 900,
                readOnly: true,
                onTap:
                    () => _selectDate(
                      context,
                      _controllers['passportExpiryDate']!,
                    ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'تاريخ انتهاء الجواز مطلوب';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required int animationDelay,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return FadeInUp(
      duration: Duration(milliseconds: 800 + animationDelay),
      child: GestureDetector(
        onTap: readOnly ? onTap : null,
        child: AbsorbPointer(
          absorbing: readOnly,
          child: CustomTextField(
            controller: controller,
            label: label,
            hint: hint,
            prefixIcon: prefixIcon,
            validator: validator,
            keyboardType: keyboardType ?? TextInputType.text,
            maxLines: maxLines,
            obscureText: obscureText,
            enabled: !readOnly,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = picked.toString().split(' ')[0];
    }
  }

  bool get isValid => _formKey.currentState?.validate() ?? false;
}
