import '../entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<DashboardEntity> getDashboard();
  Stream<void> watchDashboardTrigger();
}
