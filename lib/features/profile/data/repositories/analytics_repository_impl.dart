import 'package:fairsplit/features/profile/data/datasources/analytics_remote_datasource.dart';
import 'package:fairsplit/features/profile/data/models/analytics_models.dart';
import 'package:fairsplit/features/profile/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDatasource remoteDatasource;

  AnalyticsRepositoryImpl(this.remoteDatasource);

  @override
  Future<AnalyticsOverviewModel> getOverview() async {
    return await remoteDatasource.getOverview();
  }

  @override
  Future<List<MonthlyAnalyticsModel>> getMonthly() async {
    return await remoteDatasource.getMonthly();
  }

  @override
  Future<List<YearlyAnalyticsModel>> getYearly() async {
    return await remoteDatasource.getYearly();
  }

  @override
  Future<CompareAnalyticsModel> getCompare(int month, int year) async {
    return await remoteDatasource.getCompare(month, year);
  }
}
