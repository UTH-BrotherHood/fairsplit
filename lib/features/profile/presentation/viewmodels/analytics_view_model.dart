import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/profile/data/models/analytics_models.dart';
import 'package:fairsplit/features/profile/domain/repositories/analytics_repository.dart';

class AnalyticsViewModel extends StateNotifier<AsyncValue<AnalyticsData>> {
  final AnalyticsRepository repository;

  AnalyticsViewModel(this.repository) : super(const AsyncValue.loading());

  Future<void> fetchAnalytics() async {
    state = const AsyncValue.loading();
    try {
      final overview = await repository.getOverview();
      final monthly = await repository.getMonthly();
      final yearly = await repository.getYearly();
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;
      final compare = await repository.getCompare(currentMonth, currentYear);

      state = AsyncValue.data(
        AnalyticsData(
          overview: overview,
          monthly: monthly,
          yearly: yearly,
          compare: compare,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshCompare(int month, int year) async {
    try {
      final currentState = state.value;
      if (currentState != null) {
        final compare = await repository.getCompare(month, year);
        state = AsyncValue.data(currentState.copyWith(compare: compare));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class AnalyticsData {
  final AnalyticsOverviewModel overview;
  final List<MonthlyAnalyticsModel> monthly;
  final List<YearlyAnalyticsModel> yearly;
  final CompareAnalyticsModel compare;

  AnalyticsData({
    required this.overview,
    required this.monthly,
    required this.yearly,
    required this.compare,
  });

  AnalyticsData copyWith({
    AnalyticsOverviewModel? overview,
    List<MonthlyAnalyticsModel>? monthly,
    List<YearlyAnalyticsModel>? yearly,
    CompareAnalyticsModel? compare,
  }) {
    return AnalyticsData(
      overview: overview ?? this.overview,
      monthly: monthly ?? this.monthly,
      yearly: yearly ?? this.yearly,
      compare: compare ?? this.compare,
    );
  }
}
