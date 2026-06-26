class ProductAnalyticsModel {
  final bool success;
  final String skuCode;
  final ProductAnalyticsKpi? kpis;
  final List<WeeklySalesData> weeklySales;
  final List<MonthlySummaryData> monthlySummary;
  final List<WeeklyStockData> weeklyStock;
  final StockStatusData? stockStatus;
  final List<SeasonSalesData> seasonSales;
  final List<MonthlySalesData> monthlySales;
  final List<CitySalesData> citySales;
  final List<WeeklyReturnsData> weeklyReturns;

  ProductAnalyticsModel({
    required this.success,
    required this.skuCode,
    this.kpis,
    this.weeklySales = const [],
    this.monthlySummary = const [],
    this.weeklyStock = const [],
    this.stockStatus,
    this.seasonSales = const [],
    this.monthlySales = const [],
    this.citySales = const [],
    this.weeklyReturns = const [],
  });

  factory ProductAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return ProductAnalyticsModel(
      success: json['success'] == true,
      skuCode: json['sku_code']?.toString() ?? '',
      kpis: json['kpis'] != null ? ProductAnalyticsKpi.fromJson(json['kpis']) : null,
      weeklySales: (json['weekly_sales'] as List?)?.map((e) => WeeklySalesData.fromJson(e)).toList() ?? [],
      monthlySummary: (json['monthly_summary'] as List?)?.map((e) => MonthlySummaryData.fromJson(e)).toList() ?? [],
      weeklyStock: (json['weekly_stock'] as List?)?.map((e) => WeeklyStockData.fromJson(e)).toList() ?? [],
      stockStatus: json['stock_status'] != null ? StockStatusData.fromJson(json['stock_status']) : null,
      seasonSales: (json['season_sales'] as List?)?.map((e) => SeasonSalesData.fromJson(e)).toList() ?? [],
      monthlySales: (json['monthly_sales'] as List?)?.map((e) => MonthlySalesData.fromJson(e)).toList() ?? [],
      citySales: (json['city_sales'] as List?)?.map((e) => CitySalesData.fromJson(e)).toList() ?? [],
      weeklyReturns: (json['weekly_returns'] as List?)?.map((e) => WeeklyReturnsData.fromJson(e)).toList() ?? [],
    );
  }
}

class ProductAnalyticsKpi {
  final String launchDate;
  final int totalSold;
  final double totalRevenue;
  final int numWeeks;
  final double avgWeeklySales;
  final int totalReturns;
  final double amountLost;

  ProductAnalyticsKpi({
    this.launchDate = '',
    this.totalSold = 0,
    this.totalRevenue = 0.0,
    this.numWeeks = 0,
    this.avgWeeklySales = 0.0,
    this.totalReturns = 0,
    this.amountLost = 0.0,
  });

  factory ProductAnalyticsKpi.fromJson(Map<String, dynamic> json) {
    return ProductAnalyticsKpi(
      launchDate: json['launch_date']?.toString() ?? '',
      totalSold: (json['total_sold'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      numWeeks: (json['num_weeks'] as num?)?.toInt() ?? 0,
      avgWeeklySales: (json['avg_weekly_sales'] as num?)?.toDouble() ?? 0.0,
      totalReturns: (json['total_returns'] as num?)?.toInt() ?? 0,
      amountLost: (json['amount_lost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WeeklySalesData {
  final String week;
  final int qty;
  final double revenue;

  WeeklySalesData({required this.week, required this.qty, required this.revenue});

  factory WeeklySalesData.fromJson(Map<String, dynamic> json) {
    return WeeklySalesData(
      week: json['week']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MonthlySummaryData {
  final String label;
  final int year;
  final int month;
  final int qty;
  final double revenue;
  final int returns;
  final double returnRate;

  MonthlySummaryData({
    required this.label,
    required this.year,
    required this.month,
    required this.qty,
    required this.revenue,
    required this.returns,
    required this.returnRate,
  });

  factory MonthlySummaryData.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryData(
      label: json['label']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      returns: (json['returns'] as num?)?.toInt() ?? 0,
      returnRate: (json['return_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WeeklyStockData {
  final String week;
  final double remainingStock;
  final int soldQty;

  WeeklyStockData({required this.week, required this.remainingStock, required this.soldQty});

  factory WeeklyStockData.fromJson(Map<String, dynamic> json) {
    return WeeklyStockData(
      week: json['week']?.toString() ?? '',
      remainingStock: (json['remaining_stock'] as num?)?.toDouble() ?? 0.0,
      soldQty: (json['sold_qty'] as num?)?.toInt() ?? 0,
    );
  }
}

class StockStatusData {
  final List<String> labels;
  final List<double> values;
  final String asOnDate;

  StockStatusData({required this.labels, required this.values, required this.asOnDate});

  factory StockStatusData.fromJson(Map<String, dynamic> json) {
    return StockStatusData(
      labels: (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
      values: (json['values'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      asOnDate: json['as_on_date']?.toString() ?? '',
    );
  }
}

class SeasonSalesData {
  final String season;
  final int qty;
  final double revenue;

  SeasonSalesData({required this.season, required this.qty, required this.revenue});

  factory SeasonSalesData.fromJson(Map<String, dynamic> json) {
    return SeasonSalesData(
      season: json['season']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MonthlySalesData {
  final String label;
  final int year;
  final int month;
  final int qty;
  final double revenue;

  MonthlySalesData({required this.label, required this.year, required this.month, required this.qty, required this.revenue});

  factory MonthlySalesData.fromJson(Map<String, dynamic> json) {
    return MonthlySalesData(
      label: json['label']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CitySalesData {
  final String city;
  final int qty;

  CitySalesData({required this.city, required this.qty});

  factory CitySalesData.fromJson(Map<String, dynamic> json) {
    return CitySalesData(
      city: json['city']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
    );
  }
}

class WeeklyReturnsData {
  final String week;
  final int qty;
  final double value;

  WeeklyReturnsData({required this.week, required this.qty, required this.value});

  factory WeeklyReturnsData.fromJson(Map<String, dynamic> json) {
    return WeeklyReturnsData(
      week: json['week']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
