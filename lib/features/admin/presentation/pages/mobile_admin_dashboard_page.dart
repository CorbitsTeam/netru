import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../widgets/reports_chart.dart';
import '../widgets/recent_activity_widget.dart';
import '../widgets/mobile_admin_drawer.dart';

class MobileAdminDashboardPage extends StatefulWidget {
  const MobileAdminDashboardPage({super.key});

  @override
  State<MobileAdminDashboardPage> createState() =>
      _MobileAdminDashboardPageState();
}

class _MobileAdminDashboardPageState extends State<MobileAdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      drawer: const MobileAdminDrawer(),
      body: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
        builder: (context, state) {
          if (state is AdminDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'حدث خطأ في تحميل البيانات',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminDashboardCubit>().loadDashboardData();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminDashboardCubit>().refreshDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    SizedBox(height: 20.h),

                    // Quick Stats Cards
                    _buildQuickStatsSection(state.stats),
                    SizedBox(height: 20.h),

                    // Charts Section
                    _buildChartsSection(state.stats),
                    SizedBox(height: 20.h),

                    // Recent Activity
                    _buildRecentActivitySection(),
                    SizedBox(height: 100.h), // Bottom padding for FAB
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'لوحة التحكم',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            context.read<AdminDashboardCubit>().refreshDashboard();
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً، مدير النظام',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'هنا يمكنك إدارة جميع جوانب النظام ومتابعة الإحصائيات',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(dynamic stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات السريعة',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
        _buildMobileStatsGrid(stats),
      ],
    );
  }

  Widget _buildMobileStatsGrid(dynamic stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      children: [
        _buildStatCard(
          title: 'إجمالي البلاغات',
          value: stats?.totalReports?.toString() ?? '0',
          icon: Icons.report,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'البلاغات المعلقة',
          value: stats?.pendingReports?.toString() ?? '0',
          icon: Icons.pending,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'إجمالي المستخدمين',
          value: stats?.totalUsers?.toString() ?? '0',
          icon: Icons.people,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'في انتظار التحقق',
          value: stats?.pendingVerifications?.toString() ?? '0',
          icon: Icons.verified_user,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(dynamic stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التحليلات والمخططات',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          constraints: BoxConstraints(maxHeight: 600.h, minHeight: 250.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ReportsChart(stats: stats),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النشاطات الأخيرة',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: RecentActivityWidget(activities: []),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _showQuickActions();
      },
      backgroundColor: Theme.of(context).primaryColor,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'إجراءات سريعة',
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
      ),
    );
  }

  void _showQuickActions() {
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
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'الإجراءات السريعة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildQuickActionTile(
                  icon: Icons.report_problem,
                  title: 'إدارة البلاغات',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin/reports');
                  },
                ),
                _buildQuickActionTile(
                  icon: Icons.people_outline,
                  title: 'إدارة المستخدمين',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin/users');
                  },
                ),
                _buildQuickActionTile(
                  icon: Icons.notifications_outlined,
                  title: 'إرسال إشعار',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin/notifications');
                  },
                ),
                _buildQuickActionTile(
                  icon: Icons.security,
                  title: 'إدارة حسابات المصادقة',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin/auth-manager');
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
