class ReturnsKpiModel {
  final int totalReturnUnits;
  final int totalReturnOrders;
  final double returnRatePercent;

  ReturnsKpiModel({
    required this.totalReturnUnits,
    required this.totalReturnOrders,
    required this.returnRatePercent,
  });

  factory ReturnsKpiModel.fromJson(Map<String, dynamic> json) {
    return ReturnsKpiModel(
      totalReturnUnits: json['total_return_units'] as int? ?? 0,
      totalReturnOrders: json['total_return_orders'] as int? ?? 0,
      returnRatePercent: (json['return_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ForecastingKpiModel {
  final int forecastedDemand;
  final int inventoryOnHand;
  final int suggestedOrderQty;

  ForecastingKpiModel({
    required this.forecastedDemand,
    required this.inventoryOnHand,
    required this.suggestedOrderQty,
  });

  factory ForecastingKpiModel.fromJson(Map<String, dynamic> json) {
    return ForecastingKpiModel(
      forecastedDemand: json['forecasted_demand'] as int? ?? 0,
      inventoryOnHand: json['inventory_on_hand'] as int? ?? 0,
      suggestedOrderQty: json['suggested_order_qty'] as int? ?? 0,
    );
  }
}

class NewLaunchKpiModel {
  final int totalNewLaunches;
  final int withSalesData;
  final int activeNewLaunches;

  NewLaunchKpiModel({
    required this.totalNewLaunches,
    required this.withSalesData,
    required this.activeNewLaunches,
  });

  factory NewLaunchKpiModel.fromJson(Map<String, dynamic> json) {
    return NewLaunchKpiModel(
      totalNewLaunches: json['total_new_launches'] as int? ?? 0,
      withSalesData: json['with_sales_data'] as int? ?? 0,
      activeNewLaunches: json['active_new_launches'] as int? ?? 0,
    );
  }
}

class MissingProductModel {
  final String skuCode;
  final String skuName;
  final String brand;
  final String gender;
  final int weeks;
  final int netSale;
  final int orders;
  final int unitsSold;
  final double revenue;

  MissingProductModel({
    required this.skuCode,
    required this.skuName,
    required this.brand,
    required this.gender,
    required this.weeks,
    required this.netSale,
    required this.orders,
    required this.unitsSold,
    required this.revenue,
  });

  factory MissingProductModel.fromJson(Map<String, dynamic> json) {
    return MissingProductModel(
      skuCode: json['sku_code']?.toString() ?? '',
      skuName: json['sku_name']?.toString() ?? json['style_name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      weeks: (json['weeks'] as num?)?.toInt() ?? 0,
      netSale: (json['net_sale'] as num?)?.toInt() ?? 0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
      unitsSold: (json['units_sold'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}



class StockStatusKpiModel {
  final int bu3001Total; // Online stock
  final int bu3004Total; // Warehouse stock
  final int bu3006Total; // Other stock
  final int totalQty;

  StockStatusKpiModel({
    required this.bu3001Total,
    required this.bu3004Total,
    required this.bu3006Total,
    required this.totalQty,
  });

  factory StockStatusKpiModel.fromJson(Map<String, dynamic> json) {
    return StockStatusKpiModel(
      bu3001Total: json['bu_3001_total'] as int? ?? json['bu_3001'] as int? ?? 0,
      bu3004Total: json['bu_3004_total'] as int? ?? json['bu_3004'] as int? ?? 0,
      bu3006Total: json['bu_3006_total'] as int? ?? json['bu_3006'] as int? ?? 0,
      totalQty: json['total_qty'] as int? ?? json['total'] as int? ?? 0,
    );
  }
}

class WeeklySalesKpiModel {
  final double totalReturn;
  final double netSale;
  final int totalOrders;

  WeeklySalesKpiModel({
    required this.totalReturn,
    required this.netSale,
    required this.totalOrders,
  });

  factory WeeklySalesKpiModel.fromJson(Map<String, dynamic> json) {
    return WeeklySalesKpiModel(
      totalReturn: (json['total_return'] as num?)?.toDouble() ?? 0.0,
      netSale: (json['net_sale'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
    );
  }
}

class OverallReportModel {
  final String skuCode;
  final String styleName;
  final String color;
  final String brand;
  final String gender;
  final String category;
  final String material;
  final int grossSold;
  final int returns;
  final int netSold;
  final int totalStock;
  final double woc;
  final String status;

  OverallReportModel({
    required this.skuCode,
    required this.styleName,
    required this.color,
    required this.brand,
    required this.gender,
    required this.category,
    required this.material,
    required this.grossSold,
    required this.returns,
    required this.netSold,
    required this.totalStock,
    required this.woc,
    required this.status,
  });

  factory OverallReportModel.fromJson(Map<String, dynamic> json) {
    return OverallReportModel(
      skuCode: json['sku_code']?.toString() ?? '',
      styleName: json['style_name']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      grossSold: num.tryParse(json['gross_sold']?.toString() ?? '')?.toInt() ?? 0,
      returns: num.tryParse(json['returns']?.toString() ?? '')?.toInt() ?? 0,
      netSold: num.tryParse(json['net_sold']?.toString() ?? '')?.toInt() ?? 0,
      totalStock: num.tryParse(json['total_stock']?.toString() ?? '')?.toInt() ?? 0,
      woc: num.tryParse(json['woc']?.toString() ?? '')?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
    );
  }
}

class ForecastReportModel {
  final String skuCode;
  final String styleName;
  final String color;
  final String brand;
  final String gender;
  final String category;
  final String productType;
  final String material;
  final int forecastUnits;
  final int currentStock;
  final int requiredStock;
  final double woc;

  ForecastReportModel({
    required this.skuCode,
    required this.styleName,
    required this.color,
    required this.brand,
    required this.gender,
    required this.category,
    required this.productType,
    required this.material,
    required this.forecastUnits,
    required this.currentStock,
    required this.requiredStock,
    required this.woc,
  });

  factory ForecastReportModel.fromJson(Map<String, dynamic> json) {
    return ForecastReportModel(
      skuCode: json['sku_code']?.toString() ?? '',
      styleName: json['style_name']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      productType: json['product_type']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      forecastUnits: num.tryParse(json['forecast_units']?.toString() ?? '')?.toInt() ?? 0,
      currentStock: num.tryParse(json['current_stock']?.toString() ?? '')?.toInt() ?? 0,
      requiredStock: num.tryParse(json['required_stock']?.toString() ?? '')?.toInt() ?? 0,
      woc: num.tryParse(json['woc']?.toString() ?? '')?.toDouble() ?? 0.0,
    );
  }
}

class OverstockReportModel {
  final String skuCode;
  final String styleName;
  final String color;
  final String brand;
  final String gender;
  final String category;
  final String material;
  final int currentStock;
  final int totalSales;

  OverstockReportModel({
    required this.skuCode,
    required this.styleName,
    required this.color,
    required this.brand,
    required this.gender,
    required this.category,
    required this.material,
    required this.currentStock,
    required this.totalSales,
  });

  factory OverstockReportModel.fromJson(Map<String, dynamic> json) {
    return OverstockReportModel(
      skuCode: json['sku_code']?.toString() ?? '',
      styleName: json['style_name']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      currentStock: num.tryParse(json['current_stock']?.toString() ?? '')?.toInt() ?? 0,
      totalSales: num.tryParse(json['total_sales']?.toString() ?? '')?.toInt() ?? 0,
    );
  }
}
