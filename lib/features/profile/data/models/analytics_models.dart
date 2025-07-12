class AnalyticsOverviewModel {
  final double totalSpent;
  final double totalPaid;
  final double totalDebt;
  final int transactionCount;
  final double balance;

  AnalyticsOverviewModel({
    required this.totalSpent,
    required this.totalPaid,
    required this.totalDebt,
    required this.transactionCount,
    required this.balance,
  });

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewModel(
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      totalDebt: (json['totalDebt'] ?? 0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}

class MonthlyAnalyticsModel {
  final int month;
  final double totalSpent;
  final double totalPaid;
  final double balance;
  final Map<String, double> categoriesSpent;
  final int transactionCount;

  MonthlyAnalyticsModel({
    required this.month,
    required this.totalSpent,
    required this.totalPaid,
    required this.balance,
    required this.categoriesSpent,
    required this.transactionCount,
  });

  factory MonthlyAnalyticsModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> categories = {};
    if (json['categoriesSpent'] != null) {
      final categoriesMap = json['categoriesSpent'] as Map<String, dynamic>;
      categories = categoriesMap.map(
        (key, value) => MapEntry(key, (value ?? 0).toDouble()),
      );
    }

    return MonthlyAnalyticsModel(
      month: json['month'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      categoriesSpent: categories,
      transactionCount: json['transactionCount'] ?? 0,
    );
  }
}

class YearlyAnalyticsModel {
  final int year;
  final double totalSpent;
  final double totalPaid;
  final double totalDebt;
  final int transactionCount;
  final double balance;

  YearlyAnalyticsModel({
    required this.year,
    required this.totalSpent,
    required this.totalPaid,
    required this.totalDebt,
    required this.transactionCount,
    required this.balance,
  });

  factory YearlyAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return YearlyAnalyticsModel(
      year: json['year'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      totalDebt: (json['totalDebt'] ?? 0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}

class CompareAnalyticsModel {
  final MonthlyAnalyticsModel? current;
  final MonthlyAnalyticsModel? previous;
  final double? spentChange;
  final double? paidChange;

  CompareAnalyticsModel({
    this.current,
    this.previous,
    this.spentChange,
    this.paidChange,
  });

  factory CompareAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return CompareAnalyticsModel(
      current: json['current'] != null
          ? MonthlyAnalyticsModel.fromJson(json['current'])
          : null,
      previous: json['previous'] != null
          ? MonthlyAnalyticsModel.fromJson(json['previous'])
          : null,
      spentChange: json['spentChange']?.toDouble(),
      paidChange: json['paidChange']?.toDouble(),
    );
  }
}

// Response models
class AnalyticsOverviewResponse {
  final String message;
  final int status;
  final AnalyticsOverviewModel data;

  AnalyticsOverviewResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory AnalyticsOverviewResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data: AnalyticsOverviewModel.fromJson(json['data'] ?? {}),
    );
  }
}

class MonthlyAnalyticsResponse {
  final String message;
  final int status;
  final List<MonthlyAnalyticsModel> data;

  MonthlyAnalyticsResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory MonthlyAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return MonthlyAnalyticsResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data: dataList
          .map((item) => MonthlyAnalyticsModel.fromJson(item))
          .toList(),
    );
  }
}

class YearlyAnalyticsResponse {
  final String message;
  final int status;
  final List<YearlyAnalyticsModel> data;

  YearlyAnalyticsResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory YearlyAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return YearlyAnalyticsResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data: dataList
          .map((item) => YearlyAnalyticsModel.fromJson(item))
          .toList(),
    );
  }
}

class CompareAnalyticsResponse {
  final String message;
  final int status;
  final CompareAnalyticsModel data;

  CompareAnalyticsResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory CompareAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return CompareAnalyticsResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data: CompareAnalyticsModel.fromJson(json['data'] ?? {}),
    );
  }
}
