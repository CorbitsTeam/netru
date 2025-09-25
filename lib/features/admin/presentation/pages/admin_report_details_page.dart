import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../../domain/entities/user_profile_detail_entity.dart';
import '../../domain/usecases/manage_users.dart';
import '../cubit/admin_reports_cubit.dart';
import '../../../reports/presentation/services/professional_egyptian_pdf_service.dart';
import '../../../reports/domain/entities/reports_entity.dart';
import '../../../reports/presentation/widgets/enhanced_status_tracker.dart';
import '../../../reports/presentation/widgets/report_media_viewer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            '#${widget.report.id.substring(0, 8)}',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 12.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _getStatusColor(widget.report.reportStatus).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            widget.report.reportStatus.arabicName,
            style: TextStyle(
              fontSize: 11.sp,
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
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header Card
              _buildReportHeaderCard(),
              SizedBox(height: 10.h),

              // Reporter Information Card
              _buildReporterInfoCard(),
              SizedBox(height: 10.h),

              // User Profile Loading Indicator
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
                SizedBox(height: 16.h),
              ],

              // Report Details Card
              _buildReportDetailsCard(),
              SizedBox(height: 10.h),

              // Enhanced Status Tracker
              _buildAdminStatusTracker(),
              SizedBox(height: 10.h),

              // Status Progression Buttons
              _buildStatusProgressionButtons(),
              SizedBox(height: 10.h),

              // Location Information Card
              if (widget.report.incidentLocationLatitude != null &&
                  widget.report.incidentLocationLongitude != null) ...[
                _buildLocationCard(),
                SizedBox(height: 10.h),
              ],

              // Media Cards - عرض الوسائط المرفقة
              if (widget.report.media.isNotEmpty) ...[
                // استخدام ReportMediaViewer لكل وسائط
                ...widget.report.media.map(
                  (media) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: ReportMediaViewer(
                      mediaUrl: _resolveMediaUrl(media.fileUrl),
                      mediaType: media.mimeType ?? media.mediaType.name,
                    ),
                  ),
                ),
              ] else ...[
                // عرض رسالة عندما لا توجد وسائط
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 32.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'لا توجد وسائط مرفقة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],

              // Admin Notes Card
              _buildAdminNotesCard(),
              SizedBox(height: 10.h),

              // Status History Card
              if (widget.report.statusHistory.isNotEmpty) ...[
                _buildStatusHistoryCard(),
                SizedBox(height: 10.h),
              ],

              // Comments Card
              if (widget.report.comments.isNotEmpty) ...[
                _buildCommentsCard(),
                SizedBox(height: 10.h),
              ],

              SizedBox(height: 80.h), // Space for floating button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
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
    // If we have full user profile, show it instead of basic reporter info
    if (userProfile != null) {
      return _buildEnhancedUserProfileCard();
    }

    // Fallback to basic reporter info from report data
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                'بيانات مقدم البلاغ (أساسية)',
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

          // Warning about limited data
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'لا يمكن تحميل بيانات المستخدم الكاملة. يتم عرض البيانات الأساسية فقط.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedUserProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          // Header with verification status
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ملف المستخدم الكامل',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (_isEgyptianNationalId(userProfile!.nationalId)) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag,
                                  color: Colors.green,
                                  size: 10.sp,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'مصري',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                      ],
                    ),
                    Text(
                      userProfile!.fullName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getVerificationStatusColor(
                    userProfile!.verificationStatus,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _getVerificationStatusText(userProfile!.verificationStatus),
                  style: TextStyle(
                    fontSize: 11.sp,
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
                width: 80.w,
                height: 80.w,
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
            SizedBox(height: 16.h),
          ],

          // Personal Information Grid
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المعلومات الشخصية',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'الاسم الكامل',
                        userProfile!.fullName,
                        Icons.person,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  'جنسيه المستخدم',
                  _determineUserType(userProfile!.nationalId),
                  Icons.person_outline,
                  Colors.blue,
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  'البريد الإلكتروني',
                  userProfile!.email,
                  Icons.email,
                  Colors.green,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'رقم الهاتف',
                        userProfile!.phone ?? 'غير محدد',
                        Icons.phone,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildInfoCard(
                        'رقم الهوية',
                        userProfile!.nationalId ?? 'غير محدد',
                        Icons.credit_card,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Location Information
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات الموقع',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'الجنسية',
                        _determineNationality(userProfile!.nationalId),
                        Icons.flag,
                        Colors.red,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildInfoCard(
                        'المحافظة',
                        userProfile!.governorate ?? 'غير محدد',
                        Icons.location_city,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
                if (userProfile!.city != null) ...[
                  SizedBox(height: 12.h),
                  _buildInfoCard(
                    'المدينة',
                    userProfile!.city!,
                    Icons.location_on,
                    Colors.indigo,
                  ),
                ],
                if (userProfile!.address != null) ...[
                  SizedBox(height: 12.h),
                  _buildInfoCard(
                    'العنوان الكامل',
                    userProfile!.address!,
                    Icons.home,
                    Colors.brown,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Statistics
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      'إجمالي',
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
              ],
            ),
          ),

          // Assignment info (if any)
          if (widget.report.assignedTo != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_ind, color: Colors.purple, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مُحال إلى',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.purple[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.report.assignedToName ?? 'غير محدد',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.purple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Identity Documents Display
          if (userProfile!.identityDocuments.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge, color: Colors.amber[700], size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'المستندات الثبوتية',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${userProfile!.identityDocuments.length} مستند',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ...userProfile!.identityDocuments.map(
                    (doc) => _buildIdentityDocumentPreview(doc),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityDocumentPreview(dynamic doc) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.badge, color: Colors.amber[700], size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _documentTypeArabic(doc.docType),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (doc.createdAt != null)
                      Text(
                        'تاريخ الرفع: ${DateFormat('dd/MM/yyyy').format(doc.createdAt)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Document Images Preview
          Row(
            children: [
              // Front Image
              if (doc.frontImageUrl != null) ...[
                Expanded(
                  child: _buildDocumentImagePreview(
                    doc.frontImageUrl!,
                    'الوجه الأمامي',
                    Icons.credit_card,
                  ),
                ),
                SizedBox(width: 12.w),
              ],

              // Back Image
              if (doc.backImageUrl != null) ...[
                Expanded(
                  child: _buildDocumentImagePreview(
                    doc.backImageUrl!,
                    'الوجه الخلفي',
                    Icons.flip_to_back,
                  ),
                ),
              ],
            ],
          ),

          // If no images available
          if (doc.frontImageUrl == null && doc.backImageUrl == null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 32.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'لم يتم رفع صور للمستند',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentImagePreview(
    String imageUrl,
    String label,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _viewDocumentImage(imageUrl, label),
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            // Image Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                  ),
                  child: Image.network(
                    _resolveMediaUrl(imageUrl),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.amber[700]!,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.red[50],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.red[300],
                                size: 24.sp,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'خطأ في التحميل',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Label Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.r),
                  bottomRight: Radius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 11.sp, color: Colors.amber[700]),
                  SizedBox(width: 4.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewDocumentImage(String imageUrl, String label) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                // Background
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.black87,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                // Content
                Center(
                  child: Container(
                    margin: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.badge,
                                color: Colors.amber[700],
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                iconSize: 24.sp,
                              ),
                            ],
                          ),
                        ),

                        // Image
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: InteractiveViewer(
                            child: Image.network(
                              _resolveMediaUrl(imageUrl),
                              fit: BoxFit.contain,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 300.h,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.amber[700]!,
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'جاري تحميل الصورة...',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  height: 300.h,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 48.sp,
                                          color: Colors.red[400],
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'فشل في تحميل الصورة',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.red[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildAdminStatusTracker() {
    // تحويل AdminReportStatus إلى ReportStatus لاستخدامه مع Enhanced Status Tracker
    final reportStatus = _convertAdminStatusToReportStatus(
      widget.report.reportStatus,
    );

    return EnhancedStatusTracker(
      currentStatus: reportStatus,
      createdAt: widget.report.submittedAt,
      reportId: widget.report.id,
    );
  }

  Widget _buildStatusProgressionButtons() {
    // تحديد التسلسل الصحيح للحالات
    final statusOrder = [
      ReportStatus.received,
      ReportStatus.underReview,
      ReportStatus.dataVerification,
      ReportStatus.actionTaken,
      ReportStatus.completed,
    ];

    final currentReportStatus = _convertAdminStatusToReportStatus(
      widget.report.reportStatus,
    );
    final currentIndex = statusOrder.indexOf(currentReportStatus);

    // إذا كان البلاغ مرفوض أو مكتمل، لا نظهر أزرار التقدم
    if (widget.report.reportStatus == AdminReportStatus.rejected ||
        currentReportStatus == ReportStatus.completed) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                child: Icon(Icons.trending_up, color: Colors.blue, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تتبع حالة البلاغ',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'انقل البلاغ للمرحلة التالية',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Current Status Display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _getReportStatusColor(
                currentReportStatus,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _getReportStatusColor(
                  currentReportStatus,
                ).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getReportStatusIcon(currentReportStatus),
                  color: _getReportStatusColor(currentReportStatus),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الحالة الحالية',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        currentReportStatus.arabicName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _getReportStatusColor(currentReportStatus),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Next Steps
          if (currentIndex < statusOrder.length - 1) ...[
            Text(
              'الخطوات التالية:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),

            // Show next possible statuses
            ...statusOrder
                .asMap()
                .entries
                .where((entry) {
                  return entry.key > currentIndex &&
                      entry.key <= currentIndex + 2;
                })
                .map((entry) {
                  final status = entry.value;
                  final isNextStep = entry.key == currentIndex + 1;

                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: _buildStatusProgressionButton(
                      status: status,
                      isEnabled: isNextStep,
                      isPrimary: isNextStep,
                    ),
                  );
                })
                ,
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'تم الانتهاء من جميع مراحل البلاغ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Reject Button (always available unless already rejected)
          if (widget.report.reportStatus != AdminReportStatus.rejected) ...[
            SizedBox(height: 16.h),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 16.h),
            _buildRejectButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusProgressionButton({
    required ReportStatus status,
    required bool isEnabled,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      // height: 44.h,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? () => _progressToStatus(status) : null,
        icon: Icon(_getReportStatusIcon(status), size: 20.sp),
        label: Text(
          'الانتقال إلى: ${status.arabicName}',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? _getReportStatusColor(status) : Colors.grey[100],
          foregroundColor: isPrimary ? Colors.white : Colors.grey[600],
          elevation: isPrimary ? 4 : 1,
          shadowColor:
              isPrimary
                  ? _getReportStatusColor(status).withOpacity(0.3)
                  : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side:
                isPrimary
                    ? BorderSide.none
                    : BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  Widget _buildRejectButton() {
    return SizedBox(
      width: double.infinity,
      // height: 44.h,
      child: OutlinedButton.icon(
        onPressed: () => _rejectReport(),
        icon: Icon(Icons.cancel, size: 20.sp, color: Colors.red),
        label: Text(
          'رفض البلاغ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildReportDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'موقع الحادثة',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (widget.report.incidentLocationAddress != null) ...[
            Text(
              widget.report.incidentLocationAddress!,
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خط العرض',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.report.incidentLocationLatitude!.toStringAsFixed(
                        6,
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خط الطول',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.report.incidentLocationLongitude!.toStringAsFixed(
                        6,
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openInGoogleMaps,
                  icon: Icon(Icons.map, size: 14.sp),
                  label: Text('خرائط جوجل', style: TextStyle(fontSize: 11.sp)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyCoordinates,
                  icon: Icon(Icons.copy, size: 14.sp),
                  label: Text(
                    'نسخ الإحداثيات',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  void _openPDF() async {
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // تحويل AdminReportEntity إلى ReportEntity مع بيانات محسنة
      final reportEntity = _createEnhancedReportEntity();

      // توليد PDF
      final pdfBytes =
          await ProfessionalEgyptianPdfService.generateProfessionalReportPdf(
            reportEntity,
          );

      // إخفاء مؤشر التحميل
      Navigator.pop(context);

      // حفظ الملف مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/admin_report_${widget.report.id.substring(0, 8)}.pdf',
      );
      await file.writeAsBytes(pdfBytes);

      // فتح الملف مباشرة
      final result = await OpenFile.open(file.path);

      // إظهار رسالة النجاح أو الخطأ
      if (mounted) {
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8.w),
                  const Text('تم فتح التقرير بنجاح'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        } else {
          // في حالة فشل الفتح، نحاول مشاركة الملف كبديل
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'تقرير إداري - بلاغ رقم #${widget.report.id.substring(0, 8)}',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 8.w),
                  const Text('تم توليد التقرير ومشاركته (لا يمكن فتحه مباشرة)'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // إخفاء مؤشر التحميل في حالة الخطأ
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في توليد التقرير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// إنشاء ReportEntity محسن بالبيانات الكاملة للمستخدم
  ReportEntity _createEnhancedReportEntity() {
    // استخدام بيانات المستخدم الكاملة إذا كانت متاحة
    String firstName = widget.report.reporterFirstName;
    String lastName = widget.report.reporterLastName;
    String phone = widget.report.reporterPhone;
    String nationalId = widget.report.reporterNationalId;

    if (userProfile != null) {
      // استخدام بيانات أكثر تفصيلاً من UserProfile
      final fullNameParts = userProfile!.fullName.split(' ');
      if (fullNameParts.isNotEmpty) {
        firstName = fullNameParts.first;
        lastName =
            fullNameParts.length > 1
                ? fullNameParts.sublist(1).join(' ')
                : fullNameParts.first;
      }
      phone = userProfile!.phone ?? widget.report.reporterPhone;
      nationalId = userProfile!.nationalId ?? widget.report.reporterNationalId;
    }

    return ReportEntity(
      id: widget.report.id,
      firstName: firstName,
      lastName: lastName,
      nationalId: nationalId,
      phone: phone,
      reportType: widget.report.reportTypeName ?? 'بلاغ عام',
      reportTypeId: widget.report.reportTypeId ?? 1,
      reportDetails: widget.report.reportDetails,
      latitude: widget.report.incidentLocationLatitude,
      longitude: widget.report.incidentLocationLongitude,
      locationName: widget.report.incidentLocationAddress,
      reportDateTime:
          widget.report.incidentDateTime ?? widget.report.submittedAt,
      mediaUrl:
          widget.report.media.isNotEmpty
              ? _resolveMediaUrl(widget.report.media.first.fileUrl)
              : null,
      mediaType:
          widget.report.media.isNotEmpty
              ? widget.report.media.first.mediaType.name
              : null,
      status: _convertAdminStatusToReportStatus(widget.report.reportStatus),
      submittedBy: widget.report.userId,
      createdAt: widget.report.submittedAt,
      updatedAt: widget.report.updatedAt,
    );
  }

  // Normalize/resolve media URL to a public URL (handles Supabase storage paths like bucket/path)
  String _resolveMediaUrl(String url) {
    try {
      if (url.isEmpty) return url;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
      final clean = url.startsWith('/') ? url.substring(1) : url;
      final firstSlash = clean.indexOf('/');
      if (firstSlash > 0) {
        final bucket = clean.substring(0, firstSlash);
        final path = clean.substring(firstSlash + 1);
        final encoded = path.split('/').map(Uri.encodeComponent).join('/');
        try {
          final publicUrl = Supabase.instance.client.storage
              .from(bucket)
              .getPublicUrl(encoded);
          if (publicUrl.isNotEmpty) return publicUrl;
        } catch (_) {}
        // Fallback: return original clean path if public URL couldn't be generated
        return url;
      }
      return url;
    } catch (_) {
      return url;
    }
  }

  /// تحويل حالة الإدارة إلى حالة التقرير
  ReportStatus _convertAdminStatusToReportStatus(AdminReportStatus status) {
    switch (status) {
      case AdminReportStatus.pending:
        return ReportStatus.received;
      case AdminReportStatus.underInvestigation:
        return ReportStatus.underReview;
      case AdminReportStatus.resolved:
        return ReportStatus.completed;
      case AdminReportStatus.closed:
        return ReportStatus.completed;
      case AdminReportStatus.rejected:
        return ReportStatus.rejected;
      case AdminReportStatus.received:
        return ReportStatus.received;
    }
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
    // تحديد الحالة الحالية والتالية
    final statusOrder = [
      ReportStatus.received,
      ReportStatus.underReview,
      ReportStatus.dataVerification,
      ReportStatus.actionTaken,
      ReportStatus.completed,
    ];

    final currentReportStatus = _convertAdminStatusToReportStatus(
      widget.report.reportStatus,
    );
    final currentIndex = statusOrder.indexOf(currentReportStatus);
    final nextStatus =
        currentIndex < statusOrder.length - 1
            ? statusOrder[currentIndex + 1]
            : null;

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

                      // Quick Status Progression (if next status is available)
                      if (nextStatus != null &&
                          widget.report.reportStatus !=
                              AdminReportStatus.rejected) ...[
                        _buildActionItem(
                          icon: _getReportStatusIcon(nextStatus),
                          title: 'الانتقال للمرحلة التالية',
                          subtitle: nextStatus.arabicName,
                          onTap: () => _progressToStatus(nextStatus),
                          color: _getReportStatusColor(nextStatus),
                        ),
                        Divider(height: 1.h, color: Colors.grey[200]),
                      ],

                      // PDF Action
                      _buildActionItem(
                        icon: Icons.picture_as_pdf,
                        title: 'فتح PDF',
                        subtitle: 'فتح ملف PDF بتفاصيل البلاغ',
                        onTap: () => _openPDF(),
                      ),
                      Divider(height: 1.h, color: Colors.grey[200]),

                      // Share Action
                      _buildActionItem(
                        icon: Icons.share,
                        title: 'مشاركة البلاغ',
                        subtitle: 'مشاركة تفاصيل البلاغ مع الآخرين',
                        onTap: () => _shareReport(),
                      ),
                      Divider(height: 1.h, color: Colors.grey[200]),

                      // Reject Action (if not already rejected or completed)
                      if (widget.report.reportStatus !=
                              AdminReportStatus.rejected &&
                          currentReportStatus != ReportStatus.completed) ...[
                        _buildActionItem(
                          icon: Icons.cancel,
                          title: 'رفض البلاغ',
                          subtitle: 'رفض البلاغ وإيقاف المعالجة',
                          onTap: () => _rejectReport(),
                          color: Colors.red,
                        ),
                        Divider(height: 1.h, color: Colors.grey[200]),
                      ],

                      // Refresh Action
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
    Color? color,
  }) {
    final actionColor = color ?? AppColors.primaryColor;

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: actionColor, size: 22.sp),
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

  Widget _buildAdminNotesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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

  // Helper methods

  /// تحديد ما إذا كان الرقم القومي مصري أم لا
  bool _isEgyptianNationalId(String? nationalId) {
    if (nationalId == null || nationalId.isEmpty) return false;

    // الرقم القومي المصري يجب أن يكون 14 رقم
    if (nationalId.length != 14) return false;

    // يجب أن يحتوي على أرقام فقط
    if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) return false;

    // الرقم الأول يجب أن يكون 2 أو 3 (تاريخ الميلاد في القرن العشرين أو الحادي والعشرين)
    final firstDigit = int.tryParse(nationalId[0]);
    if (firstDigit == null || (firstDigit != 2 && firstDigit != 3)) {
      return false;
    }

    return true;
  }

  /// تحديد الجنسية بناءً على الرقم القومي
  String _determineNationality(String? nationalId) {
    if (_isEgyptianNationalId(nationalId)) {
      return 'مصري';
    }
    return 'غير محدد';
  }

  /// تحديد نوع المستخدم بناءً على الرقم القومي
  String _determineUserType(String? nationalId) {
    if (_isEgyptianNationalId(nationalId)) {
      return 'مواطن مصري';
    }
    return 'مستخدم';
  }

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

  // Report Status Helper Methods
  Color _getReportStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.received:
        return Colors.blue;
      case ReportStatus.underReview:
        return Colors.orange;
      case ReportStatus.dataVerification:
        return Colors.amber[700]!;
      case ReportStatus.actionTaken:
        return Colors.purple;
      case ReportStatus.completed:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getReportStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.received:
        return Icons.receipt_long;
      case ReportStatus.underReview:
        return Icons.search;
      case ReportStatus.dataVerification:
        return Icons.fact_check;
      case ReportStatus.actionTaken:
        return Icons.engineering;
      case ReportStatus.completed:
        return Icons.check_circle;
      case ReportStatus.rejected:
        return Icons.cancel;
    }
  }

  AdminReportStatus _convertReportStatusToAdminStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.received:
        return AdminReportStatus.received;
      case ReportStatus.underReview:
        return AdminReportStatus.underInvestigation;
      case ReportStatus.dataVerification:
        return AdminReportStatus.underInvestigation;
      case ReportStatus.actionTaken:
        return AdminReportStatus.underInvestigation;
      case ReportStatus.completed:
        return AdminReportStatus.resolved;
      case ReportStatus.rejected:
        return AdminReportStatus.rejected;
    }
  }

  // Status Progression Methods
  void _progressToStatus(ReportStatus newStatus) async {
    final adminStatus = _convertReportStatusToAdminStatus(newStatus);

    // Show confirmation dialog
    final confirmed = await _showProgressConfirmationDialog(newStatus);
    if (!confirmed) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update status using the cubit
      await context.read<AdminReportsCubit>().updateReportStatusById(
        widget.report.id,
        adminStatus,
        notes: 'تم الانتقال إلى: ${newStatus.arabicName}',
      );

      // Hide loading
      Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8.w),
                Text('تم الانتقال إلى: ${newStatus.arabicName}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }

      // Refresh data
      _refreshData();
    } catch (e) {
      // Hide loading if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الحالة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectReport() async {
    final confirmed = await _showRejectConfirmationDialog();
    if (!confirmed) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update status to rejected
      await context.read<AdminReportsCubit>().rejectReport(
        widget.report.id,
        notes: 'تم رفض البلاغ من قبل الإدارة',
      );

      // Hide loading
      Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8.w),
                const Text('تم رفض البلاغ'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }

      // Refresh data
      _refreshData();
    } catch (e) {
      // Hide loading if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفض البلاغ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showProgressConfirmationDialog(ReportStatus newStatus) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      _getReportStatusIcon(newStatus),
                      color: _getReportStatusColor(newStatus),
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'تأكيد الانتقال',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'هل أنت متأكد من الانتقال إلى حالة: ${newStatus.arabicName}؟',
                  style: TextStyle(fontSize: 14.sp),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getReportStatusColor(newStatus),
                    ),
                    child: const Text(
                      'تأكيد',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<bool> _showRejectConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 24.sp),
                    SizedBox(width: 8.w),
                    const Text('تأكيد الرفض'),
                  ],
                ),
                content: const Text(
                  'هل أنت متأكد من رفض هذا البلاغ؟ لا يمكن التراجع عن هذا الإجراء.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'رفض البلاغ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  // Action methods
  void _openInGoogleMaps() async {
    if (widget.report.incidentLocationLatitude == null ||
        widget.report.incidentLocationLongitude == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('معلومات الموقع غير متوفرة'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final lat = widget.report.incidentLocationLatitude!;
    final lng = widget.report.incidentLocationLongitude!;

    // أولاً محاولة فتح تطبيق خرائط جوجل المثبت على الهاتف
    final googleMapsAppUrl =
        'comgooglemaps://?center=$lat,$lng&zoom=15&q=$lat,$lng';

    // للأندرويد: geo: protocol أو تطبيق خرائط جوجل
    final androidGoogleMapsUrl = 'google.navigation:q=$lat,$lng&mode=d';

    // لل iOS: خرائط أبل
    final appleMapsUrl = 'http://maps.apple.com/?ll=$lat,$lng&q=الموقع&z=15';

    // Web fallback URLs
    final webUrls = [
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&zoom=15',
      'https://maps.google.com/?q=$lat,$lng&zoom=15',
      'https://www.google.com/maps/@$lat,$lng,15z',
    ];

    bool launched = false;

    // محاولة فتح تطبيق خرائط جوجل أولاً
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsAppUrl))) {
        await launchUrl(
          Uri.parse(googleMapsAppUrl),
          mode: LaunchMode.externalApplication,
        );
        launched = true;
      }
    } catch (e) {
      // تجاهل الخطأ ومتابعة المحاولات الأخرى
    }

    // إذا لم ينجح، جرب الأندرويد URL
    if (!launched) {
      try {
        if (await canLaunchUrl(Uri.parse(androidGoogleMapsUrl))) {
          await launchUrl(
            Uri.parse(androidGoogleMapsUrl),
            mode: LaunchMode.externalApplication,
          );
          launched = true;
        }
      } catch (e) {
        // تجاهل الخطأ ومتابعة المحاولات الأخرى
      }
    }

    // إذا لم ينجح، جرب خرائط أبل (iOS)
    if (!launched) {
      try {
        if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
          await launchUrl(
            Uri.parse(appleMapsUrl),
            mode: LaunchMode.externalApplication,
          );
          launched = true;
        }
      } catch (e) {
        // تجاهل الخطأ ومتابعة المحاولات الأخرى
      }
    }

    // إذا لم تنجح التطبيقات، جرب URLs الويب
    if (!launched) {
      for (final url in webUrls) {
        try {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
            launched = true;
            break;
          }
        } catch (e) {
          continue;
        }
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يمكن فتح تطبيق الخرائط. تأكد من وجود تطبيق خرائط جوجل أو أي تطبيق خرائط آخر',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8.w),
              const Text('تم فتح الموقع في تطبيق الخرائط'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  void _copyCoordinates() async {
    if (widget.report.incidentLocationLatitude == null ||
        widget.report.incidentLocationLongitude == null) {
      return;
    }

    final lat = widget.report.incidentLocationLatitude!;
    final lng = widget.report.incidentLocationLongitude!;
    final coordinates = '$lat, $lng';

    try {
      await Clipboard.setData(ClipboardData(text: coordinates));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8.w),
                const Text('تم نسخ الإحداثيات'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في نسخ الإحداثيات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
