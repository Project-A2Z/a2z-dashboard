class ProfitModel {
  final int totalOperations;
  final double totalProfit;
  final ExpenseRevenue expenses;
  final ExpenseRevenue revenues;
  final List<MonthlyStatistic> monthlyStatistics;
  final List<YearlyStatistic> yearlyStatistics;

  ProfitModel({
    required this.totalOperations,
    required this.totalProfit,
    required this.expenses,
    required this.revenues,
    required this.monthlyStatistics,
    required this.yearlyStatistics,
  });

  factory ProfitModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ProfitModel(
      totalOperations: (data['totalOperations'] ?? 0).toInt(),
      totalProfit: (data['totalProfit'] ?? 0).toDouble(),
      expenses: ExpenseRevenue.fromJson(data['Expenses'] ?? {}),
      revenues: ExpenseRevenue.fromJson(data['Revenues'] ?? {}),
      monthlyStatistics: (data['monthlyStatistics'] as List?)
              ?.map((e) => MonthlyStatistic.fromJson(e))
              .toList() ??
          [],
      yearlyStatistics: (data['yearlyStatistics'] as List?)
              ?.map((e) => YearlyStatistic.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ExpenseRevenue {
  final int totalCount;
  final double totalAmount;
  final int onlineCount;
  final int cashCount;
  final double onlineAmount;
  final double cashAmount;

  ExpenseRevenue({
    required this.totalCount,
    required this.totalAmount,
    required this.onlineCount,
    required this.cashCount,
    required this.onlineAmount,
    required this.cashAmount,
  });

  factory ExpenseRevenue.fromJson(Map<String, dynamic> json) {
    return ExpenseRevenue(
      totalCount: (json['totalCount'] ?? 0).toInt(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      onlineCount: (json['onlineCount'] ?? 0).toInt(),
      cashCount: (json['cashCount'] ?? 0).toInt(),
      onlineAmount: (json['onlineAmount'] ?? 0).toDouble(),
      cashAmount: (json['cashAmount'] ?? 0).toDouble(),
    );
  }
}

class MonthlyStatistic {
  final double revenues;
  final double expenses;
  final double profit;
  final int year;
  final int month;
  final String monthName;

  MonthlyStatistic({
    required this.revenues,
    required this.expenses,
    required this.profit,
    required this.year,
    required this.month,
    required this.monthName,
  });

  factory MonthlyStatistic.fromJson(Map<String, dynamic> json) {
    return MonthlyStatistic(
      revenues: (json['revenues'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      year: (json['year'] ?? 0).toInt(),
      month: (json['month'] ?? 0).toInt(),
      monthName: json['monthName'] ?? '',
    );
  }
}

class YearlyStatistic {
  final double revenues;
  final double expenses;
  final double profit;
  final int year;

  YearlyStatistic({
    required this.revenues,
    required this.expenses,
    required this.profit,
    required this.year,
  });

  factory YearlyStatistic.fromJson(Map<String, dynamic> json) {
    return YearlyStatistic(
      revenues: (json['revenues'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      year: (json['year'] ?? 0).toInt(),
    );
  }
}
