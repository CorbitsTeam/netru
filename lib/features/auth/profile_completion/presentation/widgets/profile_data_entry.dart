import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_entity.dart';

class ProfileDataEntry extends StatefulWidget {
  final UserType userType;
  final Map<String, String> currentData;
  final Function(Map<String, String>) onDataChanged;

  const ProfileDataEntry({
    super.key,
    required this.userType,
    required this.currentData,
    required this.onDataChanged,
  });

  @override
  State<ProfileDataEntry> createState() => _ProfileDataEntryState();
}

class _ProfileDataEntryState extends State<ProfileDataEntry> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {
      'fullName': TextEditingController(
        text: widget.currentData['fullName'] ?? '',
      ),
      'phone': TextEditingController(text: widget.currentData['phone'] ?? ''),
      'nationalId': TextEditingController(
        text: widget.currentData['nationalId'] ?? '',
      ),
      'passportNumber': TextEditingController(
        text: widget.currentData['passportNumber'] ?? '',
      ),
    };

    // Add listeners to update parent widget
    _controllers.forEach((key, controller) {
      controller.addListener(() => _updateData());
    });
  }

  void _updateData() {
    final data = <String, String>{};
    _controllers.forEach((key, controller) {
      data[key] = controller.text;
    });
    widget.onDataChanged(data);
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _controllers['fullName']!,
            label: 'الاسم الكامل',
            hint: 'أدخل اسمك الكامل',
            icon: Icons.person_outline,
            validator: (value) {
              if (value?.trim().isEmpty == true) {
                return 'الاسم الكامل مطلوب';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          _buildTextField(
            controller: _controllers['phone']!,
            label: 'رقم الهاتف',
            hint: 'أدخل رقم الهاتف',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.trim().isEmpty == true) {
                return 'رقم الهاتف مطلوب';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          if (widget.userType == UserType.citizen)
            _buildTextField(
              controller: _controllers['nationalId']!,
              label: 'الرقم القومي',
              hint: 'أدخل الرقم القومي (14 رقم)',
              icon: Icons.credit_card_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (widget.userType == UserType.citizen) {
                  if (value?.trim().isEmpty == true) {
                    return 'الرقم القومي مطلوب';
                  }
                  if (value!.length != 14) {
                    return 'الرقم القومي يجب أن يكون 14 رقم';
                  }
                }
                return null;
              },
            ),
          if (widget.userType == UserType.foreigner)
            _buildTextField(
              controller: _controllers['passportNumber']!,
              label: 'رقم جواز السفر',
              hint: 'أدخل رقم جواز السفر',
              icon: Icons.flight_outlined,
              validator: (value) {
                if (widget.userType == UserType.foreigner) {
                  if (value?.trim().isEmpty == true) {
                    return 'رقم جواز السفر مطلوب';
                  }
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
            fontFamily: 'Almarai',
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF1F2937),
            fontFamily: 'Almarai',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 12.sp,
              fontFamily: 'Almarai',
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }
}
