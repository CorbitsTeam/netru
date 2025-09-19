import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart';
import 'package:netru_app/features/cases/presentation/cubit/cases_cubit.dart';
import 'package:netru_app/features/cases/presentation/cubit/cases_state.dart';
import 'package:netru_app/features/cases/data/models/case_model.dart';
import 'package:netru_app/core/services/logger_service.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class LatestCasesCard extends StatefulWidget {
  const LatestCasesCard({super.key});

  @override
  State<LatestCasesCard> createState() => _LatestCasesCardState();
}

class _LatestCasesCardState extends State<LatestCasesCard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    // إعداد animation controller للـ slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // بدء الـ animation الأولى
    _slideController.forward();

    // تحميل أحدث القضايا — فقط إذا كانت التبعيات مسجلة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isDependencyRegistered<CasesCubit>()) {
        try {
          context.read<CasesCubit>().loadLatestCases(limit: 3);
        } catch (_) {
          // إذا حدث خطأ أثناء القراءة نتجاهله هنا لأن الـ build سيعرض رسالة مناسبة
        }
      } else {
        // قد يحدث هذا أثناء الـ hot-reload عندما لا تُعاد تهيئة GetIt.
        // تسجيل رسالة مساعدة في السجل لتسهيل التصحيح.
        sl.get<LoggerService>().logInfo(
          '⚠️ CasesCubit غير مسجل في GetIt — قد تحتاج لإعادة تشغيل التطبيق (full restart) بعد تغييرات DI.',
        );
      }
    });
  }

  void _nextSlide(int maxLength) async {
    if (_currentIndex < maxLength - 1) {
      // slide out للصورة الحالية
      await _slideController.reverse();
      setState(() {
        _currentIndex = _currentIndex + 1;
      });
      // slide in للصورة الجديدة
      _slideController.forward();
    }
  }

  void _previousSlide() async {
    if (_currentIndex > 0) {
      // slide out للصورة الحالية
      await _slideController.reverse();
      setState(() {
        _currentIndex = _currentIndex - 1;
      });
      // slide in للصورة الجديدة
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حماية سريعة: إذا لم يتم تسجيل CasesCubit في GetIt (مثلاً بعد hot-reload)
    // نعرض بطاقة مساعدة بدل رمي الاستثناء.
    if (!isDependencyRegistered<CasesCubit>()) {
      return _buildRegistrationErrorCard();
    }

    return BlocProvider(
      create: (_) => sl<CasesCubit>(),
      child: BlocBuilder<CasesCubit, CasesState>(
        builder: (context, state) {
          if (state is CasesLoading) {
            return _buildLoadingCard();
          }

          if (state is CasesError) {
            return _buildErrorCard(state.message);
          }

          if (state is LatestCasesLoaded) {
            if (state.cases.isEmpty) {
              return _buildEmptyCard();
            }

            return _buildCasesCarousel(state.cases);
          }

          return _buildEmptyCard();
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey[200],
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.w,
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'خطأ في تحميل القضايا',
              style: TextStyle(fontSize: 14.sp, color: Colors.red[700]),
            ),
            SizedBox(height: 4.h),
            Text(
              message.length > 50 ? '${message.substring(0, 50)}...' : message,
              style: TextStyle(fontSize: 12.sp, color: Colors.red[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, color: Colors.grey[600], size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'لا توجد قضايا حديثة',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationErrorCard() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.yellow[50],
        border: Border.all(color: Colors.yellow.withOpacity(0.6)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.orange, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'لم يتم تهيئة تبعيات القضايا بعد.',
              style: TextStyle(fontSize: 14.sp, color: Colors.orange[800]),
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'إذا كنت داخل عملية الـ hot-reload بعد تعديل DI، قم بعمل "Restart" كامل للتطبيق لتطبيق التغييرات.',
                style: TextStyle(fontSize: 12.sp, color: Colors.orange[700]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesCarousel(List<CaseModel> cases) {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // الصورة الخلفية مع الـ slide animation
            ...List.generate(cases.length, (index) {
              return Positioned.fill(
                child: AnimatedOpacity(
                  opacity: index == _currentIndex ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildCaseImage(cases[index]),
                ),
              );
            }),
            // طبقة شفافة سوداء للنص
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
            // السهم الأيسر
            if (_currentIndex > 0)
              Positioned(
                left: 12.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _previousSlide,
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ),
            // السهم الأيمن
            if (_currentIndex < cases.length - 1)
              Positioned(
                right: 12.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _nextSlide(cases.length),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ),
            // المحتوى النصي والنقط
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // التاريخ والأولوية مع النقط في نفس الصف
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // التاريخ والأولوية
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                  cases[_currentIndex].priority,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                cases[_currentIndex].priorityText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _formatDate(cases[_currentIndex].incidentDate),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // النقط المتحركة
                      Row(
                        children: List.generate(
                          cases.length,
                          (index) => Container(
                            margin: EdgeInsets.only(left: 6.w),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: index == _currentIndex ? 16.w : 6.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color:
                                    index == _currentIndex
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // العنوان
                  Text(
                    cases[_currentIndex].displayTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  SizedBox(height: 4.h),

                  // الموقع
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withOpacity(0.8),
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          cases[_currentIndex].displayLocation,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseImage(CaseModel caseModel) {
    // استخدام صورة افتراضية بناءً على نوع القضية
    return Image.asset(_getDefaultImageForCase(caseModel), fit: BoxFit.cover);
  }

  String _getDefaultImageForCase(CaseModel caseModel) {
    // يمكن تحسين هذا بناءً على نوع القضية أو الأولوية
    switch (caseModel.priority) {
      case 'urgent':
      case 'high':
        return AppAssets.newsImage2;
      default:
        return AppAssets.newsImages;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
