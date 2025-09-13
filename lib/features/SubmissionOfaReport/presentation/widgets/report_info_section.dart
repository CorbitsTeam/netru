import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/helper/validation_helper.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'custom_text_field.dart';

class ReportInfoSection extends StatelessWidget {
  final TextEditingController
  reportTypeController;
  final TextEditingController
  reportDetailsController;
  final List<String> reportTypes;

  const ReportInfoSection({
    super.key,
    required this.reportTypeController,
    required this.reportDetailsController,
    required this.reportTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات البلاغ',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 10.h),
        // Report Type Dropdown
        CustomDropdownField(
          controller: reportTypeController,
          label: 'نوع البلاغ',
          items: reportTypes,
          validator:
              ValidationHelper.validateReportType,
          hintText: 'اختر نوع البلاغ',
        ),
        SizedBox(height: 10.h),

        // Report Details Field
        CustomTextField(
          controller: reportDetailsController,
          label: 'تفاصيل البلاغ',
          hintText:
              'اكتب تفاصيل البلاغ هنا... (اختياري)',
          maxLines: 5,
          isRequired: false,
          validator:
              ValidationHelper
                  .validateReportDetails,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
