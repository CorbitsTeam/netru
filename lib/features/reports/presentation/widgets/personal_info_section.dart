import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/reports/presentation/widgets/custom_info_container.dart';

import '../../../../core/theme/app_colors.dart';

class PersonalInfoSection
    extends StatelessWidget {
  const PersonalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      spacing: 10.h,
      children: [
        Text(
          'personalInfo'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomInfoContainer(
                label: 'firstName'.tr(),
                value: 'أحمد',
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: CustomInfoContainer(
                label: 'lastName'.tr(),
                value: 'القناوي',
              ),
            ),
          ],
        ),
        CustomInfoContainer(
          label: 'idNumber'.tr(),
          value: '30205047915647',
        ),
        CustomInfoContainer(
          label: 'phone'.tr(),
          value: '012345678911',
        ),
      ],
    );
  }
}
