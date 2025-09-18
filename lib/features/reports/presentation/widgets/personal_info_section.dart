import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/helper/validation_helper.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'custom_text_field.dart';

class PersonalInfoSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController nationalIdController;
  final TextEditingController phoneController;

  const PersonalInfoSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.nationalIdController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'المعلومات الشخصية',
          style: TextStyle(fontSize: 16.sp, color: AppColors.primaryColor),
        ),
        SizedBox(height: 10.h),

        // First Name and Last Name Row
        Row(
          children: [
            // First Name Field
            Expanded(
              child: CustomTextField(
                controller: firstNameController,
                label: 'الاسم الأول',
                hintText: 'أدخل الاسم الأول',
                validator: ValidationHelper.validateName,
                keyboardType: TextInputType.text,
                readOnly: true,
              ),
            ),
            SizedBox(width: 12.w),

            // Last Name Field
            Expanded(
              child: CustomTextField(
                controller: lastNameController,
                label: 'الاسم الأخير',
                hintText: 'أدخل الاسم الأخير',
                validator: ValidationHelper.validateName,
                keyboardType: TextInputType.text,
                readOnly: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // National ID Field
        CustomTextField(
          controller: nationalIdController,
          label: 'الرقم القومي',
          hintText: 'أدخل الرقم القومي (14 رقم)',
          validator: ValidationHelper.validateNationalId,
          keyboardType: TextInputType.number,
          maxLength: 14,

          readOnly: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
          ],
          prefixIcon: const Icon(Icons.credit_card, color: Colors.grey),
        ),
        SizedBox(height: 10.sp),

        // Phone Number Field
        CustomTextField(
          controller: phoneController,
          label: 'رقم الهاتف',
          hintText: 'أدخل رقم الهاتف (11 رقم)',
          validator: ValidationHelper.validatePhone,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
        ),
      ],
    );
  }
}
