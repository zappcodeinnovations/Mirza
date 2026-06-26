class NewLaunchDashboardModel {
  final NewLaunchKpis kpis;
  final List<NewLaunchProduct> products;

  const NewLaunchDashboardModel({
    required this.kpis,
    required this.products,
  });

  factory NewLaunchDashboardModel.fromJson(Map<String, dynamic> json) {
    final productsList =
        (json['products'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(NewLaunchProduct.fromJson)
            .toList() ??
        const <NewLaunchProduct>[];

    return NewLaunchDashboardModel(
      kpis: NewLaunchKpis.fromJson(json['kpis'] as Map<String, dynamic>?),
      products: productsList,
    );
  }
}

class NewLaunchKpis {
  final int totalNewLaunches;
  final int withSalesData;
  final int zeroSales;
  final int totalUnitsSold;
  final String latestLaunchDate;
  final int availableStock;
  final double stockRetailValue;
  final int avgDaysLive;
  final TopSeller? topSeller;

  const NewLaunchKpis({
    required this.totalNewLaunches,
    required this.withSalesData,
    required this.zeroSales,
    required this.totalUnitsSold,
    required this.latestLaunchDate,
    required this.availableStock,
    required this.stockRetailValue,
    required this.avgDaysLive,
    this.topSeller,
  });

  factory NewLaunchKpis.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NewLaunchKpis(
        totalNewLaunches: 0,
        withSalesData: 0,
        zeroSales: 0,
        totalUnitsSold: 0,
        latestLaunchDate: '',
        availableStock: 0,
        stockRetailValue: 0.0,
        avgDaysLive: 0,
        topSeller: null,
      );
    }

    return NewLaunchKpis(
      totalNewLaunches: (json['total_new_launches'] as num?)?.toInt() ?? 0,
      withSalesData: (json['with_sales_data'] as num?)?.toInt() ?? 0,
      zeroSales: (json['zero_sales'] as num?)?.toInt() ?? 0,
      totalUnitsSold: (json['total_units_sold'] as num?)?.toInt() ?? 0,
      latestLaunchDate: json['latest_launch_date']?.toString() ?? '',
      availableStock: (json['available_stock'] as num?)?.toInt() ?? 0,
      stockRetailValue: (json['stock_retail_value'] as num?)?.toDouble() ?? 0.0,
      avgDaysLive: (json['avg_days_live'] as num?)?.toInt() ?? 0,
      topSeller: json['top_seller'] != null
          ? TopSeller.fromJson(json['top_seller'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TopSeller {
  final String skuCode;
  final String skuName;
  final int unitsSold;

  const TopSeller({
    required this.skuCode,
    required this.skuName,
    required this.unitsSold,
  });

  factory TopSeller.fromJson(Map<String, dynamic> json) {
    return TopSeller(
      skuCode: json['sku_code']?.toString() ?? '',
      skuName: json['sku_name']?.toString() ?? '',
      unitsSold: (json['units_sold'] as num?)?.toInt() ?? 0,
    );
  }
}

class NewLaunchProduct {
  final String skuCode;
  final String skuName;
  final String brand;
  final String category;
  final String gender;
  final String launchDate;
  final int daysSince;
  final int unitsSold;
  final double grossRevenue;
  final int returns;
  final double avgWeekly;
  final int stock;
  final double retailPrice;
  final int forecastUnits;
  final double woc;
  final int requiredStock;
  final bool hasSales;
  final String imageUrl;
  final int productPk;

  const NewLaunchProduct({
    required this.skuCode,
    required this.skuName,
    required this.brand,
    required this.category,
    required this.gender,
    required this.launchDate,
    required this.daysSince,
    required this.unitsSold,
    required this.grossRevenue,
    required this.returns,
    required this.avgWeekly,
    required this.stock,
    required this.retailPrice,
    required this.forecastUnits,
    required this.woc,
    required this.requiredStock,
    required this.hasSales,
    required this.imageUrl,
    required this.productPk,
  });

  factory NewLaunchProduct.fromJson(Map<String, dynamic> json) {
    return NewLaunchProduct(
      skuCode: json['sku_code']?.toString() ?? '',
      skuName: json['sku_name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      launchDate: json['launch_date']?.toString() ?? '',
      daysSince: (json['days_since'] as num?)?.toInt() ?? 0,
      unitsSold: (json['units_sold'] as num?)?.toInt() ?? 0,
      grossRevenue: (json['gross_revenue'] as num?)?.toDouble() ?? 0.0,
      returns: (json['returns'] as num?)?.toInt() ?? 0,
      avgWeekly: (json['avg_weekly'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      retailPrice: (json['retail_price'] as num?)?.toDouble() ?? 0.0,
      forecastUnits: (json['forecast_units'] as num?)?.toInt() ?? 0,
      woc: (json['woc'] as num?)?.toDouble() ?? 0.0,
      requiredStock: (json['required_stock'] as num?)?.toInt() ?? 0,
      hasSales: json['has_sales'] == true,
      imageUrl: json['image_url']?.toString() ?? '',
      productPk: (json['product_pk'] as num?)?.toInt() ?? 0,
    );
  }
}

class NewLaunchProductDetailsModel {
  final bool success;
  final NewLaunchDetailProduct product;
  final NewLaunchDetailForecast forecast;
  final NewLaunchDetailMetrics unitsSold;
  final NewLaunchDetailMetrics avgWeekly;
  final NewLaunchDetailMetrics revenue;
  final NewLaunchDetailStock stock;
  final NewLaunchDetailReturns returns;

  const NewLaunchProductDetailsModel({
    required this.success,
    required this.product,
    required this.forecast,
    required this.unitsSold,
    required this.avgWeekly,
    required this.revenue,
    required this.stock,
    required this.returns,
  });

  factory NewLaunchProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return NewLaunchProductDetailsModel(
      success: json['success'] ?? false,
      product: NewLaunchDetailProduct.fromJson(json['product'] ?? {}),
      forecast: NewLaunchDetailForecast.fromJson(json['forecast'] ?? {}),
      unitsSold: NewLaunchDetailMetrics.fromJson(json['units_sold'] ?? {}),
      avgWeekly: NewLaunchDetailMetrics.fromJson(json['avg_weekly'] ?? {}),
      revenue: NewLaunchDetailMetrics.fromJson(json['revenue'] ?? {}),
      stock: NewLaunchDetailStock.fromJson(json['stock'] ?? {}),
      returns: NewLaunchDetailReturns.fromJson(json['returns'] ?? {}),
    );
  }
}

class NewLaunchDetailProduct {
  final int id;
  final String skuCode;
  final String skuName;
  final String brand;
  final String category;
  final String gender;
  final String material;
  final String heelType;
  final String heelHeight;
  final String toeType;
  final String productType;
  final String sizeRange;
  final String retailPrice;
  final String launchDate;
  final int daysSince;
  final String imageUrl;
  final String productUrl;

  const NewLaunchDetailProduct({
    required this.id,
    required this.skuCode,
    required this.skuName,
    required this.brand,
    required this.category,
    required this.gender,
    required this.material,
    required this.heelType,
    required this.heelHeight,
    required this.toeType,
    required this.productType,
    required this.sizeRange,
    required this.retailPrice,
    required this.launchDate,
    required this.daysSince,
    required this.imageUrl,
    required this.productUrl,
  });

  factory NewLaunchDetailProduct.fromJson(Map<String, dynamic> json) {
    return NewLaunchDetailProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      skuCode: json['sku_code']?.toString() ?? '',
      skuName: json['sku_name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      heelType: json['heel_type']?.toString() ?? '',
      heelHeight: json['heel_height']?.toString() ?? '',
      toeType: json['toe_type']?.toString() ?? '',
      productType: json['product_type']?.toString() ?? '',
      sizeRange: json['size_range']?.toString() ?? '',
      retailPrice: json['retail_price']?.toString() ?? '',
      launchDate: json['launch_date']?.toString() ?? '',
      daysSince: (json['days_since'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      productUrl: json['product_url']?.toString() ?? '',
    );
  }
}

class NewLaunchDetailForecast {
  final int forecastUnits;
  final double expectedRevenue;
  final int orderRecommendation;
  final double avgWeeklyForecast;
  final int horizonWeeks;
  final String lastUpdated;

  const NewLaunchDetailForecast({
    required this.forecastUnits,
    required this.expectedRevenue,
    required this.orderRecommendation,
    required this.avgWeeklyForecast,
    required this.horizonWeeks,
    required this.lastUpdated,
  });

  factory NewLaunchDetailForecast.fromJson(Map<String, dynamic> json) {
    return NewLaunchDetailForecast(
      forecastUnits: (json['forecast_units'] as num?)?.toInt() ?? 0,
      expectedRevenue: (json['expected_revenue'] as num?)?.toDouble() ?? 0.0,
      orderRecommendation: (json['order_recommendation'] as num?)?.toInt() ?? 0,
      avgWeeklyForecast: (json['avg_weekly_forecast'] as num?)?.toDouble() ?? 0.0,
      horizonWeeks: (json['horizon_weeks'] as num?)?.toInt() ?? 0,
      lastUpdated: json['last_updated']?.toString() ?? '',
    );
  }
}

class NewLaunchDetailMetrics {
  final num w4;
  final num w8;
  final num w12;
  final num all;

  const NewLaunchDetailMetrics({
    required this.w4,
    required this.w8,
    required this.w12,
    required this.all,
  });

  factory NewLaunchDetailMetrics.fromJson(Map<String, dynamic> json) {
    return NewLaunchDetailMetrics(
      w4: json['4w'] as num? ?? 0,
      w8: json['8w'] as num? ?? 0,
      w12: json['12w'] as num? ?? 0,
      all: json['all'] as num? ?? 0,
    );
  }
}

class NewLaunchDetailStock {
  final int total;
  final int bu3001;
  final int bu3004;
  final int bu3006;
  final double woc;
  final String coverageStatus;
  final int requiredStock;

  const NewLaunchDetailStock({
    required this.total,
    required this.bu3001,
    required this.bu3004,
    required this.bu3006,
    required this.woc,
    required this.coverageStatus,
    required this.requiredStock,
  });

  factory NewLaunchDetailStock.fromJson(Map<String, dynamic> json) {
    return NewLaunchDetailStock(
      total: (json['total'] as num?)?.toInt() ?? 0,
      bu3001: (json['bu_3001'] as num?)?.toInt() ?? 0,
      bu3004: (json['bu_3004'] as num?)?.toInt() ?? 0,
      bu3006: (json['bu_3006'] as num?)?.toInt() ?? 0,
      woc: (json['woc'] as num?)?.toDouble() ?? 0.0,
      coverageStatus: json['coverage_status']?.toString() ?? '',
      requiredStock: (json['required_stock'] as num?)?.toInt() ?? 0,
    );
  }
}

class NewLaunchDetailReturns {
  final int totalUnits;
  final double returnRate;

  const NewLaunchDetailReturns({
    required this.totalUnits,
    required this.returnRate,
  });

  factory NewLaunchDetailReturns.fromJson(Map<String, dynamic> json) {
    return NewLaunchDetailReturns(
      totalUnits: (json['total_units'] as num?)?.toInt() ?? 0,
      returnRate: (json['return_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
