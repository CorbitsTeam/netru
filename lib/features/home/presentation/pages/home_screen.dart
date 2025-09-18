import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart';
import 'package:netru_app/features/home/presentation/widgets/news_carousel_card.dart';
import 'package:netru_app/features/home/presentation/widgets/news_list_widget.dart';
import 'package:netru_app/features/home/presentation/widgets/home_up_bar.dart';
import 'package:netru_app/features/home/presentation/widgets/latest_cases_card.dart';
import 'package:netru_app/features/home/presentation/widgets/statistics_cards.dart';
import 'package:netru_app/features/home/presentation/widgets/trending_cases_card.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_cubit.dart';

import '../../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewsCubit>(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeUpBar(),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "جهود الأجهزة الأمنية",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  const NewsCarouselCard(),
                  SizedBox(height: 15.h),
                  Text(
                    "statistics".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  const StatisticsCards(),
                  SizedBox(height: 15.h),
                  const NewsListWidget(maxItems: 5, headerTitle: "أحدث الأخبار"),
                  SizedBox(height: 15.h),
                  Text(
                    "latestCases".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  const LatestCasesCard(),
                  SizedBox(height: 15.h),
                  Text(
                    "trendingCases".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  const TrendingCasesCard(),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
