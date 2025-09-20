// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:netru_app/core/utils/user_data_helper.dart';
// import 'package:netru_app/core/theme/app_colors.dart';
// import 'package:netru_app/features/profile/presentation/page/edit_profile_page.dart';
// import 'package:netru_app/features/profile/presentation/page/settings_page.dart';

// class EnhancedProfilePage extends StatefulWidget {
//   const EnhancedProfilePage({super.key});

//   @override
//   State<EnhancedProfilePage> createState() => _EnhancedProfilePageState();
// }

// class _EnhancedProfilePageState extends State<EnhancedProfilePage> {
//   @override
//   Widget build(BuildContext context) {
//     final userHelper = UserDataHelper();
//     final user = userHelper.getCurrentUser();
//     final userName = userHelper.getUserFullName();
//     final userLocation = user?.location ?? 'غير محدد';

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           'الملف الشخصي',
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SettingsPage()),
//               );
//             },
//             icon: const Icon(Icons.settings, color: AppColors.primaryColor),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Profile Header Section
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(20.w),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Profile Image
//                   Stack(
//                     alignment: Alignment.bottomRight,
//                     children: [
//                       CircleAvatar(
//                         radius: 50.r,
//                         backgroundColor: Colors.grey[200],
//                         child:
//                             userHelper.getUserProfileImage() != null
//                                 ? ClipOval(
//                                   child: Image.network(
//                                     userHelper.getUserProfileImage()!,
//                                     width: 100.r,
//                                     height: 100.r,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Icon(
//                                         Icons.person,
//                                         size: 50.r,
//                                         color: Colors.grey[600],
//                                       );
//                                     },
//                                     loadingBuilder: (
//                                       context,
//                                       child,
//                                       loadingProgress,
//                                     ) {
//                                       if (loadingProgress == null) return child;
//                                       return const Center(
//                                         child: CircularProgressIndicator(),
//                                       );
//                                     },
//                                   ),
//                                 )
//                                 : Icon(
//                                   Icons.person,
//                                   size: 50.r,
//                                   color: Colors.grey[600],
//                                 ),
//                       ),
//                       Container(
//                         padding: EdgeInsets.all(6.w),
//                         decoration: const BoxDecoration(
//                           color: AppColors.primaryColor,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.camera_alt,
//                           color: Colors.white,
//                           size: 16.sp,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 15.h),
//                   // User Name
//                   Text(
//                     userName,
//                     style: TextStyle(
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   // User Location
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         color: Colors.grey[600],
//                         size: 16.sp,
//                       ),
//                       SizedBox(width: 4.w),
//                       Text(
//                         userLocation,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 15.h),
//                   // Edit Profile Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         final result = await Navigator.push<bool>(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const EditProfilePage(),
//                           ),
//                         );

//                         // Refresh the page if profile was updated
//                         if (result == true && mounted) {
//                           setState(() {
//                             // This will trigger a rebuild with updated data
//                           });
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor,
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 12.h),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.r),
//                         ),
//                       ),
//                       child: Text(
//                         'تعديل الملف الشخصي',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // Profile Statistics Section
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: 16.w),
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildStatItem('البلاغات', '12', Icons.report),
//                   _buildStatItem('القضايا', '3', Icons.gavel),
//                   _buildStatItem('النقاط', '250', Icons.star),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // Personal Information Section
//             _buildInfoSection('المعلومات الشخصية', [
//               _buildInfoItem(
//                 Icons.email,
//                 'البريد الإلكتروني',
//                 user?.email ?? 'غير محدد',
//               ),
//               _buildInfoItem(
//                 Icons.phone,
//                 'رقم الهاتف',
//                 user?.phone ?? 'غير محدد',
//               ),
//               _buildInfoItem(
//                 Icons.credit_card,
//                 'الرقم القومي',
//                 user?.nationalId ?? 'غير محدد',
//               ),
//               _buildInfoItem(
//                 Icons.book,
//                 'رقم الجواز',
//                 user?.passportNumber ?? 'غير محدد',
//               ),
//             ]),
//             SizedBox(height: 20.h),

//             // Account Security Section
//             _buildInfoSection('أمان الحساب', [
//               _buildInfoItem(
//                 Icons.lock,
//                 'كلمة المرور',
//                 '••••••••',
//                 onTap: () {},
//               ),
//               _buildInfoItem(
//                 Icons.security,
//                 'المصادقة الثنائية',
//                 'مفعلة',
//                 onTap: () {},
//               ),
//               _buildInfoItem(
//                 Icons.history,
//                 'تاريخ إنشاء الحساب',
//                 _formatDate(user?.createdAt),
//               ),
//             ]),
//             SizedBox(height: 30.h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String title, String value, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: EdgeInsets.all(12.w),
//           decoration: BoxDecoration(
//             color: AppColors.primaryColor.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(8.r),
//           ),
//           child: Icon(icon, color: AppColors.primaryColor, size: 24.sp),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
//       ],
//     );
//   }

//   Widget _buildInfoSection(String title, List<Widget> items) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//           ...items,
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoItem(
//     IconData icon,
//     String title,
//     String value, {
//     VoidCallback? onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(8.w),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryColor.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//               child: Icon(icon, color: AppColors.primaryColor, size: 18.sp),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (onTap != null)
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey[400],
//                 size: 16.sp,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return 'غير محدد';
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
