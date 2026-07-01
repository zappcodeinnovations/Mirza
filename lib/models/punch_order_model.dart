class PunchOrderModel {
  final int id;
  final String skuCode;
  final String skuName;
  final int quantity;
  final String reason;
  final int? punchedBy;
  final String punchedByName;
  final DateTime? punchedAt;
  final int? forecastUnits;
  final int? recommendedQty;
  final int? currentStock;
  final int? difference;
  final String? category;
  final String? gender;
  final String? brandName;
  final String? productType;
  final String? material;
  final String? color;
  final String? retailPrice;
  final String? forecastReason;
  final String? differenceReason;

  PunchOrderModel({
    required this.id,
    required this.skuCode,
    required this.skuName,
    required this.quantity,
    required this.reason,
    this.punchedBy,
    required this.punchedByName,
    this.punchedAt,
    this.forecastUnits,
    this.recommendedQty,
    this.currentStock,
    this.difference,
    this.category,
    this.gender,
    this.brandName,
    this.productType,
    this.material,
    this.color,
    this.retailPrice,
    this.forecastReason,
    this.differenceReason,
  });

  factory PunchOrderModel.fromJson(Map<String, dynamic> json) {
    return PunchOrderModel(
      id: json['id'] ?? 0,
      skuCode: json['sku_code'] ?? '',
      skuName: json['sku_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      reason: json['reason'] ?? '',
      punchedBy: json['punched_by'],
      punchedByName: json['punched_by_name'] ?? '',
      punchedAt: json['punched_at'] != null ? DateTime.tryParse(json['punched_at']) : null,
      forecastUnits: json['forecast_units'],
      recommendedQty: json['recommended_qty'],
      currentStock: json['current_stock'],
      difference: json['difference'],
      category: json['category'],
      gender: json['gender'],
      brandName: json['brand_name'],
      productType: json['product_type'],
      material: json['material'],
      color: json['color'],
      retailPrice: json['retail_price']?.toString(),
      forecastReason: json['forecast_reason'],
      differenceReason: json['difference_reason'],
    );
  }
}

class PunchOrderAnalysisModel {
  final int forecastUnits;
  final int recommendedQty;
  final int currentStock;
  final int difference;
  final String statusType;
  final String forecastReason;
  final String differenceReason;

  PunchOrderAnalysisModel({
    required this.forecastUnits,
    required this.recommendedQty,
    required this.currentStock,
    required this.difference,
    required this.statusType,
    required this.forecastReason,
    required this.differenceReason,
  });

  factory PunchOrderAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PunchOrderAnalysisModel(
      forecastUnits: json['forecast_units'] ?? 0,
      recommendedQty: json['recommended_qty'] ?? 0,
      currentStock: json['current_stock'] ?? 0,
      difference: json['difference'] ?? 0,
      statusType: json['status_type'] ?? '',
      forecastReason: json['forecast_reason'] ?? '',
      differenceReason: json['difference_reason'] ?? '',
    );
  }
}

class PunchOrderCreateResponseModel {
  final bool success;
  final String message;
  final PunchOrderModel? order;
  final PunchOrderAnalysisModel? analysis;

  PunchOrderCreateResponseModel({
    required this.success,
    required this.message,
    this.order,
    this.analysis,
  });

  factory PunchOrderCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return PunchOrderCreateResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      order: json['order'] != null ? PunchOrderModel.fromJson(json['order']) : null,
      analysis: json['analysis'] != null ? PunchOrderAnalysisModel.fromJson(json['analysis']) : null,
    );
  }
}

class PunchOrderHistoryResponseModel {
  final bool success;
  final List<PunchOrderModel> orders;

  PunchOrderHistoryResponseModel({
    required this.success,
    required this.orders,
  });

  factory PunchOrderHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return PunchOrderHistoryResponseModel(
      success: json['success'] ?? false,
      orders: json['orders'] != null
          ? List<PunchOrderModel>.from(json['orders'].map((x) => PunchOrderModel.fromJson(x)))
          : [],
    );
  }
}

class PunchOrderOptionsResponseModel {
  final bool success;
  final List<String> predefinedReasons;

  PunchOrderOptionsResponseModel({
    required this.success,
    required this.predefinedReasons,
  });

  factory PunchOrderOptionsResponseModel.fromJson(Map<String, dynamic> json) {
    return PunchOrderOptionsResponseModel(
      success: json['success'] ?? false,
      predefinedReasons: json['predefined_reasons'] != null
          ? List<String>.from(json['predefined_reasons'])
          : [],
    );
  }
}
