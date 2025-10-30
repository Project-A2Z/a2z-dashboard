
class CustomersModel {
  final int totalCustomers;
  

  final List<MonthlyCustomerStatistic> monthlyStatistics;
  final List<YearlyCustomerStatistic> yearlyStatistics;

  CustomersModel({
    required this.totalCustomers,

    required this.monthlyStatistics,
    required this.yearlyStatistics,
  });

  factory CustomersModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return CustomersModel(
      totalCustomers: data['totalCustomers'] ?? 0,
        monthlyStatistics: (data['monthlyStatistics'] as List?)
              ?.map((e) => MonthlyCustomerStatistic.fromJson(e))
              .toList() ??
          [],
      yearlyStatistics: (data['yearlyStatistics'] as List?)
              ?.map((e) => YearlyCustomerStatistic.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MonthlyCustomerStatistic {
  final int count;

  final int year;
  final int month;
  final String monthName;

  MonthlyCustomerStatistic({
    required this.count,

    required this.year,
    required this.month,
    required this.monthName,
  });

  factory MonthlyCustomerStatistic.fromJson(Map<String, dynamic> json) {
    return MonthlyCustomerStatistic(
      count: json['count'] ?? 0,

      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      monthName: json['monthName'] ?? '',
    );
  }
}
class YearlyCustomerStatistic {
  final int count;

  final int year;

  YearlyCustomerStatistic({
    required this.count,

    required this.year,
  });

  factory YearlyCustomerStatistic.fromJson(Map<String, dynamic> json) {
    return YearlyCustomerStatistic(
      count: json['count'] ?? 0,

      year: json['year'] ?? 0,
    );
  }
}

