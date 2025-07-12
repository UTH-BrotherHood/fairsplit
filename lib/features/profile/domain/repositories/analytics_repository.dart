import 'package:fairsplit/features/profile/data/models/analytics_models.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsOverviewModel> getOverview();
  Future<List<MonthlyAnalyticsModel>> getMonthly();
  Future<List<YearlyAnalyticsModel>> getYearly();
  Future<CompareAnalyticsModel> getCompare(int month, int year);
}
