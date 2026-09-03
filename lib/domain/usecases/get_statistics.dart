import '../entities/statistics_entity.dart';
import '../repositories/statistics_repository.dart';

class GetStatistics {
  final StatisticsRepository repo;
  GetStatistics(this.repo);
  Future<StatisticsEntity> call(StatisticsPeriod period) => repo.getStatistics(period);
}
