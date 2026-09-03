import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboard {
  final DashboardRepository repo;
  GetDashboard(this.repo);
  Future<DashboardEntity> call() => repo.getDashboard();
}
