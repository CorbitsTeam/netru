import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProceduresSection extends StatelessWidget {
  const ProceduresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: const Color(0xFF1E3A8A),
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'الإجراءات المتخذة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Procedures List
            _buildProcedureItem(
              'تم استلام البلاغ',
              'تم استلام البلاغ وتسجيله في النظام',
              Icons.check_circle,
              Colors.green,
              isCompleted: true,
            ),
            SizedBox(height: 12.h),

            _buildProcedureItem(
              'قيد المراجعة',
              'يتم مراجعة البلاغ من قبل الفريق المختص',
              Icons.visibility,
              Colors.orange,
              isCompleted: true,
            ),
            SizedBox(height: 12.h),

            _buildProcedureItem(
              'التحقق من البيانات',
              'سيتم التحقق من صحة البيانات المرسلة',
              Icons.verified,
              Colors.blue,
              isCompleted: false,
            ),
            SizedBox(height: 12.h),

            _buildProcedureItem(
              'اتخاذ الإجراء المناسب',
              'سيتم اتخاذ الإجراء المناسب حسب نوع البلاغ',
              Icons.gavel,
              Colors.purple,
              isCompleted: false,
            ),
            SizedBox(height: 16.h),

            // Status Note
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFF1E3A8A).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF1E3A8A),
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'سيتم إعلامك بأي تحديثات جديدة عبر الإشعارات',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureItem(
    String title,
    String description,
    IconData icon,
    Color color, {
    required bool isCompleted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Icon
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: Colors.white,
            size: 16.w,
          ),
        ),
        SizedBox(width: 12.w),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.black87 : Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
