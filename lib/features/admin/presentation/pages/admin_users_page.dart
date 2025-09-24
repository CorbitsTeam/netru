import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../cubit/admin_users_cubit.dart';
import '../widgets/mobile_admin_drawer.dart';
import '../widgets/user_avatar_widget.dart';
import 'user_details_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late AdminUsersCubit _adminUsersCubit;
  List<AdminUserEntity> _filteredUsers = [];
  String _searchQuery = '';
  AdminUserType? _selectedUserType;
  VerificationStatus? _selectedVerificationStatus;

  @override
  void initState() {
    super.initState();
    _adminUsersCubit = GetIt.instance<AdminUsersCubit>();
    _adminUsersCubit.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminUsersCubit>(
      create: (context) => _adminUsersCubit,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            'إدارة المستخدمين',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list, size: 24.sp),
              onPressed: _showFilterDialog,
              tooltip: 'تصفية',
            ),
          ],
        ),
        drawer: const MobileAdminDrawer(selectedRoute: '/admin/users'),
        body: BlocListener<AdminUsersCubit, AdminUsersState>(
          listener: (context, state) {
            if (state is AdminUsersVerified) {
              _showSnackBar('تم توثيق المستخدم بنجاح', Colors.green);
            } else if (state is AdminUsersSuspended) {
              _showSnackBar('تم تحديث حالة المستخدم بنجاح', Colors.orange);
            } else if (state is AdminUsersError) {
              _showSnackBar(state.message, Colors.red);
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              await _adminUsersCubit.loadUsers();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [_buildSummaryCards(), _buildUsersContent()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<AdminUsersCubit, AdminUsersState>(
      builder: (context, state) {
        if (state is AdminUsersLoaded) {
          final users = state.users;
          final totalUsers = users.length;
          final verifiedUsers =
              users
                  .where(
                    (u) => u.verificationStatus == VerificationStatus.verified,
                  )
                  .length;
          final pendingUsers =
              users
                  .where(
                    (u) => u.verificationStatus == VerificationStatus.pending,
                  )
                  .length;
          final citizenUsers =
              users.where((u) => u.userType == AdminUserType.citizen).length;

          return Container(
            padding: EdgeInsets.all(16.w),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              children: [
                _buildSummaryCard(
                  'إجمالي المستخدمين',
                  totalUsers.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  'موثقين',
                  verifiedUsers.toString(),
                  Icons.verified_user,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'في الانتظار',
                  pendingUsers.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  'مواطنين',
                  citizenUsers.toString(),
                  Icons.flag,
                  Colors.purple,
                ),
              ],
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(16.w),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            children: [
              _buildSummaryCard(
                'إجمالي المستخدمين',
                '0',
                Icons.people,
                Colors.blue,
              ),
              _buildSummaryCard(
                'موثقين',
                '0',
                Icons.verified_user,
                Colors.green,
              ),
              _buildSummaryCard(
                'في الانتظار',
                '0',
                Icons.pending,
                Colors.orange,
              ),
              _buildSummaryCard('مواطنين', '0', Icons.flag, Colors.purple),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24.sp),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersContent() {
    return BlocBuilder<AdminUsersCubit, AdminUsersState>(
      builder: (context, state) {
        if (state is AdminUsersLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is AdminUsersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  'حدث خطأ في تحميل البيانات',
                  style: TextStyle(fontSize: 16.sp, color: AppColors.error),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => _adminUsersCubit.loadUsers(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          );
        } else if (state is AdminUsersLoaded) {
          _filteredUsers = _filterUsers(state.users);

          return Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildSearchBar(),
                SizedBox(height: 16.h),
                _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserCard(user, index);
                      },
                    ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'البحث عن مستخدم...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'لا توجد بيانات مستخدمين',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AdminUserEntity user, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatarWidget(
                  imageUrl: user.profileImage,
                  userName: user.fullName,
                  radius: 25,
                  backgroundColor: _getUserTypeColor(
                    user.userType,
                  ).withValues(alpha: 0.1),
                  textColor: _getUserTypeColor(user.userType),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) => _handleUserAction(value, user),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('عرض'),
                            ],
                          ),
                        ),
                        // Show verify option only for non-verified users
                        if (user.verificationStatus !=
                            VerificationStatus.verified)
                          const PopupMenuItem(
                            value: 'verify',
                            child: Row(
                              children: [
                                Icon(Icons.verified, color: Colors.green),
                                SizedBox(width: 8),
                                Text('توثيق'),
                              ],
                            ),
                          ),
                        // Show suspend option for verified users
                        if (user.verificationStatus ==
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
                      ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildStatusChip(
                  _getUserTypeText(user.userType),
                  _getUserTypeColor(user.userType),
                ),
                SizedBox(width: 8.w),
                _buildStatusChip(
                  _getVerificationStatusText(user.verificationStatus),
                  _getVerificationStatusColor(user.verificationStatus),
                ),
              ],
            ),
            if (user.phone?.isNotEmpty == true) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.phone, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    user.phone!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (user.governorate?.isNotEmpty == true) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    user.governorate!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.date_range, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  'تاريخ التسجيل: ${_formatDate(user.createdAt)}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
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

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  List<AdminUserEntity> _filterUsers(List<AdminUserEntity> users) {
    return users.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user.phone?.contains(_searchQuery) == true);

      final matchesUserType =
          _selectedUserType == null || user.userType == _selectedUserType;

      final matchesVerification =
          _selectedVerificationStatus == null ||
          user.verificationStatus == _selectedVerificationStatus;

      return matchesSearch && matchesUserType && matchesVerification;
    }).toList();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تصفية المستخدمين',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildFilterItem(
                  'نوع المستخدم',
                  _selectedUserType?.arabicName,
                  AdminUserType.values.map((e) => e.arabicName).toList(),
                ),
                _buildFilterItem(
                  'حالة التوثيق',
                  _selectedVerificationStatus != null
                      ? _getVerificationStatusText(_selectedVerificationStatus!)
                      : null,
                  VerificationStatus.values
                      .map((e) => _getVerificationStatusText(e))
                      .toList(),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                        ),
                        child: const Text('إعادة تعيين'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text('تطبيق'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterItem(String title, String? value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text('اختر $title'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
          items:
              options
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
          onChanged: (newValue) {
            setState(() {
              if (title == 'نوع المستخدم') {
                _selectedUserType =
                    newValue != null
                        ? AdminUserType.values.firstWhere(
                          (e) => e.arabicName == newValue,
                        )
                        : null;
              } else if (title == 'حالة التوثيق') {
                _selectedVerificationStatus =
                    newValue != null
                        ? VerificationStatus.values.firstWhere(
                          (e) => _getVerificationStatusText(e) == newValue,
                        )
                        : null;
              }
            });
          },
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedUserType = null;
      _selectedVerificationStatus = null;
    });
    Navigator.pop(context);
  }

  void _applyFilters() {
    setState(() {});
    Navigator.pop(context);
  }

  // void _exportUsers() {
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text('جاري تصدير المستخدمين...')));
  // }

  // void _showBulkActionsDialog() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('العمليات المجمعة'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               ListTile(
  //                 leading: const Icon(Icons.verified_user, color: Colors.green),
  //                 title: const Text('توثيق المستخدمين المحددين'),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _bulkVerifyUsers();
  //                 },
  //               ),
  //               ListTile(
  //                 leading: const Icon(Icons.email, color: Colors.blue),
  //                 title: const Text('إرسال إشعار جماعي'),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _sendBulkNotification();
  //                 },
  //               ),
  //               ListTile(
  //                 leading: const Icon(
  //                   Icons.file_download,
  //                   color: Colors.orange,
  //                 ),
  //                 title: const Text('تصدير البيانات'),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _exportUsers();
  //                 },
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('إلغاء'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  void _handleUserAction(String action, AdminUserEntity user) {
    switch (action) {
      case 'view':
        _viewUser(user);
        break;
      case 'verify':
        _adminUsersCubit.verifyUserById(user.id, VerificationStatus.verified);
        // The success message will be shown through BlocListener
        break;
      case 'suspend':
        _showSuspendDialog(user);
        break;
    }
  }

  void _viewUser(AdminUserEntity user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailsPage(user: user)),
    );
  }

  // void _bulkVerifyUsers() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('جاري توثيق المستخدمين المحددين...')),
  //   );
  // }

  // void _sendBulkNotification() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('جاري إرسال الإشعار الجماعي...')),
  //   );
  // }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuspendDialog(AdminUserEntity user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إيقاف الحساب'),
            content: Text('هل أنت متأكد من إيقاف حساب ${user.fullName}؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _adminUsersCubit.suspendUserById(
                    user.id,
                    true,
                    reason: 'تم إيقاف الحساب من قبل الإدارة',
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

  @override
  void dispose() {
    _adminUsersCubit.close();
    super.dispose();
  }
}
