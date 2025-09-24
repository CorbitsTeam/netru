import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/admin_auth_manager_cubit.dart';

class AdminAuthManagerPage extends StatefulWidget {
  const AdminAuthManagerPage({super.key});

  @override
  State<AdminAuthManagerPage> createState() => _AdminAuthManagerPageState();
}

class _AdminAuthManagerPageState extends State<AdminAuthManagerPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminAuthManagerCubit>().loadUsersWithoutAuthAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إدارة حسابات المصادقة'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<AdminAuthManagerCubit>()
                  .loadUsersWithoutAuthAccount();
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminAuthManagerCubit, AdminAuthManagerState>(
        listener: (context, state) {
          if (state is AdminAuthManagerAccountCreated) {
            _showPasswordDialog(state.email, state.password);
          } else if (state is AdminAuthManagerBulkAccountsCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء جميع حسابات المصادقة بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdminAuthManagerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminAuthManagerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminAuthManagerUsersLoaded) {
            if (state.usersWithoutAuth.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildHeader(state.usersWithoutAuth.length),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.usersWithoutAuth.length,
                    itemBuilder: (context, index) {
                      final user = state.usersWithoutAuth[index];
                      return _buildUserCard(user);
                    },
                  ),
                ),
              ],
            );
          }

          if (state is AdminAuthManagerError) {
            return _buildErrorState(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(int usersCount) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'تحذير: مستخدمون بدون حسابات مصادقة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'تم العثور على $usersCount مستخدم في قاعدة البيانات بدون حسابات مصادقة (Authentication). هذا يعني أنهم لا يستطيعون تسجيل الدخول للتطبيق.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showBulkCreateDialog(),
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('إنشاء جميع الحسابات تلقائياً'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
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
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['full_name'] ?? 'غير محدد',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user['email'] ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(
                      user['user_type'],
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getUserTypeLabel(user['user_type']),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _getUserTypeColor(user['user_type']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUserDetails(user),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('التفاصيل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createAuthAccount(user),
                    icon: const Icon(Icons.key, size: 16),
                    label: const Text('إنشاء حساب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user, size: 64.sp, color: Colors.green),
          SizedBox(height: 16.h),
          Text(
            'ممتاز! 🎉',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'جميع المستخدمين لديهم حسابات مصادقة',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context
                  .read<AdminAuthManagerCubit>()
                  .loadUsersWithoutAuthAccount();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Color _getUserTypeColor(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'citizen':
        return Colors.blue;
      case 'foreigner':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getUserTypeLabel(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'admin':
        return 'مدير';
      case 'citizen':
        return 'مواطن';
      case 'foreigner':
        return 'أجنبي';
      default:
        return 'غير محدد';
    }
  }

  void _createAuthAccount(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إنشاء حساب مصادقة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('هل تريد إنشاء حساب مصادقة للمستخدم:'),
                SizedBox(height: 8.h),
                Text(
                  '${user['full_name']}\n${user['email']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                const Text(
                  'سيتم إنشاء كلمة مرور افتراضية وإرسالها للمستخدم.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context
                      .read<AdminAuthManagerCubit>()
                      .createAuthAccountForSingleUser(
                        email: user['email'],
                        userId: user['id'],
                        fullName: user['full_name'] ?? 'User',
                      );
                },
                child: const Text('إنشاء'),
              ),
            ],
          ),
    );
  }

  void _showBulkCreateDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إنشاء جميع حسابات المصادقة'),
            content: const Text(
              'هل تريد إنشاء حسابات مصادقة لجميع المستخدمين؟\n\n'
              'سيتم إنشاء كلمات مرور افتراضية لجميع المستخدمين.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context
                      .read<AdminAuthManagerCubit>()
                      .createAuthAccountsForAll();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('إنشاء الجميع'),
              ),
            ],
          ),
    );
  }

  void _showPasswordDialog(String email, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                SizedBox(width: 8.w),
                const Text('تم إنشاء الحساب'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تم إنشاء حساب مصادقة للإيميل:'),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الإيميل: $email'),
                      SizedBox(height: 4.h),
                      Text('كلمة المرور: $password'),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'تم إرسال بيانات الدخول للمستخدم عبر الإشعارات.',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context
                      .read<AdminAuthManagerCubit>()
                      .loadUsersWithoutAuthAccount();
                },
                child: const Text('موافق'),
              ),
            ],
          ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تفاصيل المستخدم'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('الاسم', user['full_name'] ?? 'غير محدد'),
                  _buildDetailRow('الإيميل', user['email'] ?? 'غير محدد'),
                  _buildDetailRow(
                    'نوع المستخدم',
                    _getUserTypeLabel(user['user_type']),
                  ),
                  _buildDetailRow(
                    'تاريخ الإنشاء',
                    user['created_at'] ?? 'غير محدد',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
