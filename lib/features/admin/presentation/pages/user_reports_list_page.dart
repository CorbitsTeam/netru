// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../core/theme/app_colors.dart';
// import '../../domain/entities/report_summary_entity.dart';

// class UserReportsListPage extends StatelessWidget {
//   final List<ReportSummaryEntity> reports;
//   final String userName;
//   final int totalReportsCount;

//   const UserReportsListPage({
//     super.key,
//     required this.reports,
//     required this.userName,
//     required this.totalReportsCount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text(
//           'بلاغات $userName',
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: AppColors.primary,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildSummaryHeader(),
//           Expanded(
//             child: reports.isEmpty ? _buildEmptyState() : _buildReportsList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryHeader() {
//     return Container(
//       margin: EdgeInsets.all(16.w),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withValues(alpha: 0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.assessment, color: AppColors.primary, size: 24.sp),
//           SizedBox(width: 12.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'إجمالي البلاغات المقدمة',
//                 style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//               ),
//               Text(
//                 totalReportsCount.toString(),
//                 style: TextStyle(
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.report_off, size: 64.sp, color: Colors.grey[400]),
//           SizedBox(height: 16.h),
//           Text(
//             'لا توجد بلاغات مقدمة',
//             style: TextStyle(
//               fontSize: 18.sp,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'لم يقم هذا المستخدم بتقديم أي بلاغات بعد',
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReportsList() {
//     return ListView.builder(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       itemCount: reports.length,
//       itemBuilder: (context, index) {
//         final report = reports[index];
//         return _buildReportCard(report, index);
//       },
//     );
//   }

//   Widget _buildReportCard(ReportSummaryEntity report, int index) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 12.h),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       child: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     report.title,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//                 _buildStatusChip(report.status),
//               ],
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               report.description,
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
//             SizedBox(height: 12.h),
//             Row(
//               children: [
//                 _buildPriorityChip(report.priority),
//                 SizedBox(width: 8.w),
//                 if (report.categoryName != null)
//                   _buildInfoChip(
//                     report.categoryName!,
//                     Icons.category,
//                     Colors.blue,
//                   ),
//               ],
//             ),
//             SizedBox(height: 8.h),
//             Row(
//               children: [
//                 Icon(Icons.location_on, size: 14.sp, color: Colors.grey[600]),
//                 SizedBox(width: 4.w),
//                 Text(
//                   '${report.governorate ?? 'غير محدد'} - ${report.city ?? 'غير محدد'}',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                 ),
//                 const Spacer(),
//                 Icon(Icons.date_range, size: 14.sp, color: Colors.grey[600]),
//                 SizedBox(width: 4.w),
//                 Text(
//                   _formatDate(report.createdAt),
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//             if (report.assignedToName != null) ...[
//               SizedBox(height: 8.h),
//               Row(
//                 children: [
//                   Icon(Icons.person, size: 14.sp, color: Colors.grey[600]),
//                   SizedBox(width: 4.w),
//                   Text(
//                     'مُحال إلى: ${report.assignedToName}',
//                     style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(ReportStatus status) {
//     Color color = _getStatusColor(status);
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//       ),
//       child: Text(
//         status.arabicName,
//         style: TextStyle(
//           fontSize: 12.sp,
//           fontWeight: FontWeight.w500,
//           color: color,
//         ),
//       ),
//     );
//   }

//   Widget _buildPriorityChip(ReportPriority priority) {
//     Color color = _getPriorityColor(priority);
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(_getPriorityIcon(priority), size: 12.sp, color: color),
//           SizedBox(width: 4.w),
//           Text(
//             priority.arabicName,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w500,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoChip(String text, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12.sp, color: color),
//           SizedBox(width: 4.w),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w500,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(ReportStatus status) {
//     switch (status) {
//       case ReportStatus.pending:
//         return Colors.orange;
//       case ReportStatus.underReview:
//         return Colors.blue;
//       case ReportStatus.inProgress:
//         return Colors.purple;
//       case ReportStatus.resolved:
//         return Colors.green;
//       case ReportStatus.rejected:
//         return Colors.red;
//       case ReportStatus.closed:
//         return Colors.grey;
//     }
//   }

//   Color _getPriorityColor(ReportPriority priority) {
//     switch (priority) {
//       case ReportPriority.low:
//         return Colors.green;
//       case ReportPriority.medium:
//         return Colors.orange;
//       case ReportPriority.high:
//         return Colors.red;
//       case ReportPriority.urgent:
//         return Colors.deepOrange;
//     }
//   }

//   IconData _getPriorityIcon(ReportPriority priority) {
//     switch (priority) {
//       case ReportPriority.low:
//         return Icons.keyboard_arrow_down;
//       case ReportPriority.medium:
//         return Icons.remove;
//       case ReportPriority.high:
//         return Icons.keyboard_arrow_up;
//       case ReportPriority.urgent:
//         return Icons.priority_high;
//     }
//   }

//   String _formatDate(DateTime dateTime) {
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//   }
// }
