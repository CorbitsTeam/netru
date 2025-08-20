import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_constants.dart';
import 'package:netru_app/core/routing/routes.dart';

// Model للبيانات
class ReportData {
  final String reportNumber;
  final String reportType;
  final String date;
  final String location;
  final String status;
  final Color statusColor;

  ReportData({
    required this.reportNumber,
    required this.reportType,
    required this.date,
    required this.location,
    required this.status,
    required this.statusColor,
  });
}

class ReportCard extends StatelessWidget {
  final ReportData reportData;
  final VoidCallback? onDetailsPressed;

  const ReportCard({
    super.key,
    required this.reportData,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 115.h,
      margin: EdgeInsets.only(
          bottom: 12.h), // مسافة بين الكروت
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xffCBCBCB),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 15.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'بلاغ رقم #${reportData.reportNumber}',
                      style: TextStyle(
                          fontSize: 14.sp),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '| ${reportData.reportType}',
                      style: TextStyle(
                          fontSize: 14.sp),
                    ),
                  ],
                ),
                Container(
                  height: 25.h,
                  width: 135.w,
                  decoration: BoxDecoration(
                    color: reportData.statusColor,
                    borderRadius:
                        BorderRadius.circular(
                            12.r),
                  ),
                  child: Center(
                    child: Text(
                      reportData.status,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                Text(
                  reportData.date,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      reportData.location,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap:
                      onDetailsPressed ?? () {},
                  child: Row(
                    children: [
                      Text(
                        'تفاصيل البلاغ',
                        style: TextStyle(
                            fontSize: 12.sp),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// الصفحة الي هتعرض الـ ListView
class ReportsListPage extends StatelessWidget {
  const ReportsListPage({super.key});

  // دالة منفصلة لكل بلاغ حسب الرقم
  void _handleReportDetails(
      BuildContext context, String reportNumber) {
    switch (reportNumber) {
      case '21348':
        Navigator.pushNamed(
            context, Routes.reportDetailsPage);
        break;
      case '21349':
        print('عرض تفاصيل بلاغ الاحتيال #21349');
        break;
      case '21350':
        print('عرض تفاصيل بلاغ العنف #21350');
        break;
      case '21351':
        print('عرض تفاصيل بلاغ التحرش #21351');
        break;
      case '21352':
        print(
            'عرض تفاصيل بلاغ السرقة الثاني #21352');
        break;
      case '21353':
        print('عرض تفاصيل بلاغ النصب #21353');
        break;
      case '21354':
        print('عرض تفاصيل بلاغ الاعتداء #21354');
        break;
      case '21355':
        print(
            'عرض تفاصيل بلاغ السب والقذف #21355');
        break;
      default:
        print('بلاغ غير معروف: $reportNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    // البيانات التجريبية - تقدر تغيرها زي ما تحب
    final List<ReportData> reports = [
      ReportData(
        reportNumber: '21348',
        reportType: 'سرقة',
        date: '16 أغسطس 2026 - 6:45 م',
        location: 'القاهرة - مصر الجديدة',
        status: 'تحت المراجعة',
        statusColor: AppColors.grey,
      ),
      ReportData(
        reportNumber: '21349',
        reportType: 'احتيال',
        date: '17 أغسطس 2026 - 2:30 م',
        location: 'الجيزة - المهندسين',
        status: 'تم التحويل للجهات المعنية',
        statusColor: AppColors.orange,
      ),
      ReportData(
        reportNumber: '21350',
        reportType: 'عنف',
        date: '18 أغسطس 2026 - 10:15 ص',
        location: 'الإسكندرية - سموحة',
        status: 'تم الحل',
        statusColor: AppColors.green,
      ),
      ReportData(
        reportNumber: '21351',
        reportType: 'تحرش',
        date: '19 أغسطس 2026 - 8:20 م',
        location: 'القاهرة - وسط البلد',
        status: 'بلاغ كاذب',
        statusColor: AppColors.red,
      ),
      ReportData(
        reportNumber: '21352',
        reportType: 'سرقة',
        date: '20 أغسطس 2026 - 4:45 م',
        location: 'المنوفية - شبين الكوم',
        status: 'تحت المراجعة',
        statusColor: AppColors.grey,
      ),
      ReportData(
        reportNumber: '21353',
        reportType: 'نصب',
        date: '21 أغسطس 2026 - 11:30 ص',
        location: 'القليوبية - بنها',
        status: 'تم الحل',
        statusColor: AppColors.green,
      ),
      ReportData(
        reportNumber: '21354',
        reportType: 'اعتداء',
        date: '22 أغسطس 2026 - 7:15 م',
        location: 'البحيرة - دمنهور',
        status: 'بلاغ كاذب',
        statusColor: AppColors.red,
      ),
      ReportData(
        reportNumber: '21355',
        reportType: 'سب وقذف',
        date: '23 أغسطس 2026 - 1:00 م',
        location: 'المنيا - ملوي',
        status: 'تم الحل',
        statusColor: AppColors.green,
      ),
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return ReportCard(
            reportData: reports[index],
            onDetailsPressed: () {
              _handleReportDetails(context,
                  reports[index].reportNumber);
            },
          );
        },
      ),
    );
  }
}
