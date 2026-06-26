class WeeklySalesKpiModel {
  final double totalReturn;
  final double netSale;
  final int totalRecords;

  WeeklySalesKpiModel({
    required this.totalReturn,
    required this.netSale,
    required this.totalRecords,
  });

  factory WeeklySalesKpiModel.fromJson(Map<String, dynamic> json) {
    return WeeklySalesKpiModel(
      totalReturn: (json['total_return'] as num?)?.toDouble() ?? 0.0,
      netSale: (json['net_sale'] as num?)?.toDouble() ?? 0.0,
      totalRecords: json['total_records'] as int? ?? 0,
    );
  }
}

class WeeklySalesRecordModel {
  final int srNo;
  final int id;
  final String skuCode;
  final String weekStartDate;
  final double totalReturn;
  final double netSale;
  final String financialYear;
  final String upload;

  WeeklySalesRecordModel({
    required this.srNo,
    required this.id,
    required this.skuCode,
    required this.weekStartDate,
    required this.totalReturn,
    required this.netSale,
    required this.financialYear,
    required this.upload,
  });

  factory WeeklySalesRecordModel.fromJson(Map<String, dynamic> json) {
    return WeeklySalesRecordModel(
      srNo: json['sr_no'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      skuCode: json['sku_code']?.toString() ?? '',
      weekStartDate: json['week_start_date']?.toString() ?? '',
      totalReturn: (json['total_return'] as num?)?.toDouble() ?? 0.0,
      netSale: (json['net_sale'] as num?)?.toDouble() ?? 0.0,
      financialYear: json['financial_year']?.toString() ?? '',
      upload: json['upload']?.toString() ?? '',
    );
  }
}

class WeeklySalesPaginationModel {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  WeeklySalesPaginationModel({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory WeeklySalesPaginationModel.fromJson(Map<String, dynamic> json) {
    return WeeklySalesPaginationModel(
      totalRecords: json['total_records'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 30,
    );
  }
}

class WeeklySalesFilterOptionsModel {
  final bool success;
  final List<String> financialYears;

  WeeklySalesFilterOptionsModel({
    required this.success,
    required this.financialYears,
  });

  factory WeeklySalesFilterOptionsModel.fromJson(Map<String, dynamic> json) {
    return WeeklySalesFilterOptionsModel(
      success: json['success'] == true,
      financialYears: (json['financial_years'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class WeeklySalesResponseModel {
  final bool success;
  final WeeklySalesKpiModel? kpis;
  final List<WeeklySalesRecordModel> records;
  final WeeklySalesPaginationModel pagination;

  WeeklySalesResponseModel({
    required this.success,
    this.kpis,
    required this.records,
    required this.pagination,
  });

  factory WeeklySalesResponseModel.fromJson(Map<String, dynamic> json) {
    return WeeklySalesResponseModel(
      success: json['success'] == true,
      kpis: json['kpis'] != null ? WeeklySalesKpiModel.fromJson(json['kpis']) : null,
      records: (json['records'] as List?)?.map((e) => WeeklySalesRecordModel.fromJson(e)).toList() ?? [],
      pagination: json['pagination'] != null 
          ? WeeklySalesPaginationModel.fromJson(json['pagination']) 
          : WeeklySalesPaginationModel(totalRecords: 0, totalPages: 1, currentPage: 1, pageSize: 30),
    );
  }
}
