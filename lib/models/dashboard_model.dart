class DashboardResponseModel {
  final DashboardKpiModel? kpis;
  final DashboardFiltersModel? filters;

  final List<String> autoInsights;

  final List<DashboardTopProductModel> topProducts;

  final DashboardChartModel? styleMix;
  final DashboardChartModel? colorMix;
  final DashboardChartModel? materialMix;

  final DashboardChartModel? returnAnalysis;
  final DashboardChartModel? seasonalTop;
  final DashboardCityProductsModel? cityProducts;

  DashboardResponseModel({
    required this.kpis,
    required this.filters,
    required this.autoInsights,
    required this.topProducts,
    required this.styleMix,
    required this.colorMix,
    required this.materialMix,
    required this.returnAnalysis,
    required this.seasonalTop,
    required this.cityProducts,
  });

  factory DashboardResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardResponseModel(
      kpis: json['kpis'] != null
          ? DashboardKpiModel.fromJson(
              json['kpis'],
            )
          : null,

      filters: DashboardFiltersModel.fromJson(
        json,
      ),

      autoInsights: List<String>.from(
        json['auto_insights'] ?? [],
      ),

      topProducts:
          (json['top_products'] as List<dynamic>? ??
                  [])
              .map(
                (e) =>
                    DashboardTopProductModel.fromJson(
                  e,
                ),
              )
              .toList(),

      styleMix: json['style_mix'] != null
          ? DashboardChartModel.fromJson(
              json['style_mix'],
            )
          : null,

      colorMix: json['color_mix'] != null
          ? DashboardChartModel.fromJson(
              json['color_mix'],
            )
          : null,

      materialMix: json['material_mix'] != null
          ? DashboardChartModel.fromJson(
              json['material_mix'],
            )
          : null,

      returnAnalysis:
          json['return_analysis'] != null
              ? DashboardChartModel.fromJson(
                  json['return_analysis'],
                )
              : null,

      seasonalTop:
          json['seasonal_top'] != null
              ? DashboardChartModel.fromJson(
                  json['seasonal_top'],
                )
              : null,

      cityProducts:
          json['city_products'] != null
              ? DashboardCityProductsModel.fromJson(
                  json['city_products'],
                )
              : null,
    );
  }
}

/// =================================================
/// KPI MODEL
/// =================================================

class DashboardKpiModel {
  final int grossUnits;
  final double grossRevenue;
  final double asp;
  final double returnRate;
  final double sellThrough;
  final double weeksCover;

  final int netUnits;
  final int activeProducts;
  final int competitors;

  final int totalOrders;
  final int netReturns;
  final int brands;

  DashboardKpiModel({
    required this.grossUnits,
    required this.grossRevenue,
    required this.asp,
    required this.returnRate,
    required this.sellThrough,
    required this.weeksCover,
    required this.netUnits,
    required this.activeProducts,
    required this.competitors,
    required this.totalOrders,
    required this.netReturns,
    required this.brands,
  });

  factory DashboardKpiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardKpiModel(
      grossUnits:
          (json['gross_units'] as num?)?.toInt() ?? 0,

      grossRevenue:
          (json['gross_revenue'] as num?)
                  ?.toDouble() ??
              0.0,

      asp:
          (json['asp'] as num?)?.toDouble() ?? 0.0,

      returnRate:
          (json['return_rate'] as num?)
                  ?.toDouble() ??
              0.0,

      sellThrough:
          (json['sell_through'] as num?)
                  ?.toDouble() ??
              0.0,

      weeksCover:
          (json['weeks_cover'] as num?)
                  ?.toDouble() ??
              0.0,

      netUnits:
          (json['net_units'] as num?)?.toInt() ??
              0,

      activeProducts:
          (json['active_products'] as num?)
                  ?.toInt() ??
              0,

      competitors:
          (json['competitors'] as num?)
                  ?.toInt() ??
              0,

      totalOrders:
          (json['total_orders'] as num?)
                  ?.toInt() ??
              0,

      netReturns:
          (json['net_returns'] as num?)
                  ?.toInt() ??
              0,

      brands:
          (json['brands'] as num?)?.toInt() ?? 0,
    );
  }
}

/// =================================================
/// TOP PRODUCTS MODEL
/// =================================================

class DashboardTopProductModel {
  final String skuCode;
  final String skuName;
  final String brand;
  final String colour;

