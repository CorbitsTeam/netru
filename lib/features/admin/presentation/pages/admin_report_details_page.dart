import 'dart:developer';

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

import 'package:supabase_flutter/supabase_flutter.dart';

class AdminReportDetailsPage extends StatefulWidget {
  final AdminReportEntity report;
  // Optional: reuse existing AdminReportsCubit from the list page so actions
  // taken here (status updates / assign / verify) refresh the list without
  // needing a manual refresh.
  final AdminReportsCubit? adminReportsCubit;

  const AdminReportDetailsPage({
    super.key,
    required this.report,
    this.adminReportsCubit,
  });

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
    // If a cubit was passed from the list page, reuse it via BlocProvider.value
    // so both pages share the same state and updates will reflect immediately.
    if (widget.adminReportsCubit != null) {
      return BlocProvider.value(
        value: widget.adminReportsCubit!,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButton: _buildFloatingActionMenu(),
        ),
      );
    }

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
          margin: EdgeInsetsDirectional.only(end: 12.w),
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
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Report Summary Card
              _buildMainSummaryCard(),
              SizedBox(height: 16.h),

              // Quick Actions Row
              _buildQuickActionsRow(),
              SizedBox(height: 16.h),

              // Expandable Sections
              _buildExpandableReporterSection(),
              SizedBox(height: 12.h),

              _buildExpandableDetailsSection(),
              SizedBox(height: 12.h),

              if (widget.report.media.isNotEmpty ||
                  (widget.report.incidentLocationLatitude != null &&
                      widget.report.incidentLocationLongitude != null))
                _buildExpandableMediaLocationSection(),
              SizedBox(height: 12.h),

              _buildExpandableStatusSection(),
              SizedBox(height: 12.h),

              _buildExpandableNotesSection(),

              SizedBox(height: 100.h), // Space for floating button
            ],
          ),
        ),
      ),
    );
  }

  // New enhanced UI components
  Widget _buildMainSummaryCard() {
    return Container(
      width: double.infinity,
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
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with reporter info
          Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // Report icon and number
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.assignment,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بلاغ #${widget.report.id.substring(0, 8).toUpperCase()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${widget.report.reporterFirstName} ${widget.report.reporterLastName}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          widget.report.reportStatus,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.report.reportStatus.arabicName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Quick info row
                Row(
                  children: [
                    _buildQuickInfoItem(
                      Icons.category,
                      'نوع البلاغ',
                      widget.report.reportTypeCustom ?? 'غير محدد',
                    ),
                    SizedBox(width: 16.w),
                    _buildQuickInfoItem(
                      Icons.priority_high,
                      'الأولوية',
                      widget.report.priorityLevel.arabicName,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    _buildQuickInfoItem(
                      Icons.access_time,
                      'تاريخ الإبلاغ',
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(widget.report.submittedAt),
                    ),
                    SizedBox(width: 16.w),
                    if (widget.report.caseNumber != null)
                      _buildQuickInfoItem(
                        Icons.confirmation_number,
                        'رقم القضية',
                        widget.report.caseNumber!,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Report details preview
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل البلاغ:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.report.reportDetails.length > 150
                      ? '${widget.report.reportDetails.substring(0, 150)}...'
                      : widget.report.reportDetails,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.8), size: 16.sp),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11.sp,
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
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        // Status progression
        // if (_canProgressStatus())
        //   Expanded(
        //     flex: 2,
        //     child: _buildQuickActionButton(
        //       icon: Icons.trending_up,
        //       label: 'تقدم الحالة',
        //       color: Colors.green,
        //       onTap: _showProgressDialog,
        //     ),
        //   ),
        if (_canProgressStatus()) SizedBox(width: 12.w),

        // Location button
        if (widget.report.incidentLocationLatitude != null)
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.map,
              label: 'الموقع',
              color: Colors.blue,
              onTap: _openInGoogleMaps,
            ),
          ),

        SizedBox(width: 12.w),

        // Identity Card button
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.perm_identity,
            label: 'بطاقة الهوية',
            color: Colors.orange,
            onTap: _showIdentityDocumentsForReporter,
          ),
        ),

        SizedBox(width: 12.w),

        // PDF button
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.picture_as_pdf,
            label: 'PDF',
            color: Colors.red,
            onTap: _openPDF,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Expandable Sections
  Widget _buildExpandableReporterSection() {
    return _buildExpandableCard(
      title: 'بيانات المُبلغ',
      icon: Icons.person,
      color: Colors.blue,
      child:
          isLoadingUserProfile
              ? SizedBox(
                height: 100.h,
                child: const Center(child: CircularProgressIndicator()),
              )
              : userProfile != null
              ? _buildEnhancedUserProfileCardContent()
              : _buildBasicReporterInfoContent(),
    );
  }

  Widget _buildExpandableDetailsSection() {
    return _buildExpandableCard(
      title: 'تفاصيل البلاغ',
      icon: Icons.description,
      color: AppColors.primaryColor,
      child: _buildReportDetailsContent(),
    );
  }

  Widget _buildExpandableMediaLocationSection() {
    return _buildExpandableCard(
      title: 'الوسائط والموقع',
      icon: Icons.perm_media,
      color: Colors.purple,
      child: Column(
        children: [
          // Location section
          if (widget.report.incidentLocationLatitude != null &&
              widget.report.incidentLocationLongitude != null) ...[
            _buildLocationContent(),
            if (widget.report.media.isNotEmpty) SizedBox(height: 16.h),
          ],

          // Media section
          if (widget.report.media.isNotEmpty) ...[
            _buildMediaContent(),
          ] else if (widget.report.incidentLocationLatitude == null ||
              widget.report.incidentLocationLongitude == null) ...[
            Container(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد وسائط أو موقع مرفق',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandableStatusSection() {
    return _buildExpandableCard(
      title: 'حالة ومتابعة البلاغ',
      icon: Icons.trending_up,
      color: Colors.green,
      child: Column(
        children: [
          _buildAdminStatusTracker(),
          SizedBox(height: 16.h),
          _buildStatusProgressionButtons(),
          if (widget.report.statusHistory.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildStatusHistoryContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandableNotesSection() {
    return _buildExpandableCard(
      title: 'الملاحظات والتعليقات',
      icon: Icons.comment,
      color: Colors.orange,
      child: Column(
        children: [
          _buildAdminNotesContent(),
          if (widget.report.comments.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildCommentsContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  // Content methods for expandable sections
  Widget _buildBasicReporterInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'الاسم الكامل',
          '${widget.report.reporterFirstName} ${widget.report.reporterLastName}',
          Icons.person_outline,
        ),
        SizedBox(height: 16.h),
        _buildInfoRow(
          'رقم الهوية',
          widget.report.reporterNationalId,
          Icons.credit_card,
        ),
        SizedBox(height: 16.h),
        _buildInfoRow('رقم الهاتف', widget.report.reporterPhone, Icons.phone),
        SizedBox(height: 16.h),
        // Prominent button to show identity documents (ID front/back)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showIdentityDocumentsForReporter,
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.perm_identity, size: 20.sp),
            ),
            label: Text(
              'عرض صور البطاقة الشخصية',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 4,
              shadowColor: Colors.orange.withOpacity(0.3),
            ),
          ),
        ),
        // Inline small previews of identity documents (visible in the reporter section)
        SizedBox(height: 8.h),
        _buildInlineIdentityDocs(),
        if (widget.report.isAnonymous) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility_off, color: Colors.orange, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'بلاغ مجهول الهوية',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showIdentityDocumentsForReporter() {
    // Collect identity documents from userProfile if available
    String? frontImageUrl;
    String? backImageUrl;
    String docType = 'البطاقة الشخصية';

    if (userProfile != null && userProfile!.identityDocuments.isNotEmpty) {
      final doc = userProfile!.identityDocuments.first;
      frontImageUrl = doc.frontImageUrl;
      backImageUrl = doc.backImageUrl;
      docType = _getDocumentTypeArabic(doc.docType.toString().split('.').last);
    }

    // Fallback: try to detect media in report.media that look like ID images
    if ((frontImageUrl == null && backImageUrl == null) &&
        widget.report.media.isNotEmpty) {
      final idKeywords = [
        'id',
        'card',
        'identity',
        'national',
        'بطاقة',
        'هويه',
        'هوية',
      ];
      for (final m in widget.report.media) {
        final fname = (m.fileName ?? m.fileUrl).toLowerCase();
        final desc = (m.description ?? '').toLowerCase();
        if (idKeywords.any((k) => fname.contains(k) || desc.contains(k))) {
          if (fname.contains('front') ||
              fname.contains('أمام') ||
              desc.contains('front') ||
              desc.contains('أمام')) {
            frontImageUrl = _resolveMediaUrl(m.fileUrl);
          } else if (fname.contains('back') ||
              fname.contains('ظهر') ||
              desc.contains('back') ||
              desc.contains('ظهر')) {
            backImageUrl = _resolveMediaUrl(m.fileUrl);
          } else {
            // If no specific side detected, assign to front if empty, otherwise back
            if (frontImageUrl == null) {
              frontImageUrl = _resolveMediaUrl(m.fileUrl);
            } else {
              backImageUrl ??= _resolveMediaUrl(m.fileUrl);
            }
          }
        }
      }
    }

    if (frontImageUrl == null && backImageUrl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد صور إثبات الهوية متاحة')),
      );
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        width: 40.w,
                        height: 4.h,
                        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),

                      // Header
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.perm_identity,
                                color: Colors.blue,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'بيانات هوية المُبلغ',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    docType,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                      Divider(color: Colors.grey[200], height: 1),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reporter info summary
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'معلومات المُبلغ',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    _buildInfoRowInBottomSheet(
                                      'الاسم',
                                      '${widget.report.reporterFirstName} ${widget.report.reporterLastName}',
                                      Icons.person_outline,
                                    ),
                                    SizedBox(height: 8.h),
                                    _buildInfoRowInBottomSheet(
                                      'رقم الهوية',
                                      widget.report.reporterNationalId,
                                      Icons.credit_card,
                                    ),
                                    SizedBox(height: 8.h),
                                    _buildInfoRowInBottomSheet(
                                      'رقم الهاتف',
                                      widget.report.reporterPhone,
                                      Icons.phone,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Identity cards section
                              Text(
                                'صور البطاقة الشخصية',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              SizedBox(height: 16.h),

                              // Front and Back cards
                              if (frontImageUrl != null ||
                                  backImageUrl != null) ...[
                                Row(
                                  children: [
                                    // Front image
                                    if (frontImageUrl != null)
                                      Expanded(
                                        child: _buildIdCardInBottomSheet(
                                          imageUrl: frontImageUrl,
                                          label: 'الوجه الأمامي',
                                          icon: Icons.badge,
                                        ),
                                      ),

                                    if (frontImageUrl != null &&
                                        backImageUrl != null)
                                      SizedBox(width: 12.w),

                                    // Back image
                                    if (backImageUrl != null)
                                      Expanded(
                                        child: _buildIdCardInBottomSheet(
                                          imageUrl: backImageUrl,
                                          label: 'الوجه الخلفي',
                                          icon: Icons.badge_outlined,
                                        ),
                                      ),
                                  ],
                                ),

                                SizedBox(height: 20.h),

                                // Action buttons
                                Row(
                                  children: [
                                    if (frontImageUrl != null)
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                () => _viewDocumentImage(
                                                  frontImageUrl!,
                                                  'الوجه الأمامي للبطاقة',
                                                ),
                                            icon: Icon(
                                              Icons.zoom_in,
                                              size: 18.sp,
                                            ),
                                            label: const Text('عرض الأمامي'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                              side: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    if (frontImageUrl != null &&
                                        backImageUrl != null)
                                      SizedBox(width: 12.w),

                                    if (backImageUrl != null)
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                () => _viewDocumentImage(
                                                  backImageUrl!,
                                                  'الوجه الخلفي للبطاقة',
                                                ),
                                            icon: Icon(
                                              Icons.zoom_in,
                                              size: 18.sp,
                                            ),
                                            label: const Text('عرض الخلفي'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                              side: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ] else ...[
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48.sp,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'لا توجد صور بطاقة متاحة',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildInfoRowInBottomSheet(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13.sp, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildIdCardInBottomSheet({
    required String imageUrl,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _viewDocumentImage(imageUrl, label),
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                _resolveMediaUrl(imageUrl),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                        strokeWidth: 2,
                        color: Colors.blue,
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
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 32.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'خطأ في تحميل الصورة',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Label overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 12.w,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tap indicator
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(Icons.zoom_in, color: Colors.white, size: 16.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gather identity document items from user profile or fallback to report media
  List<Map<String, dynamic>> _gatherIdentityDocs() {
    final List<Map<String, dynamic>> docs = [];

    if (userProfile != null && userProfile!.identityDocuments.isNotEmpty) {
      for (final doc in userProfile!.identityDocuments) {
        final docInfo = {
          'type': 'profile',
          'docType': doc.docType.toString().split('.').last,
          'frontUrl': doc.frontImageUrl,
          'backUrl': doc.backImageUrl,
        };
        docs.add(docInfo);
      }
    }

    // Fallback: scan report media for likely id files
    if (docs.isEmpty && widget.report.media.isNotEmpty) {
      final idKeywords = [
        'id',
        'card',
        'identity',
        'national',
        'بطاقة',
        'هويه',
        'هوية',
      ];
      String? frontUrl, backUrl;
      for (final m in widget.report.media) {
        final fname = (m.fileName ?? m.fileUrl).toLowerCase();
        final desc = (m.description ?? '').toLowerCase();
        if (idKeywords.any((k) => fname.contains(k) || desc.contains(k))) {
          if (fname.contains('front') ||
              fname.contains('امام') ||
              desc.contains('امام')) {
            frontUrl = _resolveMediaUrl(m.fileUrl);
          } else if (fname.contains('back') ||
              fname.contains('خلف') ||
              desc.contains('خلف')) {
            backUrl = _resolveMediaUrl(m.fileUrl);
          } else {
            // If no specific front/back indication, treat as front
            frontUrl ??= _resolveMediaUrl(m.fileUrl);
          }
        }
      }
      if (frontUrl != null || backUrl != null) {
        docs.add({
          'type': 'media',
          'docType': 'nationalId',
          'frontUrl': frontUrl,
          'backUrl': backUrl,
        });
      }
    }

    return docs;
  }

  /// Build professional identity card display showing front and back
  Widget _buildInlineIdentityDocs() {
    final docs = _gatherIdentityDocs();
    if (docs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        // Header with icon
        Row(
          children: [
            Icon(Icons.credit_card, size: 16.sp, color: Colors.blue),
            SizedBox(width: 6.w),
            Text(
              'إثبات الهوية',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Identity cards display
        ...docs.map((doc) => _buildIdentityCardWidget(doc)),
      ],
    );
  }

  /// Build a single identity document card widget
  Widget _buildIdentityCardWidget(Map<String, dynamic> doc) {
    final frontUrl = doc['frontUrl'] as String?;
    final backUrl = doc['backUrl'] as String?;
    final docType = doc['docType'] as String? ?? 'nationalId';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document type header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  _getDocumentTypeArabic(docType),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Front and back cards
          Row(
            children: [
              // Front card
              if (frontUrl != null)
                Expanded(
                  child: _buildIdCardSide(
                    imageUrl: frontUrl,
                    label: 'الوجه الأمامي',
                    icon: Icons.credit_card,
                  ),
                ),
              if (frontUrl != null && backUrl != null) SizedBox(width: 12.w),
              // Back card
              if (backUrl != null)
                Expanded(
                  child: _buildIdCardSide(
                    imageUrl: backUrl,
                    label: 'الوجه الخلفي',
                    icon: Icons.flip_to_back,
                  ),
                ),
            ],
          ),
          // If no images available
          if (frontUrl == null && backUrl == null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 24.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'لا توجد صور للهوية',
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

  /// Build individual ID card side (front or back)
  Widget _buildIdCardSide({
    required String imageUrl,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _viewDocumentImage(imageUrl, label),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Stack(
            children: [
              // ID card image
              Positioned.fill(
                child: Image.network(
                  _resolveMediaUrl(imageUrl),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
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
                              size: 24.sp,
                              color: Colors.red[300],
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
              // Label overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 12.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get Arabic name for document type
  String _getDocumentTypeArabic(String docType) {
    switch (docType) {
      case 'nationalId':
        return 'البطاقة الشخصية';
      case 'passport':
        return 'جواز السفر';
      default:
        return 'وثيقة إثبات هوية';
    }
  }

  Widget _buildEnhancedUserProfileCardContent() {
    if (userProfile == null) return _buildBasicReporterInfoContent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        // Basic Info
        _buildInfoRow('الاسم الكامل', userProfile!.fullName, Icons.person),
        SizedBox(height: 12.h),
        _buildInfoRow('البريد الإلكتروني', userProfile!.email, Icons.email),
        SizedBox(height: 12.h),
        _buildInfoRow(
          'رقم الهاتف',
          userProfile!.phone ?? 'غير محدد',
          Icons.phone,
        ),
        SizedBox(height: 12.h),
        _buildInfoRow(
          'رقم الهوية',
          userProfile!.nationalId ?? 'غير محدد',
          Icons.credit_card,
        ),

        if (userProfile!.governorate != null) ...[
          SizedBox(height: 12.h),
          _buildInfoRow(
            'المحافظة',
            userProfile!.governorate!,
            Icons.location_city,
          ),
        ],

        // Statistics
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
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
        ),
      ],
    );
  }

  Widget _buildReportDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildLocationContent() {
    return Column(
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
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                  Text(
                    widget.report.incidentLocationLatitude!.toStringAsFixed(6),
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
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                  Text(
                    widget.report.incidentLocationLongitude!.toStringAsFixed(6),
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
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  side: const BorderSide(color: Colors.blue),
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.perm_media, color: Colors.purple, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'الوسائط المرفقة',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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
        SizedBox(height: 16.h),

        // Show media grid if there are media files
        if (widget.report.media.isNotEmpty) ...[
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
        ] else ...[
          // Show "no media" message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 12.h),
                Text(
                  'لا توجد وسائط مرفقة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'لم يتم إرفاق أي صور أو فيديوهات مع هذا البلاغ',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سجل الحالات',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.report.statusHistory.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final history = widget.report.statusHistory[index];
            return _buildStatusHistoryItem(history);
          },
        ),
      ],
    );
  }

  Widget _buildAdminNotesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildCommentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'التعليقات',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.report.comments.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final comment = widget.report.comments[index];
            return _buildCommentItem(comment);
          },
        ),
      ],
    );
  }

  // Helper methods for new UI
  bool _canProgressStatus() {
    return widget.report.reportStatus != AdminReportStatus.rejected &&
        widget.report.reportStatus != AdminReportStatus.resolved &&
        widget.report.reportStatus != AdminReportStatus.closed;
  }

  void _showProgressDialog() {
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

    if (currentIndex < statusOrder.length - 1) {
      final nextStatus = statusOrder[currentIndex + 1];
      _progressToStatus(nextStatus);
    }
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
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child:
                      media.mediaType == MediaType.image
                          ? Image.network(
                            _resolveMediaUrl(media.fileUrl),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.red[50],
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.red[300],
                                    size: 32.sp,
                                  ),
                                ),
                              );
                            },
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                media.mediaType == MediaType.video
                                    ? Icons.play_circle_outline
                                    : Icons.insert_drive_file,
                                size: 32.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                ),
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
                children: [
                  Text(
                    media.mediaType.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  if (media.fileName != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      media.fileName!.length > 15
                          ? '${media.fileName!.substring(0, 15)}...'
                          : media.fileName!,
                      style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewMedia(ReportMediaEntity media) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            backgroundColor: Colors.black87,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child:
                        media.mediaType == MediaType.image
                            ? Image.network(
                              _resolveMediaUrl(media.fileUrl),
                              fit: BoxFit.contain,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 64.sp,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'خطأ في تحميل الصورة',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 64.sp,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'فيديو - اضغط لفتح في تطبيق خارجي',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                }),
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
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showLocationOptions,
                  icon: Icon(Icons.more_horiz, size: 14.sp),
                  label: Text('خيارات أكثر', style: TextStyle(fontSize: 11.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    side: const BorderSide(color: Colors.blue),
                    foregroundColor: Colors.blue,
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

    // Resolve cubit safely: prefer injected cubit, then context provider, then service locator fallback
    AdminReportsCubit cubit;
    if (widget.adminReportsCubit != null) {
      cubit = widget.adminReportsCubit!;
    } else {
      try {
        cubit = context.read<AdminReportsCubit>();
      } catch (_) {
        // Fallback to service locator if provider is not available in this context
        cubit = di.sl<AdminReportsCubit>();
      }
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update status using the resolved cubit
      await cubit.updateReportStatusById(
        widget.report.id,
        adminStatus,
        notes: 'تم الانتقال إلى: ${newStatus.arabicName}',
      );

      // Hide loading
      if (Navigator.canPop(context)) Navigator.pop(context);

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

      log('خطأ في تحديث الحالة: $e');
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

    // Resolve cubit safely as above
    AdminReportsCubit cubit;
    if (widget.adminReportsCubit != null) {
      cubit = widget.adminReportsCubit!;
    } else {
      try {
        cubit = context.read<AdminReportsCubit>();
      } catch (_) {
        cubit = di.sl<AdminReportsCubit>();
      }
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update status to rejected
      await cubit.rejectReport(
        widget.report.id,
        notes: 'تم رفض البلاغ من قبل الإدارة',
      );

      // Hide loading
      if (Navigator.canPop(context)) Navigator.pop(context);

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

  // Enhanced location methods
  void _openInGoogleMaps() async {
    final lat = widget.report.incidentLocationLatitude;
    final lng = widget.report.incidentLocationLongitude;

    if (lat == null || lng == null) {
      _showLocationError('معلومات الموقع غير متوفرة');
      return;
    }

    // Basic validation
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      _showLocationError('إحداثيات غير صحيحة');
      return;
    }

    final latStr = lat.toStringAsFixed(6);
    final lngStr = lng.toStringAsFixed(6);
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latStr,$lngStr';

    try {
      final uri = Uri.parse(googleMapsUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showLocationError('فشل في فتح تطبيق الخرائط');
      }
    } catch (e) {
      _showLocationError('حدث خطأ أثناء فتح الخرائط: $e');
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    message.split('\n').first,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (message.contains('\n')) ...[
              SizedBox(height: 4.h),
              Text(
                message.split('\n').skip(1).join('\n'),
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        action: SnackBarAction(
          label: 'نسخ الإحداثيات',
          textColor: Colors.white,
          onPressed: _copyCoordinates,
        ),
      ),
    );
  }

  void _showLocationOptions() {
    if (widget.report.incidentLocationLatitude == null ||
        widget.report.incidentLocationLongitude == null) {
      _showLocationError('معلومات الموقع غير متوفرة');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8.h),
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
                        'خيارات الموقع',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Google Maps
                      _buildLocationOption(
                        icon: Icons.map,
                        title: 'فتح في خرائط جوجل',
                        subtitle: 'عرض الموقع في تطبيق الخرائط',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          _openInGoogleMaps();
                        },
                      ),

                      // Copy coordinates
                      _buildLocationOption(
                        icon: Icons.copy,
                        title: 'نسخ الإحداثيات',
                        subtitle: 'نسخ خط العرض وخط الطول',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pop(context);
                          _copyCoordinates();
                        },
                      ),

                      // Share location
                      _buildLocationOption(
                        icon: Icons.share_location,
                        title: 'مشاركة الموقع',
                        subtitle: 'مشاركة إحداثيات الموقع',
                        color: Colors.green,
                        onTap: () {
                          Navigator.pop(context);
                          _shareLocation();
                        },
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: color, size: 22.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }

  void _shareLocation() async {
    if (widget.report.incidentLocationLatitude == null ||
        widget.report.incidentLocationLongitude == null) {
      return;
    }

    final lat = widget.report.incidentLocationLatitude!;
    final lng = widget.report.incidentLocationLongitude!;
    final locationText =
        'موقع البلاغ #${widget.report.id.substring(0, 8)}\n'
        'خط العرض: $lat\n'
        'خط الطول: $lng\n'
        'رابط الخريطة: https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      await Share.share(locationText, subject: 'موقع البلاغ');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في مشاركة الموقع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyCoordinates() async {
    if (widget.report.incidentLocationLatitude == null ||
        widget.report.incidentLocationLongitude == null) {
      return;
    }

    final lat = widget.report.incidentLocationLatitude!;
    final lng = widget.report.incidentLocationLongitude!;

    // Create a more comprehensive coordinate text
    final coordinatesText = '''خط العرض: ${lat.toStringAsFixed(6)}
خط الطول: ${lng.toStringAsFixed(6)}
الإحداثيات: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}
رابط خرائط جوجل: https://www.google.com/maps/search/?api=1&query=${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}''';

    try {
      await Clipboard.setData(ClipboardData(text: coordinatesText));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8.w),
              const Text('تم نسخ الإحداثيات ورابط الخريطة'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(child: Text('فشل في نسخ الإحداثيات: $e')),
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
  }
}
