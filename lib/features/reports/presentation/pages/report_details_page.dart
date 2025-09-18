import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/media_section.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/report_info_section.dart';
import '../widgets/procedures_section.dart';

class ReportDetailsPage extends StatelessWidget {
  const ReportDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create dummy controllers for display purposes
    final firstNameController = TextEditingController(text: 'أحمد محمد');
    final lastNameController = TextEditingController(text: 'العلي');
    final nationalIdController = TextEditingController(text: '123456789012');
    final phoneController = TextEditingController(text: '+966501234567');
    final reportTypeController = TextEditingController(text: 'سرقة');
    final reportDetailsController = TextEditingController(
      text: 'تفاصيل البلاغ: تم سرقة المحفظة من السوق التجاري أمس المساء.',
    );

    final List<String> reportTypes = [
      'سرقة',
      'عنف أسري',
      'بلاغ مفقودات',
      'أعمال شغب او تجمع غير قانوني',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'reportDetails'.tr(),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h),
                PersonalInfoSection(
                  firstNameController: firstNameController,
                  lastNameController: lastNameController,
                  nationalIdController: nationalIdController,
                  phoneController: phoneController,
                ),
                SizedBox(height: 15.h),
                ReportInfoSection(
                  reportTypeController: reportTypeController,
                  reportDetailsController: reportDetailsController,
                  reportTypes: reportTypes,
                ),
                SizedBox(height: 15.h),
                const MediaSection(),
                SizedBox(height: 15.h),
                const ProceduresSection(),
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
