import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/user_profile_detail_entity.dart';
import '../cubit/admin_users_cubit.dart';
import '../widgets/user_avatar_widget.dart';
import '../widgets/identity_documents_widget.dart';

class UserDetailsPage extends StatefulWidget {
  final AdminUserEntity user;

  const UserDetailsPage({super.key, required this.user});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late AdminUsersCubit _adminUsersCubit;

  @override
  void initState() {
    super.initState();
    _adminUsersCubit = GetIt.instance<AdminUsersCubit>();
    _loadUserDetailedProfile();
  }

  void _loadUserDetailedProfile() {
    _adminUsersCubit.loadUserDetailedProfile(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminUsersCubit>(
      create: (context) => _adminUsersCubit,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'تفاصيل المواطن',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handleUserAction(value),
              itemBuilder:
                  (context) => [
                    // Show verify option only for non-verified users
                    if (widget.user.verificationStatus !=
                        VerificationStatus.verified)
                      const PopupMenuItem(
                        value: 'verify',
                        child: Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green),
                            SizedBox(width: 8),
                            Text('توثيق المواطن'),
                          ],
                        ),
                      ),
                    // Show suspend option for verified users
                    if (widget.user.verificationStatus ==
                        VerificationStatus.verified)
                      const PopupMenuItem(
                        value: 'suspend',
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red),
                            SizedBox(width: 8),
                            Text('إيقاف الحساب'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('تعديل البيانات'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        body: BlocListener<AdminUsersCubit, AdminUsersState>(
          listener: (context, state) {
            if (state is AdminUsersVerified) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم توثيق المستخدم بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
              // Reload detailed profile to get updated data
              _loadUserDetailedProfile();
            } else if (state is AdminUsersSuspended) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إيقاف المستخدم بنجاح'),
                  backgroundColor: Colors.orange,
                ),
              );
              // Reload detailed profile to get updated data
              _loadUserDetailedProfile();
            } else if (state is AdminUsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _loadUserDetailedProfile();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(),
                  SizedBox(height: 20.h),
                  _buildPersonalInfoSection(),
                  SizedBox(height: 16.h),
                  _buildContactInfoSection(),
                  SizedBox(height: 16.h),
                  _buildLocationInfoSection(),
                  SizedBox(height: 16.h),
                  _buildAccountInfoSection(),
                  SizedBox(height: 16.h),
                  _buildVerificationSection(),
                  SizedBox(height: 16.h),
                  _buildIdentityDocumentsSection(),
                  SizedBox(height: 16.h),
                  _buildReportsSection(),
                  SizedBox(height: 16.h),
                 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            UserAvatarWidget(
              imageUrl: widget.user.profileImage,
              userName: widget.user.fullName,
              radius: 40,
              backgroundColor: _getUserTypeColor(
                widget.user.userType,
              ).withOpacity(0.1),
              textColor: _getUserTypeColor(widget.user.userType),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.fullName,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.user.email,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildStatusChip(
                        _getUserTypeText(widget.user.userType),
                        _getUserTypeColor(widget.user.userType),
                      ),
                      SizedBox(width: 8.w),
                      _buildStatusChip(
                        _getVerificationStatusText(
                          widget.user.verificationStatus,
                        ),
                        _getVerificationStatusColor(
                          widget.user.verificationStatus,
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

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'المعلومات الشخصية',
      icon: Icons.person,
      children: [
        if (widget.user.nationalId?.isNotEmpty == true)
          _buildInfoRow('الرقم القومي', widget.user.nationalId!, Icons.badge),
        if (widget.user.passportNumber?.isNotEmpty == true)
          _buildInfoRow(
            'رقم جواز السفر',
            widget.user.passportNumber!,
            Icons.flight,
          ),
        if (widget.user.nationality?.isNotEmpty == true)
          _buildInfoRow('الجنسية', widget.user.nationality!, Icons.flag),
        _buildInfoRow(
          'نوع المستخدم',
          _getUserTypeText(widget.user.userType),
          Icons.category,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'معلومات الاتصال',
      icon: Icons.contact_phone,
      children: [
        _buildInfoRow('البريد الإلكتروني', widget.user.email, Icons.email),
        if (widget.user.phone?.isNotEmpty == true)
          _buildInfoRow('رقم الهاتف', widget.user.phone!, Icons.phone),
      ],
    );
  }

  Widget _buildLocationInfoSection() {
    return _buildSection(
      title: 'معلومات العنوان',
      icon: Icons.location_on,
      children: [
        if (widget.user.governorate?.isNotEmpty == true)
          _buildInfoRow(
            'المحافظة',
            widget.user.governorate!,
            Icons.location_city,
          ),
        if (widget.user.city?.isNotEmpty == true)
          _buildInfoRow('المدينة', widget.user.city!, Icons.location_city),
        if (widget.user.district?.isNotEmpty == true)
          _buildInfoRow('المنطقة', widget.user.district!, Icons.place),
        if (widget.user.address?.isNotEmpty == true)
          _buildInfoRow('العنوان التفصيلي', widget.user.address!, Icons.home),
      ],
    );
  }

  Widget _buildAccountInfoSection() {
    return _buildSection(
      title: 'معلومات الحساب',
      icon: Icons.account_circle,
      children: [
        _buildInfoRow(
          'تاريخ التسجيل',
          _formatDateTime(widget.user.createdAt),
          Icons.date_range,
        ),
        _buildInfoRow(
          'آخر تحديث',
          _formatDateTime(widget.user.updatedAt),
          Icons.update,
        ),
        // if (widget.user.lastLoginAt != null)
        //   _buildInfoRow(
        //     'آخر تسجيل دخول',
        //     _formatDateTime(widget.user.lastLoginAt!),
        //     Icons.login,
        //   ),
        if (widget.user.role != null)
          _buildInfoRow(
            'الدور',
            _getAdminRoleText(widget.user.role!),
            Icons.admin_panel_settings,
          ),
      ],
    );
  }

  Widget _buildVerificationSection() {
    return _buildSection(
      title: 'حالة التوثيق',
      icon: Icons.verified_user,
      children: [
        _buildInfoRow(
          'حالة التوثيق',
          _getVerificationStatusText(widget.user.verificationStatus),
          Icons.verified,
          valueColor: _getVerificationStatusColor(
            widget.user.verificationStatus,
          ),
        ),
        if (widget.user.verifiedAt != null)
          _buildInfoRow(
            'تاريخ التوثيق',
            _formatDateTime(widget.user.verifiedAt!),
            Icons.check_circle,
          ),
      ],
    );
  }

  Widget _buildIdentityDocumentsSection() {
    return _buildSection(
      title: 'وثائق الهوية',
      icon: Icons.badge,
      children: [
        BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersDetailedProfileLoaded) {
              return IdentityDocumentsWidget(
                documents: state.userDetail.identityDocuments,
                nationality: state.userDetail.nationality,
                userNationalId: state.userDetail.nationalId,
                onImageTap: _showImageDialog,
              );
            } else if (state is AdminUsersLoadingDetailedProfile) {
              return const Center(child: CircularProgressIndicator());
            } else {
              // عرض بيانات أساسية من AdminUserEntity
              return IdentityDocumentsWidget(
                documents: const [],
                nationality: widget.user.nationality,
                userNationalId: widget.user.nationalId,
                onImageTap: _showImageDialog,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildReportsSection() {
    return _buildSection(
      title: 'البلاغات المقدمة',
      icon: Icons.report,
      children: [
        BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersDetailedProfileLoaded) {
              return _buildReportsContent(state.userDetail);
            } else {
              return _buildBasicReportsContent();
            }
          },
        ),
      ],
    );
  }

  Widget _buildReportsContent(UserProfileDetailEntity userDetail) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildReportStatCard(
                'إجمالي البلاغات',
                userDetail.totalReportsCount.toString(),
                Icons.report,
                Colors.blue,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildReportStatCard(
                'قيد المراجعة',
                userDetail.pendingReportsCount.toString(),
                Icons.hourglass_empty,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildReportStatCard(
                'تم الحل',
                userDetail.resolvedReportsCount.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildReportStatCard(
                'مرفوضة',
                (userDetail.totalReportsCount -
                        userDetail.pendingReportsCount -
                        userDetail.resolvedReportsCount)
                    .toString(),
                Icons.cancel,
                Colors.red,
              ),
            ),
          ],
        ),
        // if (userDetail.reports.isNotEmpty) ...[
        //   SizedBox(height: 16.h),
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         'آخر البلاغات',
        //         style: TextStyle(
        //           fontSize: 14.sp,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.grey[700],
        //         ),
        //       ),
        //       // if (userDetail.totalReportsCount > 3)
        //       //   TextButton(
        //       //     onPressed: () => _showAllReports(userDetail.reports),
        //       //     child: const Text('عرض الكل'),
        //       //   ),
        //     ],
        //   ),
        //   SizedBox(height: 8.h),
        //   ...userDetail.reports
        //       .take(3)
        //       .map(
        //         (report) => Container(
        //           margin: EdgeInsets.only(bottom: 8.h),
        //           padding: EdgeInsets.all(12.w),
        //           decoration: BoxDecoration(
        //             color: Colors.grey[50],
        //             borderRadius: BorderRadius.circular(8.r),
        //             border: Border.all(color: Colors.grey.withOpacity(0.2)),
        //           ),
        //           child: Row(
        //             children: [
        //               Icon(
        //                 Icons.report_problem,
        //                 size: 16.sp,
        //                 color: _getReportStatusColor(report.status),
        //               ),
        //               SizedBox(width: 8.w),
        //               Expanded(
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     Text(
        //                       report.title,
        //                       style: TextStyle(
        //                         fontSize: 12.sp,
        //                         fontWeight: FontWeight.w500,
        //                       ),
        //                       maxLines: 1,
        //                       overflow: TextOverflow.ellipsis,
        //                     ),
        //                     Text(
        //                       _formatDate(report.createdAt),
        //                       style: TextStyle(
        //                         fontSize: 10.sp,
        //                         color: Colors.grey[600],
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //               Container(
        //                 padding: EdgeInsets.symmetric(
        //                   horizontal: 6.w,
        //                   vertical: 2.h,
        //                 ),
        //                 decoration: BoxDecoration(
        //                   color: _getReportStatusColor(
        //                     report.status,
        //                   ).withOpacity(0.1),
        //                   borderRadius: BorderRadius.circular(4.r),
        //                 ),
        //                 child: Text(
        //                   _getReportStatusText(report.status),
        //                   style: TextStyle(
        //                     fontSize: 9.sp,
        //                     color: _getReportStatusColor(report.status),
        //                     fontWeight: FontWeight.w500,
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       )
        //       .toList(),
        // ],
      ],
    );
  }

  Widget _buildBasicReportsContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildReportStatCard(
                'إجمالي البلاغات',
                widget.user.reportCount.toString(),
                Icons.report,
                Colors.blue,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildReportStatCard(
                'قيد المراجعة',
                '0',
                Icons.hourglass_empty,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildReportStatCard(
                'تم الحل',
                '0',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildReportStatCard(
                'مرفوضة',
                '0',
                Icons.cancel,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getReportStatusColor(dynamic status) {
    return Colors.blue; // Default color
  }

  String _getReportStatusText(dynamic status) {
    return 'قيد المراجعة'; // Default text
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }



  Widget _buildReportStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return _buildSection(
      title: 'النشاط',
      icon: Icons.analytics,
      children: [
        _buildInfoRow(
          'عدد التقارير',
          widget.user.reportCount.toString(),
          Icons.report,
        ),
        if (widget.user.permissions.isNotEmpty) _buildPermissionsRow(),
      ],
    );
  }

  Widget _buildPermissionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.security, size: 20.sp, color: Colors.grey[600]),
            SizedBox(width: 8.w),
            Text(
              'الصلاحيات:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children:
              widget.user.permissions
                  .map(
                    (permission) => Chip(
                      label: Text(
                        permission,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  String _getUserTypeText(AdminUserType userType) {
    return userType.arabicName;
  }

  Color _getUserTypeColor(AdminUserType userType) {
    switch (userType) {
      case AdminUserType.citizen:
        return Colors.blue;
      case AdminUserType.foreigner:
        return Colors.green;
      case AdminUserType.admin:
        return Colors.purple;
    }
  }

  String _getVerificationStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 'موثق';
      case VerificationStatus.pending:
        return 'قيد المراجعة';
      case VerificationStatus.rejected:
        return 'مرفوض';
      case VerificationStatus.unverified:
        return 'غير موثق';
    }
  }

  Color _getVerificationStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.unverified:
        return Colors.grey;
    }
  }

  String _getAdminRoleText(AdminRole role) {
    return role.arabicName;
  }

  String _formatDateTime(DateTime dateTime) {
    // بتخلي التاريخ بالشكل: 22/09/2025 14:05
    final DateFormat formatter = DateFormat('dd/MM/yyyy - HH:mm a');
    return formatter.format(dateTime);
  }

  void _handleUserAction(String action) {
    switch (action) {
      case 'verify':
        _showVerificationDialog();
        break;
      case 'suspend':
        _showSuspensionDialog();
        break;
      case 'edit':
        _showEditDialog();
        break;
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('توثيق المستخدم'),
            content: const Text('هل تريد توثيق هذا المستخدم؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _adminUsersCubit.verifyUserById(
                    widget.user.id,
                    VerificationStatus.verified,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'توثيق',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showSuspensionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إيقاف المستخدم'),
            content: const Text('هل تريد إيقاف هذا المستخدم؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _adminUsersCubit.suspendUserById(
                    widget.user.id,
                    true,
                    reason: 'تم الإيقاف بواسطة المدير',
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'إيقاف',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة التعديل قيد التطوير'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showImageDialog(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(dialogContext).pop(),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // عنوان الصورة
                  Container(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // الصورة
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(20.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 48.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'خطأ في تحميل الصورة',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // زر الإغلاق
                  Container(
                    padding: EdgeInsets.all(16.w),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'إغلاق',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
