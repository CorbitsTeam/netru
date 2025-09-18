// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:netru_app/core/theme/app_colors.dart';
// import '../../domain/entities/reports_entity.dart';
// import 'package:intl/intl.dart';

// class ReportStatusTracker extends StatelessWidget {
//   final ReportStatus currentStatus;
//   final DateTime? createdAt;

//   const ReportStatusTracker({
//     super.key,
//     required this.currentStatus,
//     this.createdAt,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10.w),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Icon(
//                   Icons.timeline,
//                   color: AppColors.primaryColor,
//                   size: 24.sp,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'تتبع حالة البلاغ',
//                       style: TextStyle(
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       'تابع حالة بلاغك خطوة بخطوة',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(currentStatus).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Text(
//                   currentStatus.arabicName,
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     fontWeight: FontWeight.w600,
//                     color: _getStatusColor(currentStatus),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 24.h),

//           // Status Steps
//           Column(
//             children: [
//               _buildStatusStep(
//                 title: 'تم استلام البلاغ',
//                 description: 'تم استلام البلاغ وتسجيله في النظام',
//                 icon: Icons.assignment_turned_in,
//                 color: Colors.green,
//                 status: ReportStatus.received,
//                 isCompleted: _isStepCompleted(ReportStatus.received),
//                 isActive: currentStatus == ReportStatus.received,
//               ),

//               _buildConnectorLine(_isStepCompleted(ReportStatus.underReview)),

//               _buildStatusStep(
//                 title: 'قيد المراجعة',
//                 description: 'يتم مراجعة البلاغ من قبل الفريق المختص',
//                 icon: Icons.search,
//                 color: Colors.orange,
//                 status: ReportStatus.underReview,
//                 isCompleted: _isStepCompleted(ReportStatus.underReview),
//                 isActive: currentStatus == ReportStatus.underReview,
//               ),

//               _buildConnectorLine(
//                 _isStepCompleted(ReportStatus.dataVerification),
//               ),

//               _buildStatusStep(
//                 title: 'التحقق من البيانات',
//                 description: 'سيتم التحقق من صحة البيانات المرسلة',
//                 icon: Icons.fact_check,
//                 color: Colors.blue,
//                 status: ReportStatus.dataVerification,
//                 isCompleted: _isStepCompleted(ReportStatus.dataVerification),
//                 isActive: currentStatus == ReportStatus.dataVerification,
//               ),

//               _buildConnectorLine(_isStepCompleted(ReportStatus.actionTaken)),

//               _buildStatusStep(
//                 title: 'اتخاذ الإجراء المناسب',
//                 description: 'سيتم اتخاذ الإجراء المناسب حسب نوع البلاغ',
//                 icon: Icons.engineering,
//                 color: Colors.purple,
//                 status: ReportStatus.actionTaken,
//                 isCompleted: _isStepCompleted(ReportStatus.actionTaken),
//                 isActive: currentStatus == ReportStatus.actionTaken,
//               ),

//               _buildConnectorLine(_isStepCompleted(ReportStatus.completed)),

//               _buildStatusStep(
//                 title: 'اكتمال البلاغ',
//                 description: 'تم إنجاز البلاغ بنجاح',
//                 icon: Icons.check_circle,
//                 color: Colors.green,
//                 status: ReportStatus.completed,
//                 isCompleted: _isStepCompleted(ReportStatus.completed),
//                 isActive: currentStatus == ReportStatus.completed,
//                 isLast: true,
//               ),
//             ],
//           ),

//           // Rejected status if applicable
//           if (currentStatus == ReportStatus.rejected) ...[
//             SizedBox(height: 20.h),
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(color: Colors.red.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.cancel, color: Colors.red, size: 24.sp),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'تم رفض البلاغ',
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red[700],
//                           ),
//                         ),
//                         SizedBox(height: 4.h),
//                         Text(
//                           'لم يتم قبول البلاغ لأسباب فنية أو قانونية',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.red[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   bool _isStepCompleted(ReportStatus status) {
//     final statusOrder = [
//       ReportStatus.received,
//       ReportStatus.underReview,
//       ReportStatus.dataVerification,
//       ReportStatus.actionTaken,
//       ReportStatus.completed,
//     ];

//     final currentIndex = statusOrder.indexOf(currentStatus);
//     final stepIndex = statusOrder.indexOf(status);

//     if (currentStatus == ReportStatus.completed) {
//       return true; // All steps completed
//     }

//     if (currentStatus == ReportStatus.rejected) {
//       return stepIndex == 0; // Only first step completed if rejected
//     }

//     return stepIndex <= currentIndex;
//   }

//   Widget _buildStatusStep({
//     required String title,
//     required String description,
//     required IconData icon,
//     required Color color,
//     required ReportStatus status,
//     required bool isCompleted,
//     required bool isActive,
//     bool isLast = false,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Status Icon
//           Container(
//             width: 44.w,
//             height: 44.w,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color:
//                   isCompleted || isActive
//                       ? _getStatusColor(status)
//                       : Colors.grey.withOpacity(0.3),
//               boxShadow:
//                   isCompleted || isActive
//                       ? [
//                         BoxShadow(
//                           color: _getStatusColor(status).withOpacity(0.3),
//                           spreadRadius: 0,
//                           blurRadius: 6,
//                           offset: const Offset(0, 2),
//                         ),
//                       ]
//                       : null,
//             ),
//             child: Icon(
//               isCompleted ? Icons.check : icon,
//               color: isCompleted || isActive ? Colors.white : Colors.grey[600],
//               size: 20.sp,
//             ),
//           ),
//           SizedBox(width: 16.w),

//           // Status Content
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color:
//                     isActive
//                         ? _getStatusColor(status).withOpacity(0.05)
//                         : isCompleted
//                         ? Colors.green.withOpacity(0.05)
//                         : Colors.grey.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(
//                   color:
//                       isActive
//                           ? _getStatusColor(status).withOpacity(0.3)
//                           : isCompleted
//                           ? Colors.green.withOpacity(0.3)
//                           : Colors.grey.withOpacity(0.3),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: 15.sp,
//                             fontWeight: FontWeight.bold,
//                             color:
//                                 isCompleted || isActive
//                                     ? Colors.black87
//                                     : Colors.grey[600],
//                           ),
//                         ),
//                       ),
//                       if (isActive)
//                         Container(
//                           width: 8.w,
//                           height: 8.w,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _getStatusColor(status),
//                           ),
//                         ),
//                     ],
//                   ),
//                   SizedBox(height: 6.h),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       color:
//                           isCompleted || isActive
//                               ? Colors.black54
//                               : Colors.grey[500],
//                       height: 1.4,
//                     ),
//                   ),
//                   if (isActive && createdAt != null) ...[
//                     SizedBox(height: 8.h),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 4.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _getStatusColor(status).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: Text(
//                         'الوقت: ${_formatDateTime(createdAt!)}',
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           color: _getStatusColor(status),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildConnectorLine(bool isCompleted) {
//     return Container(
//       margin: EdgeInsets.only(right: 22.w, top: 4.h, bottom: 4.h),
//       width: 3.w,
//       height: 20.h,
//       decoration: BoxDecoration(
//         color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(2.r),
//       ),
//     );
//   }

//   Color _getStatusColor(ReportStatus status) {
//     switch (status) {
//       case ReportStatus.received:
//         return AppColors.primaryColor;
//       case ReportStatus.underReview:
//         return Colors.orange;
//       case ReportStatus.dataVerification:
//         return Colors.blue;
//       case ReportStatus.actionTaken:
//         return Colors.purple;
//       case ReportStatus.completed:
//         return Colors.green;
//       case ReportStatus.rejected:
//         return Colors.red;
//     }
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(dateTime);
//   }
// }
