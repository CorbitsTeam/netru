import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../../../core/usecases/usecase.dart';

part 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetDashboardStats getDashboardStats;

  AdminDashboardCubit({required this.getDashboardStats})
    : super(AdminDashboardInitial());

  Future<void> loadDashboardData() async {
    emit(AdminDashboardLoading());

    final result = await getDashboardStats(const NoParams());

    result.fold(
      (failure) => emit(AdminDashboardError(failure.toString())),
      (stats) => emit(AdminDashboardLoaded(stats)),
    );
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }
}
