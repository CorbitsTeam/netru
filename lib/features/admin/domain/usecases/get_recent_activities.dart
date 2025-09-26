import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_dashboard_repository.dart';
import '../../../admin/presentation/widgets/recent_activity_widget.dart';

class GetRecentActivities implements UseCase<List<ActivityItem>, NoParams> {
  final AdminDashboardRepository repository;

  GetRecentActivities(this.repository);

  @override
  Future<Either<Failure, List<ActivityItem>>> call(NoParams params) async {
    return await repository.getRecentActivities();
  }
}
