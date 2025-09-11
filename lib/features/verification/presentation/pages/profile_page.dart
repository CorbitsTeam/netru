import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/verification_cubit.dart';
import '../cubit/verification_state.dart';
import '../widgets/verification_status_widget.dart';
import '../widgets/documents_list_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<VerificationCubit>().getUserDocuments(authState.user.id);
      context.read<VerificationCubit>().checkVerificationStatus(
        authState.user.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text('يرجى تسجيل الدخول أولاً'));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(authState.user),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVerificationSection(authState.user),
                      SizedBox(height: 24.h),
                      _buildPersonalInfoSection(authState.user),
                      SizedBox(height: 24.h),
                      _buildDocumentsSection(),
                      SizedBox(height: 24.h),
                      _buildAccountActionsSection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(UserEntity user) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile picture
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child:
                        user.profileImage != null
                            ? CachedNetworkImage(
                              imageUrl: user.profileImage!,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 40.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 40.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                            )
                            : Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 40.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationSection(UserEntity user) {
    return BlocBuilder<VerificationCubit, VerificationState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: AppColors.primaryColor,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'حالة التحقق من الهوية',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              if (state is VerificationStatusLoaded)
                VerificationStatusWidget(
                  isVerified: state.isVerified,
                  user: user,
                  onStartVerification: () {
                    context.pushNamed(Routes.documentScan);
                  },
                )
              else if (state is VerificationStatusLoading)
                const Center(child: CircularProgressIndicator())
              else
                VerificationStatusWidget(
                  isVerified: false,
                  user: user,
                  onStartVerification: () {
                    context.pushNamed(Routes.documentScan);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalInfoSection(UserEntity user) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'المعلومات الشخصية',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildInfoRow('الاسم الكامل', user.fullName),
          SizedBox(height: 12.h),
          _buildInfoRow('البريد الإلكتروني', user.email),

          if (user.phone != null) ...[
            SizedBox(height: 12.h),
            _buildInfoRow('رقم الهاتف', user.phone!),
          ],

          SizedBox(height: 12.h),
          _buildInfoRow(
            'نوع الحساب',
            user.userType == UserType.egyptian ? 'مواطن مصري' : 'مواطن أجنبي',
          ),

          if (user is CitizenEntity) ...[
            SizedBox(height: 12.h),
            _buildInfoRow('الرقم القومي', user.nationalId),
            if (user.address != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow('العنوان', user.address!),
            ],
          ],

          if (user is ForeignerEntity) ...[
            SizedBox(height: 12.h),
            _buildInfoRow('رقم جواز السفر', user.passportNumber),
            SizedBox(height: 12.h),
            _buildInfoRow('الجنسية', user.nationality),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return BlocBuilder<VerificationCubit, VerificationState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryColor,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'الوثائق المرفوعة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      context.pushNamed(Routes.documentScan);
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              if (state is DocumentsLoaded)
                DocumentsListWidget(documents: state.documents)
              else if (state is DocumentsLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildEmptyDocuments(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountActionsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'إعدادات الحساب',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildActionItem(
            icon: Icons.edit,
            title: 'تعديل المعلومات الشخصية',
            onTap: () {
              // Navigate to edit profile
            },
          ),

          _buildActionItem(
            icon: Icons.lock_outline,
            title: 'تغيير كلمة المرور',
            onTap: () {
              // Navigate to change password
            },
          ),

          _buildActionItem(
            icon: Icons.notification_important_outlined,
            title: 'إعدادات الإشعارات',
            onTap: () {
              // Navigate to notification settings
            },
          ),

          _buildActionItem(
            icon: Icons.help_outline,
            title: 'المساعدة والدعم',
            onTap: () {
              // Navigate to help
            },
          ),

          _buildActionItem(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            textColor: AppColors.red,
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: textColor ?? AppColors.grey, size: 24.sp),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.grey,
        size: 16.sp,
      ),
      onTap: onTap,
    );
  }

  Widget _buildEmptyDocuments() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 48.sp, color: AppColors.grey),
          SizedBox(height: 16.h),
          Text(
            'لم يتم رفع أي وثائق بعد',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قم برفع وثيقة هويتك للتحقق من حسابك',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.pushNamed(Routes.documentScan);
            },
            child: const Text('رفع وثيقة'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthCubit>().logout();
                  context.pushNamedAndRemoveUntil(Routes.loginScreen);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
    );
  }
}
