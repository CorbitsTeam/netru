import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_constants.dart';
import 'package:netru_app/features/reports/presentation/widgets/custom_info_container.dart';

class ReportInfoSection extends StatelessWidget {
  const ReportInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      spacing: 10.h,
      children: [
        Text(
          'reportInfo'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        CustomInfoContainer(
          label: 'reportType'.tr(),
          value: 'سرقة',
        ),
        CustomInfoContainer(
          height: 80.h,
          label: 'reportDescription'.tr(),
          value:
              'تعرضت للسرقة أثناء خروجي من محطة المترو، حيث قام شخصان يستقلان دراجة بخطف هاتفي المحمول ولاذا بالفرار بسرعة.',
        ),
        CustomInfoContainer(
          label: 'location'.tr(),
          value:
              'عبد الحميد دبس، المطار، إمبابة، محافظة الجيزة',
        ),
        CustomInfoContainer(
          label: 'reportDate'.tr(),
          value: '16 أغسطس 2026 - 6:45 م',
        ),
      ],
    );
  }
}
