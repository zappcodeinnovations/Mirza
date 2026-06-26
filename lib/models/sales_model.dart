class SalesKpiModel {
  final int totalOrders;
  final double totalRevenue;
  final int totalVolume;
  final int distinctOrders;
  final String topSku;
  final String topCity;
  final String topPlatform;

  SalesKpiModel({
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalVolume,
    required this.distinctOrders,
    required this.topSku,
    required this.topCity,
    required this.topPlatform,
  });

  factory SalesKpiModel.fromJson(Map<String, dynamic> json) {
    return SalesKpiModel(
      totalOrders: json['total_orders'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalVolume: json['total_volume'] as int? ?? 0,
      distinctOrders: json['distinct_orders'] as int? ?? 0,
      topSku: json['top_sku']?.toString() ?? '',
      topCity: json['top_city']?.toString() ?? '',
      topPlatform: json['top_platform']?.toString() ?? '',
    );
  }
}

class SalesRecordModel {
  final int srNo;
  final int id;
  final String orderDate;
  final String orderId;
  final String platform;
  final String skuCode;
  final String skuName;
  final String colour;
  final String size;
  final int quantity;
  final double totalAmount;
  final String brand;
  final String city;

  SalesRecordModel({
    required this.srNo,
    required this.id,
    required this.orderDate,
    required this.orderId,
    required this.platform,
    required this.skuCode,
    required this.skuName,
    required this.colour,
    required this.size,
    required this.quantity,
    required this.totalAmount,
    required this.brand,
    required this.city,
  });

  factory SalesRecordModel.fromJson(Map<String, dynamic> json) {
    return SalesRecordModel(
      srNo: json['sr_no'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      orderDate: json['order_date']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      skuCode: json['sku_code']?.toString() ?? '',
      skuName: json['sku_name']?.toString() ?? '',
      colour: json['colour']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      brand: json['brand']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
    );
  }
}

class SalesPaginationModel {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  SalesPaginationModel({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory SalesPaginationModel.fromJson(Map<String, dynamic> json) {
    return SalesPaginationModel(
      totalRecords: json['total_records'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 30,
    );
  }
}

class SalesResponseModel {
  final bool success;
  final SalesKpiModel? kpis;
  final List<SalesRecordModel> records;
  final SalesPaginationModel pagination;

  SalesResponseModel({
    required this.success,
    this.kpis,
    required this.records,
    required this.pagination,
  });

  factory SalesResponseModel.fromJson(Map<String, dynamic> json) {
    return SalesResponseModel(
      success: json['success'] == true,
      kpis: json['kpis'] != null ? SalesKpiModel.fromJson(json['kpis']) : null,
      records: (json['records'] as List?)?.map((e) => SalesRecordModel.fromJson(e)).toList() ?? [],
      pagination: json['pagination'] != null 
          ? SalesPaginationModel.fromJson(json['pagination']) 
          : SalesPaginationModel(totalRecords: 0, totalPages: 1, currentPage: 1, pageSize: 30),
    );
  }
}

class SalesFilterOptionsModel {
  final bool success;
  final List<String> platforms;
  final List<String> brands;

  SalesFilterOptionsModel({
    required this.success,
    required this.platforms,
    required this.brands,
  });

  factory SalesFilterOptionsModel.fromJson(Map<String, dynamic> json) {
    return SalesFilterOptionsModel(
      success: json['success'] == true,
      platforms: (json['platforms'] as List?)?.map((e) => e.toString()).toList() ?? [],
      brands: (json['brands'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
