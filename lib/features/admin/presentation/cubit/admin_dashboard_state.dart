part of 'admin_dashboard_cubit.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final DashboardStatsEntity stats;

  const AdminDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class AdminDashboardTrendsLoaded extends AdminDashboardState {
  final List<ReportTrendData> trends;

  const AdminDashboardTrendsLoaded(this.trends);

  @override
  List<Object?> get props => [trends];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
