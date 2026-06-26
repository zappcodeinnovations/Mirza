class ForecastingDashboardModel {
  final ForecastingKpiSummary kpis;
  final List<ForecastingTopProduct> topProducts;
  final String cacheLastUpdated;

  const ForecastingDashboardModel({
    required this.kpis,
    required this.topProducts,
    required this.cacheLastUpdated,
  });

  factory ForecastingDashboardModel.fromJson(Map<String, dynamic> json) {
    final top20 =
        (json['top_20'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(ForecastingTopProduct.fromJson)
            .toList() ??
        const <ForecastingTopProduct>[];

    return ForecastingDashboardModel(
      kpis: ForecastingKpiSummary.fromJson(
        json['kpis'] as Map<String, dynamic>?,
      ),
      topProducts: top20,
      cacheLastUpdated: json['cache_last_updated']?.toString() ?? '',
    );
  }
}

class ForecastingKpiSummary {
  final int forecastedDemand;
  final int inventoryOnHand;
  final int inventoryGap;
  final double weeksOfCover;
  final int skusStockoutRisk;
  final int skusOverstockRisk;
  final double stockLastsWeeks;
  final int horizonWeeks;
  final int totalSkus;

  const ForecastingKpiSummary({
    required this.forecastedDemand,
    required this.inventoryOnHand,
    required this.inventoryGap,
    required this.weeksOfCover,
    required this.skusStockoutRisk,
    required this.skusOverstockRisk,
    required this.stockLastsWeeks,
    required this.horizonWeeks,
    required this.totalSkus,
  });

  factory ForecastingKpiSummary.fromJson(Map<String, dynamic>? json) {
    return ForecastingKpiSummary(
      forecastedDemand: (json?['forecasted_demand'] as num?)?.toInt() ?? 0,
      inventoryOnHand: (json?['inventory_on_hand'] as num?)?.toInt() ?? 0,
      inventoryGap: (json?['inventory_gap'] as num?)?.toInt() ?? 0,
      weeksOfCover: (json?['weeks_of_cover'] as num?)?.toDouble() ?? 0.0,
      skusStockoutRisk: (json?['skus_stockout_risk'] as num?)?.toInt() ?? 0,
      skusOverstockRisk: (json?['skus_overstock_risk'] as num?)?.toInt() ?? 0,
      stockLastsWeeks: (json?['stock_lasts_weeks'] as num?)?.toDouble() ?? 0.0,
      horizonWeeks: (json?['horizon_weeks'] as num?)?.toInt() ?? 0,
      totalSkus: (json?['total_skus'] as num?)?.toInt() ?? 0,
    );
  }
}

class ForecastingTopProduct {
  final int rank;
  final String skuCode;
  final String skuName;
  final String imageUrl;
  final int forecastUnits;
  final int currentStock;
  final double woc;
  final int requiredStock;
  final String reorderWeek;
  final String lastUpdated;

  const ForecastingTopProduct({
    required this.rank,
    required this.skuCode,
    required this.skuName,
    required this.imageUrl,
    required this.forecastUnits,
    required this.currentStock,
    required this.woc,
    required this.requiredStock,
    required this.reorderWeek,
    required this.lastUpdated,
  });

  factory ForecastingTopProduct.fromJson(Map<String, dynamic> json) {
    return ForecastingTopProduct(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      skuCode: json['sku_code']?.toString() ?? '',
      skuName: json['sku_name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      forecastUnits: (json['forecast_units'] as num?)?.toInt() ?? 0,
      currentStock: (json['current_stock'] as num?)?.toInt() ?? 0,
      woc: (json['woc'] as num?)?.toDouble() ?? 0.0,
      requiredStock: (json['required_stock'] as num?)?.toInt() ?? 0,
      reorderWeek: json['reorder_week']?.toString() ?? '',
      lastUpdated: json['last_updated']?.toString() ?? '',
    );
  }
}
