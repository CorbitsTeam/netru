import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_recent_activities.dart';
import '../widgets/recent_activity_widget.dart';
import '../../../../core/usecases/usecase.dart';

part 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetDashboardStats getDashboardStats;
  final GetRecentActivities getRecentActivities;

  DashboardStatsEntity? _cachedStats;
  List<ActivityItem>? _cachedActivities;

  AdminDashboardCubit({
    required this.getDashboardStats,
    required this.getRecentActivities,
  }) : super(AdminDashboardInitial());

  // Use a safe emit to avoid throwing if the cubit has been closed
  void _safeEmit(AdminDashboardState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  // Getter to access cached stats
  DashboardStatsEntity? get cachedStats => _cachedStats;

  Future<void> loadDashboardData() async {
    _safeEmit(AdminDashboardLoading());

    final result = await getDashboardStats(const NoParams());

    result.fold(
      (failure) => _safeEmit(AdminDashboardError(failure.toString())),
      (stats) {
        _cachedStats = stats;
        _safeEmit(AdminDashboardLoaded(stats));
        // Load activities immediately after stats
        loadRecentActivities();
      },
    );
  }

  Future<void> loadRecentActivities() async {
    print('Loading recent activities...');

    final result = await getRecentActivities(const NoParams());

    result.fold(
      (failure) {
        print('Failed to load recent activities: $failure');
        // Use cached activities if available, otherwise emit stats only
        if (_cachedActivities != null) {
          _safeEmit(AdminDashboardActivitiesLoaded(_cachedActivities!));
        } else if (_cachedStats != null) {
          _safeEmit(AdminDashboardLoaded(_cachedStats!));
        }
      },
      (activities) {
        print('Loaded ${activities.length} activities');
        _cachedActivities = activities;

        // Emit activities loaded state
        _safeEmit(AdminDashboardActivitiesLoaded(activities));
      },
    );
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }
}
