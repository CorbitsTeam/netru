import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../../domain/entities/user_profile_detail_entity.dart';
import '../../domain/usecases/manage_users.dart';
import '../cubit/admin_reports_cubit.dart';
import '../widgets/comprehensive_admin_actions.dart';

class AdminReportDetailsPage extends StatefulWidget {
  final AdminReportEntity report;

  const AdminReportDetailsPage({super.key, required this.report});

  @override
  State<AdminReportDetailsPage> createState() => _AdminReportDetailsPageState();
}

class _AdminReportDetailsPageState extends State<AdminReportDetailsPage> {
  UserProfileDetailEntity? userProfile;
  bool isLoadingUserProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (widget.report.userId == null) return;

    setState(() {
      isLoadingUserProfile = true;
    });

    try {
      final result = await di.sl<GetUserDetailedProfile>().call(
        GetUserDetailedProfileParams(userId: widget.report.userId!),
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'فشل في تحميل بيانات المستخدم: ${failure.toString()}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (profile) {
          if (mounted) {
            setState(() {
              userProfile = profile;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل بيانات المستخدم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingUserProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminReportsCubit>(
      create: (_) => di.sl<AdminReportsCubit>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionMenu(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            'تفاصيل البلاغ',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            '#${widget.report.id.substring(0, 8)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _getStatusColor(widget.report.reportStatus).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            widget.report.reportStatus.arabicName,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(widget.report.reportStatus),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[50]!, Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header Card
              _buildReportHeaderCard(),
              SizedBox(height: 20.h),

              // Reporter Information Card
              _buildReporterInfoCard(),
              SizedBox(height: 20.h),

              // User Profile Detail (if available)
              if (isLoadingUserProfile) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                SizedBox(height: 20.h),
              ] else if (userProfile != null) ...[
                _buildUserProfileDetailCard(),
                SizedBox(height: 20.h),
              ],

              // Report Details Card
              _buildReportDetailsCard(),
              SizedBox(height: 20.h),

              // Location Information Card
              if (widget.report.incidentLocationLatitude != null &&
                  widget.report.incidentLocationLongitude != null) ...[
                _buildLocationCard(),
                SizedBox(height: 20.h),
              ],

              // Media Card
              if (widget.report.media.isNotEmpty) ...[
                _buildMediaCard(),
                SizedBox(height: 20.h),
              ],

              // Admin Notes Card
              _buildAdminNotesCard(),
              SizedBox(height: 20.h),

              // Status History Card
              if (widget.report.statusHistory.isNotEmpty) ...[
                _buildStatusHistoryCard(),
                SizedBox(height: 20.h),
              ],

              // Comments Card
              if (widget.report.comments.isNotEmpty) ...[
                _buildCommentsCard(),
                SizedBox(height: 20.h),
              ],

              // Admin Actions
              ComprehensiveAdminActions(report: widget.report),

              SizedBox(height: 100.h), // Space for floating button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(Icons.assignment, color: Colors.white, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم البلاغ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '#${widget.report.id.substring(0, 8)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(widget.report.priorityLevel),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      widget.report.priorityLevel.arabicName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (widget.report.caseNumber != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'رقم القضية: ${widget.report.caseNumber}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوع البلاغ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.report.reportTypeName ?? 'غير محدد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.9),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'تم الإبلاغ: ${DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(widget.report.submittedAt)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (widget.report.incidentDateTime != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: Colors.white.withOpacity(0.9),
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'وقت الحادثة: ${DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(widget.report.incidentDateTime!)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReporterInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'بيانات مقدم البلاغ',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (widget.report.isAnonymous)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'مجهول',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            'الاسم الكامل',
            '${widget.report.reporterFirstName} ${widget.report.reporterLastName}',
            Icons.person_outline,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'رقم الهوية الوطنية',
            widget.report.reporterNationalId,
            Icons.credit_card,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('رقم الهاتف', widget.report.reporterPhone, Icons.phone),
          if (widget.report.assignedTo != null) ...[
            SizedBox(height: 16.h),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 16.h),
            _buildInfoRow(
              'مُحال إلى',
              widget.report.assignedToName ?? 'غير محدد',
              Icons.assignment_ind,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserProfileDetailCard() {
    if (userProfile == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.blue,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'الملف الشخصي الكامل',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getVerificationStatusColor(
                    userProfile!.verificationStatus,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _getVerificationStatusText(userProfile!.verificationStatus),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Profile Image
          if (userProfile!.profileImage != null) ...[
            Center(
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(userProfile!.profileImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // Personal Information
          _buildInfoRow('البريد الإلكتروني', userProfile!.email, Icons.email),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'الجنسية',
            userProfile!.nationality ?? 'غير محدد',
            Icons.flag,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'المحافظة',
            userProfile!.governorate ?? 'غير محدد',
            Icons.location_city,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'المدينة',
            userProfile!.city ?? 'غير محدد',
            Icons.location_on,
          ),

          if (userProfile!.address != null) ...[
            SizedBox(height: 16.h),
            _buildInfoRow('العنوان الكامل', userProfile!.address!, Icons.home),
          ],

          // Statistics
          SizedBox(height: 20.h),
          Divider(color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'إحصائيات البلاغات',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatCard(
                'إجمالي البلاغات',
                userProfile!.totalReportsCount.toString(),
                Colors.blue,
              ),
              SizedBox(width: 12.w),
              _buildStatCard(
                'معلقة',
                userProfile!.pendingReportsCount.toString(),
                Colors.orange,
              ),
              SizedBox(width: 12.w),
              _buildStatCard(
                'محلولة',
                userProfile!.resolvedReportsCount.toString(),
                Colors.green,
              ),
            ],
          ),

          // Identity Documents
          if (userProfile!.identityDocuments.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              'المستندات الثبوتية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            ...userProfile!.identityDocuments.map(
              (doc) => _buildDocumentCard(doc),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentCard(dynamic doc) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.badge, color: AppColors.primaryColor, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوع المستند: ${_documentTypeArabic(doc.docType)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (doc.uploadedAt != null)
                  Text(
                    'تاريخ الرفع: ${DateFormat('dd/MM/yyyy').format(doc.uploadedAt)}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          if (doc.frontImageUrl != null)
            IconButton(
              onPressed: () => _viewDocument(doc.frontImageUrl!),
              icon: Icon(Icons.visibility, color: AppColors.primaryColor),
              iconSize: 20.sp,
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
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
              style: TextStyle(
                fontSize: 10.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.description,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'تفاصيل البلاغ',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              widget.report.reportDetails,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.update, color: Colors.grey[600], size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                'آخر تحديث: ${DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(widget.report.updatedAt)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'موقع الحادثة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _openInGoogleMaps,
                icon: Icon(Icons.open_in_new, color: Colors.blue, size: 20.sp),
                tooltip: 'فتح في خرائط جوجل',
              ),
            ],
          ),
          SizedBox(height: 20.h),

          if (widget.report.incidentLocationAddress != null) ...[
            _buildInfoRow(
              'العنوان',
              widget.report.incidentLocationAddress!,
              Icons.place,
            ),
            SizedBox(height: 16.h),
          ],

          _buildInfoRow(
            'خط العرض',
            widget.report.incidentLocationLatitude!.toStringAsFixed(6),
            Icons.straighten,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'خط الطول',
            widget.report.incidentLocationLongitude!.toStringAsFixed(6),
            Icons.straighten,
          ),

          SizedBox(height: 20.h),

          // Location Display Card
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[100],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 48.sp, color: Colors.green),
                  SizedBox(height: 12.h),
                  Text(
                    'موقع الحادثة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${widget.report.incidentLocationLatitude!.toStringAsFixed(6)}, ${widget.report.incidentLocationLongitude!.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: _openInGoogleMaps,
                    icon: Icon(Icons.open_in_new, size: 16.sp),
                    label: const Text('فتح في خرائط جوجل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.perm_media,
                  color: Colors.purple,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'الملفات المرفقة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${widget.report.media.length} ملف',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.2,
            ),
            itemCount: widget.report.media.length,
            itemBuilder: (context, index) {
              final media = widget.report.media[index];
              return _buildMediaItem(media);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(ReportMediaEntity media) {
    return GestureDetector(
      onTap: () => _viewMedia(media),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: _buildMediaPreview(media),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.fileName ?? 'ملف مرفق',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (media.description != null)
                    Text(
                      media.description!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(ReportMediaEntity media) {
    if (media.fileUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
          ),
        ),
        child: Center(
          child: Icon(Icons.broken_image, size: 40.sp, color: Colors.grey[600]),
        ),
      );
    }

    switch (media.mediaType) {
      case MediaType.image:
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
          ),
          child: Image.network(
            media.fileUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
              );
            },
            errorBuilder:
                (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Icon(
                    Icons.broken_image,
                    size: 40.sp,
                    color: Colors.grey[600],
                  ),
                ),
          ),
        );
      case MediaType.video:
        return Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_filled,
              size: 40.sp,
              color: Colors.white,
            ),
          ),
        );
      case MediaType.document:
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: Center(
            child: Icon(Icons.description, size: 40.sp, color: Colors.blue),
          ),
        );
      default:
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.file_present,
              size: 40.sp,
              color: Colors.grey[600],
            ),
          ),
        );
    }
  }

  Widget _buildAdminNotesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.orange,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'ملاحظات الإدارة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          if (widget.report.adminNotes != null) ...[
            Text(
              'ملاحظات داخلية:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Text(
                widget.report.adminNotes!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ] else ...[
            Text(
              'لا توجد ملاحظات داخلية',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          if (widget.report.publicNotes != null) ...[
            Text(
              'ملاحظات عامة:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Text(
                widget.report.publicNotes!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ] else ...[
            Text(
              'لا توجد ملاحظات عامة',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHistoryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.history, color: Colors.indigo, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'سجل الحالات',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.report.statusHistory.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final history = widget.report.statusHistory[index];
              return _buildStatusHistoryItem(history);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHistoryItem(ReportStatusHistoryEntity history) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: _getStatusColor(history.newStatus),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.timeline, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.newStatus.arabicName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(history.newStatus),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'بواسطة: ${history.changedByName ?? 'النظام'}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                Text(
                  DateFormat(
                    'dd/MM/yyyy - HH:mm',
                    'ar',
                  ).format(history.changedAt),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                ),
                if (history.notes != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    history.notes!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.comment, color: Colors.teal, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'التعليقات',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${widget.report.comments.length} تعليق',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.report.comments.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final comment = widget.report.comments[index];
              return _buildCommentItem(comment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(ReportCommentEntity comment) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color:
            comment.isInternal
                ? Colors.orange.withOpacity(0.05)
                : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              comment.isInternal
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: comment.isInternal ? Colors.orange : Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  comment.isInternal ? Icons.lock : Icons.public,
                  color: Colors.white,
                  size: 12.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                comment.userName,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: comment.isInternal ? Colors.orange : Colors.blue,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat(
                  'dd/MM/yyyy - HH:mm',
                  'ar',
                ).format(comment.createdAt),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            comment.commentText,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primaryColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionMenu() {
    return FloatingActionButton.extended(
      onPressed: () => _showActionMenu(),
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      icon: Icon(Icons.more_horiz, size: 20.sp),
      label: Text(
        'الإجراءات',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      elevation: 6,
    );
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإجراءات المتاحة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildActionItem(
                        icon: Icons.share,
                        title: 'مشاركة البلاغ',
                        subtitle: 'مشاركة تفاصيل البلاغ مع الآخرين',
                        onTap: () => _shareReport(),
                      ),
                      Divider(height: 1.h, color: Colors.grey[200]),
                      _buildActionItem(
                        icon: Icons.picture_as_pdf,
                        title: 'تحميل كـ PDF',
                        subtitle: 'تنزيل ملف PDF بتفاصيل البلاغ',
                        onTap: () => _downloadPDF(),
                      ),
                      Divider(height: 1.h, color: Colors.grey[200]),
                      _buildActionItem(
                        icon: Icons.refresh,
                        title: 'تحديث البيانات',
                        subtitle: 'إعادة تحميل بيانات البلاغ',
                        onTap: () => _refreshData(),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 22.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  // Helper methods
  Color _getStatusColor(AdminReportStatus status) {
    switch (status) {
      case AdminReportStatus.received:
        return Colors.blue;
      case AdminReportStatus.pending:
        return Colors.orange;
      case AdminReportStatus.underInvestigation:
        return Colors.purple;
      case AdminReportStatus.resolved:
        return Colors.green;
      case AdminReportStatus.closed:
        return Colors.grey;
      case AdminReportStatus.rejected:
        return Colors.red;
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return Colors.green;
      case PriorityLevel.medium:
        return Colors.orange;
      case PriorityLevel.high:
        return Colors.red;
      case PriorityLevel.urgent:
        return Colors.deepPurple;
    }
  }

  Color _getVerificationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Safe helper to get Arabic name for document type. Accepts DocumentType enum or String.
  String _documentTypeArabic(dynamic docType) {
    try {
      if (docType == null) return 'غير محدد';
      // If it's the enum from admin domain
      if (docType is Object && docType.toString().contains('DocumentType')) {
        // Try to call extension getter
        try {
          return (docType as dynamic).arabicName as String;
        } catch (_) {
          // fallback to parsing name
          final name = docType.toString().split('.').last;
          switch (name) {
            case 'nationalId':
            case 'DocumentType.nationalId':
              return 'البطاقة الشخصية';
            case 'passport':
            case 'DocumentType.passport':
              return 'جواز السفر';
            default:
              return 'غير محدد';
          }
        }
      }

      // If it's a string value like 'nationalId' or 'passport'
      if (docType is String) {
        switch (docType) {
          case 'nationalId':
            return 'البطاقة الشخصية';
          case 'passport':
            return 'جواز السفر';
          default:
            return 'غير محدد';
        }
      }

      return 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
  }

  String _getVerificationStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'موثق';
      case 'pending':
        return 'قيد المراجعة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير موثق';
    }
  }

  // Action methods
  void _openInGoogleMaps() async {
    if (widget.report.incidentLocationLatitude == null ||
        widget.report.incidentLocationLongitude == null) {
      return;
    }

    final lat = widget.report.incidentLocationLatitude!;
    final lng = widget.report.incidentLocationLongitude!;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح خرائط جوجل'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في فتح الخرائط: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewDocument(String documentUrl) {
    // Open document viewer
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              height: 400.h,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('عرض المستند'),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Image.network(
                      documentUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Center(child: Text('لا يمكن عرض المستند')),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _viewMedia(ReportMediaEntity media) {
    // Open media viewer based on type
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              height: 400.h,
              child: Column(
                children: [
                  AppBar(
                    title: Text(media.fileName ?? 'عرض الملف'),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(child: _buildFullMediaPreview(media)),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildFullMediaPreview(ReportMediaEntity media) {
    switch (media.mediaType) {
      case MediaType.image:
        return Image.network(
          media.fileUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
          errorBuilder:
              (context, error, stackTrace) =>
                  const Center(child: Text('لا يمكن عرض الصورة')),
        );
      case MediaType.video:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_filled, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text('اضغط لتشغيل الفيديو'),
            ],
          ),
        );
      default:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.file_present, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('معاينة الملف غير متاحة'),
            ],
          ),
        );
    }
  }

  void _shareReport() async {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة المشاركة قيد التطوير'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _downloadPDF() async {
    // TODO: Implement PDF download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة تحميل PDF قيد التطوير'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _refreshData() async {
    // Refresh all data
    await _loadUserProfile();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث البيانات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
