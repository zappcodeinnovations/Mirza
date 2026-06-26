class StockKpiModel {
  final int bu3001Total;
  final int bu3004Total;
  final int bu3006Total;
  final int allStock;
  final String asOnDate;

  StockKpiModel({
    required this.bu3001Total,
    required this.bu3004Total,
    required this.bu3006Total,
    required this.allStock,
    required this.asOnDate,
  });

  factory StockKpiModel.fromJson(Map<String, dynamic> json) {
    return StockKpiModel(
      bu3001Total: json['bu_3001_total'] as int? ?? 0,
      bu3004Total: json['bu_3004_total'] as int? ?? 0,
      bu3006Total: json['bu_3006_total'] as int? ?? 0,
      allStock: json['all_stock'] as int? ?? 0,
      asOnDate: json['as_on_date']?.toString() ?? '',
    );
  }
}

class StockRecordModel {
  final int srNo;
  final int id;
  final String itemCode;
  final String productName;
  final String brand;
  final String businessUnit1;
  final int qty1;
  final String businessUnit2;
  final int qty2;
  final String businessUnit3;
  final int qty3;
  final int totalQty;
  final String asOnDate;

  StockRecordModel({
    required this.srNo,
    required this.id,
    required this.itemCode,
    required this.productName,
    required this.brand,
    required this.businessUnit1,
    required this.qty1,
    required this.businessUnit2,
    required this.qty2,
    required this.businessUnit3,
    required this.qty3,
    required this.totalQty,
    required this.asOnDate,
  });

  factory StockRecordModel.fromJson(Map<String, dynamic> json) {
    return StockRecordModel(
      srNo: json['sr_no'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      itemCode: json['item_code']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      businessUnit1: json['business_unit_1']?.toString() ?? '',
      qty1: json['qty_1'] as int? ?? 0,
      businessUnit2: json['business_unit_2']?.toString() ?? '',
      qty2: json['qty_2'] as int? ?? 0,
      businessUnit3: json['business_unit_3']?.toString() ?? '',
      qty3: json['qty_3'] as int? ?? 0,
      totalQty: json['total_qty'] as int? ?? 0,
      asOnDate: json['as_on_date']?.toString() ?? '',
    );
  }
}

class StockPaginationModel {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  StockPaginationModel({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory StockPaginationModel.fromJson(Map<String, dynamic> json) {
    return StockPaginationModel(
      totalRecords: json['total_records'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 30,
    );
  }
}

class StockFilterOptionsModel {
  final bool success;
  final List<String> brands;
  final List<String> businessUnits;

  StockFilterOptionsModel({
    required this.success,
    required this.brands,
    required this.businessUnits,
  });

  factory StockFilterOptionsModel.fromJson(Map<String, dynamic> json) {
    return StockFilterOptionsModel(
      success: json['success'] == true,
      brands: (json['brands'] as List?)?.map((e) => e.toString()).toList() ?? [],
      businessUnits: (json['business_units'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class StockResponseModel {
  final bool success;
  final StockKpiModel? kpis;
  final List<StockRecordModel> records;
  final StockPaginationModel pagination;

  StockResponseModel({
    required this.success,
    this.kpis,
    required this.records,
    required this.pagination,
  });

  factory StockResponseModel.fromJson(Map<String, dynamic> json) {
    return StockResponseModel(
      success: json['success'] == true,
      kpis: json['kpis'] != null ? StockKpiModel.fromJson(json['kpis']) : null,
      records: (json['records'] as List?)?.map((e) => StockRecordModel.fromJson(e)).toList() ?? [],
      pagination: json['pagination'] != null 
          ? StockPaginationModel.fromJson(json['pagination']) 
          : StockPaginationModel(totalRecords: 0, totalPages: 1, currentPage: 1, pageSize: 30),
    );
  }
}
