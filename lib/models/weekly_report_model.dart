class WeeklyReportModel {
  final WeeklyKpisModel kpis;
  final List<BrandPortalTableModel> brandPortalTable;
  final List<Last4WeeksModel> last4Weeks;
  final List<MonthSummaryModel> monthSummary;
  final List<ReturnRateTableModel> returnRateTable;
  final List<String> returnRateMonths;
  final MonthlyComparisonModel monthlyComparison;
  final List<String> monthLabels;

  WeeklyReportModel({
    required this.kpis,
    required this.brandPortalTable,
    required this.last4Weeks,
    required this.monthSummary,
    required this.returnRateTable,
    required this.returnRateMonths,
    required this.monthlyComparison,
    required this.monthLabels,
  });

  factory WeeklyReportModel.fromJson(Map<String, dynamic> json) {
    return WeeklyReportModel(
      kpis: json['kpis'] != null
          ? WeeklyKpisModel.fromJson(json['kpis'])
          : WeeklyKpisModel.empty(),
      brandPortalTable: (json['brand_portal_table'] as List?)
              ?.map((e) => BrandPortalTableModel.fromJson(e))
              .toList() ??
          [],
      last4Weeks: (json['last_4_weeks'] as List?)
              ?.map((e) => Last4WeeksModel.fromJson(e))
              .toList() ??
          [],
      monthSummary: (json['month_summary'] as List?)
              ?.map((e) => MonthSummaryModel.fromJson(e))
              .toList() ??
          [],
      returnRateTable: (json['return_rate_table'] as List?)
              ?.map((e) => ReturnRateTableModel.fromJson(e))
              .toList() ??
          [],
      returnRateMonths: (json['return_rate_months'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      monthlyComparison: json['monthly_comparison'] != null
          ? MonthlyComparisonModel.fromJson(json['monthly_comparison'])
          : MonthlyComparisonModel.empty(),
      monthLabels: (json['month_labels'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class WeeklyKpisModel {
  final String weekLabel;
  final String monthLabel;
  final int othLastWeekGross;
  final int othReturns;
  final int tcLastWeekGross;
  final int tcReturns;
  final double othPctChange;
  final double tcPctChange;

  WeeklyKpisModel({
    required this.weekLabel,
    required this.monthLabel,
    required this.othLastWeekGross,
    required this.othReturns,
    required this.tcLastWeekGross,
    required this.tcReturns,
    required this.othPctChange,
    required this.tcPctChange,
  });

  factory WeeklyKpisModel.fromJson(Map<String, dynamic> json) {
    return WeeklyKpisModel(
      weekLabel: json['week_label']?.toString() ?? '',
      monthLabel: json['month_label']?.toString() ?? '',
      othLastWeekGross: (json['oth_last_week_gross'] as num?)?.toInt() ?? 0,
      othReturns: (json['oth_returns'] as num?)?.toInt() ?? 0,
      tcLastWeekGross: (json['tc_last_week_gross'] as num?)?.toInt() ?? 0,
      tcReturns: (json['tc_returns'] as num?)?.toInt() ?? 0,
      othPctChange: (json['oth_pct_change'] as num?)?.toDouble() ?? 0.0,
      tcPctChange: (json['tc_pct_change'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory WeeklyKpisModel.empty() {
    return WeeklyKpisModel(
      weekLabel: '',
      monthLabel: '',
      othLastWeekGross: 0,
      othReturns: 0,
      tcLastWeekGross: 0,
      tcReturns: 0,
      othPctChange: 0.0,
      tcPctChange: 0.0,
    );
  }
}

class BrandPortalTableModel {
  final String label;
  final int uk;
  final int asosEu;
  final int next;
  final int total;

  BrandPortalTableModel({
    required this.label,
    required this.uk,
    required this.asosEu,
    required this.next,
    required this.total,
  });

  factory BrandPortalTableModel.fromJson(Map<String, dynamic> json) {
    return BrandPortalTableModel(
      label: json['label']?.toString() ?? '',
      uk: (json['UK'] as num?)?.toInt() ?? 0,
      asosEu: (json['ASOS EU'] as num?)?.toInt() ?? 0,
      next: (json['NEXT'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class Last4WeeksModel {
  final String week;
  final int oth;
  final int tc;
  final int total;

  Last4WeeksModel({
    required this.week,
    required this.oth,
    required this.tc,
    required this.total,
  });

  factory Last4WeeksModel.fromJson(Map<String, dynamic> json) {
    return Last4WeeksModel(
      week: json['week']?.toString() ?? '',
      oth: (json['oth'] as num?)?.toInt() ?? 0,
      tc: (json['tc'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class MonthSummaryModel {
  final String brand;
  final int gross;
  final int returns;
  final int net;
  final double returnPct;

  MonthSummaryModel({
    required this.brand,
    required this.gross,
    required this.returns,
    required this.net,
    required this.returnPct,
  });

  factory MonthSummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthSummaryModel(
      brand: json['brand']?.toString() ?? '',
      gross: (json['gross'] as num?)?.toInt() ?? 0,
      returns: (json['returns'] as num?)?.toInt() ?? 0,
      net: (json['net'] as num?)?.toInt() ?? 0,
      returnPct: (json['return_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReturnRateTableModel {
  final String category;
  final Map<String, double> rates;

  ReturnRateTableModel({
    required this.category,
    required this.rates,
  });

  factory ReturnRateTableModel.fromJson(Map<String, dynamic> json) {
    String cat = json['category']?.toString() ?? '';
    Map<String, double> parsedRates = {};
    json.forEach((key, value) {
      if (key != 'category') {
        parsedRates[key] = (value as num?)?.toDouble() ?? 0.0;
      }
    });

    return ReturnRateTableModel(
      category: cat,
      rates: parsedRates,
    );
  }
}

class MonthlyComparisonModel {
  final List<MonthlyComparisonItemModel> oth;
  final List<MonthlyComparisonItemModel> tc;

  MonthlyComparisonModel({
    required this.oth,
    required this.tc,
  });

  factory MonthlyComparisonModel.fromJson(Map<String, dynamic> json) {
    return MonthlyComparisonModel(
      oth: (json['OTH'] as List?)
              ?.map((e) => MonthlyComparisonItemModel.fromJson(e))
              .toList() ??
          [],
      tc: (json['TC'] as List?)
              ?.map((e) => MonthlyComparisonItemModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory MonthlyComparisonModel.empty() {
    return MonthlyComparisonModel(oth: [], tc: []);
  }
}

class MonthlyComparisonItemModel {
  final String month;
  final int current;
  final int previous;

  MonthlyComparisonItemModel({
    required this.month,
    required this.current,
    required this.previous,
  });

  factory MonthlyComparisonItemModel.fromJson(Map<String, dynamic> json) {
    return MonthlyComparisonItemModel(
      month: json['month']?.toString() ?? '',
      current: (json['current'] as num?)?.toInt() ?? 0,
      previous: (json['previous'] as num?)?.toInt() ?? 0,
    );
  }
}
