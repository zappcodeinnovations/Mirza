class ProductModel {
  final int id;

  final String skuCode;
  final String shoeStyleColor;
  final String styleName;
  final String color;
  final String brand;
  final String gender;
  final String category;

  final String productType;
  final String material;
  final String occasion;
  final String soleType;
  final String toeType;
  final String heelType;
  final String heelHeight;
  final String closureType;
  final String sizeRange;
  final String additionalFeatures;
  final String styleAttributeA;
  final String styleAttributeB;
  final String styleAttributeC;
  final String styleAttributeD;

  final String launchDate;
  final String cost;
  final String retailPrice;
  final String status;
  final String imageUrl;
  final String productUrl;

  final int grossSold;
  final int returns;
  final int netSold;
  final int totalStock;

  final double weeksCover;
  final StockInfo stock;
  final SalesInfo sales;
  final ForecastInfo forecast;

  ProductModel({
    required this.id,
    required this.skuCode,
    required this.shoeStyleColor,
    required this.styleName,
    required this.color,
    required this.brand,
    required this.gender,
    required this.category,
    required this.productType,
    required this.material,
    required this.occasion,
    required this.soleType,
    required this.toeType,
    required this.heelType,
    required this.heelHeight,
    required this.closureType,
    required this.sizeRange,
    required this.additionalFeatures,
    required this.styleAttributeA,
    required this.styleAttributeB,
    required this.styleAttributeC,
    required this.styleAttributeD,
    required this.launchDate,
    required this.cost,
    required this.retailPrice,
    required this.status,
    required this.imageUrl,
    required this.productUrl,
    required this.grossSold,
    required this.returns,
    required this.netSold,
    required this.totalStock,
    required this.weeksCover,
    required this.stock,
    required this.sales,
    required this.forecast,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final stockJson = json['stock'] as Map<String, dynamic>?;
    final salesJson = json['sales'] as Map<String, dynamic>?;
    final forecastJson = json['forecast'] as Map<String, dynamic>?;

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,

      skuCode: json['sku_code']?.toString() ?? '',

      shoeStyleColor: json['shoe_style_color']?.toString() ?? '',

      styleName:
          json['style_name']?.toString() ?? json['name']?.toString() ?? '',

      color: json['color']?.toString() ?? '',

      brand: json['brand']?.toString() ?? '',

      gender: json['gender']?.toString() ?? '',

      category: json['category']?.toString() ?? '',

      /// NEW
      productType: json['product_type']?.toString() ?? '',

      material: json['material']?.toString() ?? '',

      occasion: json['occasion']?.toString() ?? '',

      soleType: json['sole_type']?.toString() ?? '',

      toeType: json['toe_type']?.toString() ?? '',

      heelType: json['heel_type']?.toString() ?? '',

      heelHeight: json['heel_height']?.toString() ?? '',

      closureType: json['closure_type']?.toString() ?? '',

      sizeRange: json['size_range']?.toString() ?? '',

      additionalFeatures: json['additional_features']?.toString() ?? '',

      styleAttributeA: json['style_attribute_a']?.toString() ?? '',

      styleAttributeB: json['style_attribute_b']?.toString() ?? '',

      styleAttributeC: json['style_attribute_c']?.toString() ?? '',

      styleAttributeD: json['style_attribute_d']?.toString() ?? '',

      /// NEW
      launchDate: json['launch_date']?.toString() ?? '',

      /// NEW
      cost: json['cost']?.toString() ?? '0',

      /// NEW
      retailPrice: json['retail_price']?.toString() ?? '0',

      /// NEW
      status: json['status']?.toString() ?? '',

      /// NEW
      imageUrl: json['image_url']?.toString() ?? '',

      productUrl: json['product_url']?.toString() ?? '',

      grossSold:
          (json['gross_sold'] as num?)?.toInt() ??
          (json['sales_gross'] as num?)?.toInt() ??
          0,

      returns: (json['returns'] as num?)?.toInt() ?? 0,

      netSold: (json['net_sold'] as num?)?.toInt() ?? 0,

      totalStock:
          (json['total_stock'] as num?)?.toInt() ??
          (stockJson?['total'] as num?)?.toInt() ??
          0,

      weeksCover: (json['weeks_cover'] as num?)?.toDouble() ?? 0.0,

      stock: StockInfo.fromJson(stockJson),

      sales: SalesInfo.fromJson(salesJson),

      forecast: ForecastInfo.fromJson(forecastJson),
    );
  }
}

class StockInfo {
  final String asOnDate;
  final int bu3001;
  final int bu3004;
  final int bu3006;
  final int total;

  const StockInfo({
    required this.asOnDate,
    required this.bu3001,
    required this.bu3004,
    required this.bu3006,
    required this.total,
  });

  factory StockInfo.fromJson(Map<String, dynamic>? json) {
    return StockInfo(
      asOnDate: json?['as_on_date']?.toString() ?? '',
      bu3001: (json?['bu_3001'] as num?)?.toInt() ?? 0,
      bu3004: (json?['bu_3004'] as num?)?.toInt() ?? 0,
      bu3006: (json?['bu_3006'] as num?)?.toInt() ?? 0,
      total: (json?['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class SalesInfo {
  final int netSale;
  final double totalRevenue;
  final int totalReturn;
  final double returnRate;
  final List<SalesPlatformInfo> byPlatform;

  const SalesInfo({
    required this.netSale,
    required this.totalRevenue,
    required this.totalReturn,
    required this.returnRate,
    required this.byPlatform,
  });

  factory SalesInfo.fromJson(Map<String, dynamic>? json) {
    final platforms =
        (json?['by_platform'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(SalesPlatformInfo.fromJson)
            .toList() ??
        const <SalesPlatformInfo>[];

    return SalesInfo(
      netSale: (json?['net_sale'] as num?)?.toInt() ?? 0,
      totalRevenue: (json?['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalReturn: (json?['total_return'] as num?)?.toInt() ?? 0,
      returnRate: (json?['return_rate'] as num?)?.toDouble() ?? 0.0,
      byPlatform: platforms,
    );
  }
}

class SalesPlatformInfo {
  final String platform;
  final int units;
  final double revenue;

  const SalesPlatformInfo({
    required this.platform,
    required this.units,
    required this.revenue,
  });

  factory SalesPlatformInfo.fromJson(Map<String, dynamic> json) {
    return SalesPlatformInfo(
      platform: json['platform']?.toString() ?? '',
      units: (json['units'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ForecastInfo {
  final int forecastUnits;
  final int currentStock;
  final int requiredStock;
  final double woc;
  final String lastUpdated;

  const ForecastInfo({
    required this.forecastUnits,
    required this.currentStock,
    required this.requiredStock,
    required this.woc,
    required this.lastUpdated,
  });

  factory ForecastInfo.fromJson(Map<String, dynamic>? json) {
    return ForecastInfo(
      forecastUnits: (json?['forecast_units'] as num?)?.toInt() ?? 0,
      currentStock: (json?['current_stock'] as num?)?.toInt() ?? 0,
      requiredStock: (json?['required_stock'] as num?)?.toInt() ?? 0,
      woc: (json?['woc'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json?['last_updated']?.toString() ?? '',
    );
  }
}
