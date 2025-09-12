import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/reports/presentation/widgets/media_section.dart';
import 'package:netru_app/features/reports/presentation/widgets/personal_info_section.dart';
import 'package:netru_app/features/reports/presentation/widgets/procedures_section.dart';
import 'package:netru_app/features/reports/presentation/widgets/report_info_section.dart';

class ReportDetailsPage extends StatelessWidget {
  const ReportDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'reportDetails'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15.h,
                ),
                const PersonalInfoSection(),
                SizedBox(
                  height: 15.h,
                ),
                const ReportInfoSection(),
                SizedBox(
                  height: 15.h,
                ),
                const MediaSection(),
                SizedBox(
                  height: 15.h,
                ),
                const ProceduresSection(),
                SizedBox(
                  height: 15.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
