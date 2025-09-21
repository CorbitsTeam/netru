import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../widgets/dashboard_stats_cards.dart';
import '../widgets/reports_chart.dart';
import '../widgets/recent_activity_widget.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/quick_actions_widget.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          const AdminSidebar(),

          // Main content
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Dashboard content
                  Expanded(
                    child: BlocBuilder<
                      AdminDashboardCubit,
                      AdminDashboardState
                    >(
                      builder: (context, state) {
                        if (state is AdminDashboardLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is AdminDashboardError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'خطأ في تحميل البيانات',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<AdminDashboardCubit>()
                                        .refreshDashboard();
                                  },
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is AdminDashboardLoaded) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats cards
                                DashboardStatsCards(stats: state.stats),

                                const SizedBox(height: 24),

                                // Quick Actions
                                const QuickActionsWidget(),

                                const SizedBox(height: 24),

                                // Charts and analytics
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Reports chart
                                    Expanded(
                                      flex: 2,
                                      child: ReportsChart(stats: state.stats),
                                    ),

                                    const SizedBox(width: 24),

                                    // Recent activity
                                    Expanded(
                                      flex: 1,
                                      child: RecentActivityWidget(
                                        activities: _getMockActivities(),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Additional analytics
                                _buildAdditionalAnalytics(state.stats),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
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

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Page title
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة التحكم الإدارية',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'إدارة البلاغات والمستخدمين',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Refresh button
            IconButton(
              onPressed: () {
                context.read<AdminDashboardCubit>().refreshDashboard();
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث البيانات',
            ),

            // Notifications
            IconButton(
              onPressed: () {
                // Navigate to notifications
              },
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: 'الإشعارات',
            ),

            // Profile menu
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    // Navigate to profile
                    break;
                  case 'settings':
                    // Navigate to settings
                    break;
                  case 'logout':
                    // Logout
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Text('الملف الشخصي'),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Text('الإعدادات'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('تسجيل الخروج'),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalAnalytics(dynamic stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التحليلات الإضافية',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'هنا يمكن إضافة المزيد من التحليلات والإحصائيات التفصيلية حول أداء النظام.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  List<ActivityItem> _getMockActivities() {
    return [
      ActivityItem(
        id: '1',
        title: 'بلاغ جديد تم إنشاؤه',
        description: 'بلاغ عن سرقة في حي المعادي',
        type: ActivityType.reportCreated,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        hasAction: true,
      ),
      ActivityItem(
        id: '2',
        title: 'تم تحديث حالة بلاغ',
        description: 'تم تغيير حالة البلاغ #1234 إلى "قيد المراجعة"',
        type: ActivityType.reportUpdated,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ActivityItem(
        id: '3',
        title: 'مستخدم جديد مسجل',
        description: 'انضم مستخدم جديد للمنصة',
        type: ActivityType.userRegistered,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ActivityItem(
        id: '4',
        title: 'تم إرسال إشعار جماعي',
        description: 'تم إرسال تنبيه أمني لـ 500 مستخدم',
        type: ActivityType.notificationSent,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        hasAction: true,
      ),
      ActivityItem(
        id: '5',
        title: 'تم التحقق من مستخدم',
        description: 'تم التحقق من هوية المستخدم أحمد محمد',
        type: ActivityType.userVerified,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