  final int units;

  final double revenue;
  final double asp;
  final double returnPct;

  DashboardTopProductModel({
    required this.skuCode,
    required this.skuName,
    required this.brand,
    required this.colour,
    required this.units,
    required this.revenue,
    required this.asp,
    required this.returnPct,
  });

  factory DashboardTopProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardTopProductModel(
      skuCode: json['sku_code'] ?? '',

      skuName: json['sku_name'] ?? '',

      brand: json['brand'] ?? '',

      colour: json['colour'] ?? '',

      units:
          (json['units'] as num?)?.toInt() ?? 0,

      revenue:
          (json['revenue'] as num?)
                  ?.toDouble() ??
              0.0,

      asp:
          (json['asp'] as num?)?.toDouble() ?? 0.0,

      returnPct:
          (json['return_pct'] as num?)
                  ?.toDouble() ??
              0.0,
    );
  }
}

/// =================================================
/// COMMON CHART MODEL
/// =================================================

class DashboardChartModel {
  final List<String> labels;
  final List<double> values;

  DashboardChartModel({
    required this.labels,
    required this.values,
  });

  factory DashboardChartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardChartModel(
      labels: List<String>.from(
        json['labels'] ?? [],
      ),

      values:
          (json['values'] as List<dynamic>? ?? [])
              .map(
                (e) => (e as num).toDouble(),
              )
              .toList(),
    );
  }
}

/// =================================================
/// CITY PRODUCTS MODEL
/// =================================================

class DashboardCityProductsModel {
  final List<String> products;
  final List<double> values;

  DashboardCityProductsModel({
    required this.products,
    required this.values,
  });

  factory DashboardCityProductsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardCityProductsModel(
      products: List<String>.from(
        json['products'] ?? [],
      ),

      values:
          (json['values'] as List<dynamic>? ?? [])
              .map(
                (e) => (e as num).toDouble(),
              )
              .toList(),
    );
  }
}

/// =================================================
/// DATE RANGE MODEL
/// =================================================

class DashboardDateRangeModel {
  final String label;
  final String value;

  DashboardDateRangeModel({
    required this.label,
    required this.value,
  });

  factory DashboardDateRangeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardDateRangeModel(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

/// =================================================
/// SEASON MODEL
/// =================================================

class DashboardSeasonModel {
  final String seasonName;
  final String seasonAlias;

  DashboardSeasonModel({
    required this.seasonName,
    required this.seasonAlias,
  });

  factory DashboardSeasonModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardSeasonModel(
      seasonName: json['season_name'] ?? '',
      seasonAlias: json['season_alias'] ?? '',
    );
  }
}

/// =================================================
/// FILTER MODEL
/// =================================================

class DashboardFiltersModel {
  final List<String> brands;
  final List<String> genders;
  final List<String> platforms;

  final List<String> footwearTypes;
  final List<String> productTypes;
  final List<String> materials;
  final List<String> cities;

  final List<DashboardSeasonModel> seasons;

  final List<DashboardDateRangeModel> dateRanges;

  DashboardFiltersModel({
    required this.brands,
    required this.genders,
    required this.platforms,
    required this.footwearTypes,
    required this.productTypes,
    required this.materials,
    required this.cities,
    required this.seasons,
    required this.dateRanges,
  });

  factory DashboardFiltersModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardFiltersModel(
      brands: List<String>.from(
        json['brands'] ?? [],
      ),

      genders: List<String>.from(
        json['genders'] ?? [],
      ),

      platforms: List<String>.from(
        json['platforms'] ?? [],
      ),

      footwearTypes: List<String>.from(
        json['footwear_types'] ?? [],
      ),

      productTypes: List<String>.from(
        json['product_types'] ?? [],
      ),

      materials: List<String>.from(
        json['materials'] ?? [],
      ),

      cities: List<String>.from(
        json['cities'] ?? [],
      ),

      seasons:
          (json['seasons'] as List<dynamic>? ?? [])
              .map(
                (e) =>
                    DashboardSeasonModel.fromJson(
                  e,
                ),
              )
              .toList(),

      dateRanges:
          (json['date_ranges'] as List<dynamic>? ??
                  [])
              .map(
                (e) =>
                    DashboardDateRangeModel.fromJson(
                  e,
                ),
              )
              .toList(),
    );
  }
}