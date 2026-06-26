class CompetitorModel {
  final int srNo;
  final int id;
  final String name;
  final String website;
  final String notes;
  final String createdBy;
  final String createdAt;

  CompetitorModel({
    required this.srNo,
    required this.id,
    required this.name,
    required this.website,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory CompetitorModel.fromJson(Map<String, dynamic> json) {
    return CompetitorModel(
      srNo: json['sr_no'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class CompetitorPaginationModel {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  CompetitorPaginationModel({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory CompetitorPaginationModel.fromJson(Map<String, dynamic> json) {
    return CompetitorPaginationModel(
      totalRecords: json['total_records'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 30,
    );
  }
}

class CompetitorResponseModel {
  final bool success;
  final List<CompetitorModel> records;
  final CompetitorPaginationModel pagination;

  CompetitorResponseModel({
    required this.success,
    required this.records,
    required this.pagination,
  });

  factory CompetitorResponseModel.fromJson(Map<String, dynamic> json) {
    return CompetitorResponseModel(
      success: json['success'] == true,
      records: (json['records'] as List?)?.map((e) => CompetitorModel.fromJson(e)).toList() ?? [],
      pagination: json['pagination'] != null 
          ? CompetitorPaginationModel.fromJson(json['pagination']) 
          : CompetitorPaginationModel(totalRecords: 0, totalPages: 1, currentPage: 1, pageSize: 30),
    );
  }
}
