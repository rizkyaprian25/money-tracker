import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/dashboard_entity.dart';

/// Clean-architecture dashboard provider — uses `DashboardRepository` instead of direct `AppDatabase`.
/// Keep `dashboardProvider` (legacy) for backward compat; new screens should watch this one.
final dashboardEntityProvider = FutureProvider<DashboardEntity>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDashboard();
});
