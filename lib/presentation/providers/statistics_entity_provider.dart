import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/statistics_entity.dart';

final statisticsPeriodEntityProvider = StateProvider<StatisticsPeriod>((ref) => StatisticsPeriod.monthly);

final statisticsEntityProvider = FutureProvider<StatisticsEntity>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  final period = ref.watch(statisticsPeriodEntityProvider);
  return repo.getStatistics(period);
});
