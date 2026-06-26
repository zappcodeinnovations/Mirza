import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/reports_model.dart';
import '../models/product_model.dart';
import '../models/weekly_report_model.dart';

class ReportsService {
  final ApiClient _apiClient = ApiClient();

  // Fetch Returns KPIs
  Future<ReturnsKpiModel?> getReturnsKpis() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.returns, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['kpis'] != null) {
          return ReturnsKpiModel.fromJson(data['kpis']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Fetch Forecasting KPIs
  Future<ForecastingKpiModel?> getForecastingKpis() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.forecasting, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['kpis'] != null) {
          return ForecastingKpiModel.fromJson(data['kpis']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Fetch New Launch KPIs
  Future<NewLaunchKpiModel?> getNewLaunchKpis() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.newLaunch, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['kpis'] != null) {
          return NewLaunchKpiModel.fromJson(data['kpis']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Fetch Missing Products List
  Future<List<MissingProductModel>> getMissingProducts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.missingProducts, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['records'] != null) {
          final List list = data['records'];
          return list.map((e) => MissingProductModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Trigger Download Missing Products Report
  Future<bool> downloadMissingProductsReport({bool isExcel = false}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.missingProductsDownload, requireAuth: true);
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        
        if (isExcel) {
          String csvString = utf8.decode(response.bodyBytes);
          List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
          var excel = Excel.createExcel();
          Sheet sheetObject = excel['Sheet1'];
          for (var row in rowsAsListOfValues) {
            List<CellValue> cellValues = row.map((e) => TextCellValue(e.toString())).toList();
            sheetObject.appendRow(cellValues);
          }
          var fileBytes = excel.save();
          final path = '${directory.path}/missing_products.xlsx';
          final file = File(path);
          await file.writeAsBytes(fileBytes!);
          await Share.shareXFiles([XFile(path)], text: 'Missing Products Report (Excel)');
        } else {
          final path = '${directory.path}/missing_products.csv';
          final file = File(path);
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareXFiles([XFile(path)], text: 'Missing Products Report (CSV)');
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Download exception: $e');
      return false;
    }
  }

  // Fetch Weekly Report Data
  Future<WeeklyReportModel?> getWeeklyReport() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.weeklyReport, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return WeeklyReportModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch weekly report exception: $e');
      return null;
    }
  }

  // Download Weekly Report
  Future<bool> downloadWeeklyReport({bool isExcel = false}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.weeklyReportDownload, requireAuth: true);
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        if (isExcel) {
          String csvString = response.body;
          List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
          var excel = Excel.createExcel();
          Sheet sheetObject = excel['Sheet1'];
          for (var row in rowsAsListOfValues) {
            List<CellValue> cellValues = row.map((e) => TextCellValue(e.toString())).toList();
            sheetObject.appendRow(cellValues);
          }
          var fileBytes = excel.save();
          final path = '${directory.path}/weekly_report.xlsx';
          final file = File(path);
          await file.writeAsBytes(fileBytes!);
          await Share.shareXFiles([XFile(path)], text: 'Weekly Report (Excel)');
        } else {
          final path = '${directory.path}/weekly_report.csv';
          final file = File(path);
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareXFiles([XFile(path)], text: 'Weekly Report (CSV)');
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Download exception: $e');
      return false;
    }
  }

  // Fetch Overstock Products
  Future<List<OverstockReportModel>> getOverstockReport() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.overstockReport, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['records'] != null) {
          final List list = data['records'];
          return list.map((e) => OverstockReportModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }



  // Fetch Stock Status KPIs
  Future<StockStatusKpiModel?> getStockStatus() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.stock, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['kpis'] != null) {
          return StockStatusKpiModel.fromJson(data['kpis']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Fetch Weekly Sales KPIs
  Future<WeeklySalesKpiModel?> getWeeklySales() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.weeklySales, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['kpis'] != null) {
          return WeeklySalesKpiModel.fromJson(data['kpis']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Fetch Popular Search Keywords (Trends)
  Future<List<String>> getPopularKeywords() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.trendPopular, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['top_keywords'] != null) {
          final List list = data['top_keywords'];
          return list.map((e) => e['keyword']?.toString() ?? '').where((k) => k.isNotEmpty).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Get Suggestions for Specific Brand & Gender
  Future<String> getTrendSuggestion({required String brand, required String gender}) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.trendSuggest}?brand=${Uri.encodeComponent(brand)}&gender=${Uri.encodeComponent(gender)}',
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['best_name']?.toString() ?? data['keyword']?.toString() ?? 'No suggestion found';
        }
      }
      return 'No trend suggestion';
    } catch (_) {
      return 'No trend suggestion';
    }
  }

  // Fetch Overall Report
  Future<List<OverallReportModel>> getOverallReport() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.overallReport, requireAuth: true);
      print('getOverallReport status: ${response.statusCode}');
      print('getOverallReport body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['records'] != null) {
          final List list = data['records'];
          return list.map((e) => OverallReportModel.fromJson(e)).toList();
        } else {
          throw Exception('Failed to parse records: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      print('getOverallReport exception: $e\n$stacktrace');
      rethrow;
    }
  }

  // Trigger Download Overall Report
  Future<bool> downloadOverallReport({bool isExcel = false}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.overallReportDownload, requireAuth: true);
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        
        if (isExcel) {
          String csvString = utf8.decode(response.bodyBytes);
          List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
          var excel = Excel.createExcel();
          Sheet sheetObject = excel['Sheet1'];
          for (var row in rowsAsListOfValues) {
            List<CellValue> cellValues = row.map((e) => TextCellValue(e.toString())).toList();
            sheetObject.appendRow(cellValues);
          }
          var fileBytes = excel.save();
          final path = '${directory.path}/overall_report.xlsx';
          final file = File(path);
          await file.writeAsBytes(fileBytes!);
          await Share.shareXFiles([XFile(path)], text: 'Overall Performance Report (Excel)');
        } else {
          final path = '${directory.path}/overall_report.csv';
          final file = File(path);
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareXFiles([XFile(path)], text: 'Overall Performance Report (CSV)');
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Download exception: $e');
      return false;
    }
  }

  // Fetch Forecast Report
  Future<List<ForecastReportModel>> getForecastReport() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.forecastReport, requireAuth: true);
      print('getForecastReport status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['records'] != null) {
          final List list = data['records'];
          return list.map((e) => ForecastReportModel.fromJson(e)).toList();
        } else {
          throw Exception('Failed to parse records: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      print('getForecastReport exception: $e\n$stacktrace');
      rethrow;
    }
  }

  // Trigger Download Forecast Report
  Future<bool> downloadForecastReport({bool isExcel = false}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.forecastReportDownload, requireAuth: true);
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        
        if (isExcel) {
          String csvString = utf8.decode(response.bodyBytes);
          List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
          var excel = Excel.createExcel();
          Sheet sheetObject = excel['Sheet1'];
          for (var row in rowsAsListOfValues) {
            List<CellValue> cellValues = row.map((e) => TextCellValue(e.toString())).toList();
            sheetObject.appendRow(cellValues);
          }
          var fileBytes = excel.save();
          final path = '${directory.path}/forecast_report.xlsx';
          final file = File(path);
          await file.writeAsBytes(fileBytes!);
          await Share.shareXFiles([XFile(path)], text: 'Forecast Report (Excel)');
        } else {
          final path = '${directory.path}/forecast_report.csv';
          final file = File(path);
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareXFiles([XFile(path)], text: 'Forecast Report (CSV)');
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Download exception: $e');
      return false;
    }
  }

  // Trigger Download Overstock Report
  Future<bool> downloadOverstockReport({bool isExcel = false}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.overstockReportDownload, requireAuth: true);
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        
        if (isExcel) {
          String csvString = utf8.decode(response.bodyBytes);
          List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
          var excel = Excel.createExcel();
          Sheet sheetObject = excel['Sheet1'];
          for (var row in rowsAsListOfValues) {
            List<CellValue> cellValues = row.map((e) => TextCellValue(e.toString())).toList();
            sheetObject.appendRow(cellValues);
          }
          var fileBytes = excel.save();
          final path = '${directory.path}/overstock_report.xlsx';
          final file = File(path);
          await file.writeAsBytes(fileBytes!);
          await Share.shareXFiles([XFile(path)], text: 'Overstock Report (Excel)');
        } else {
          final path = '${directory.path}/overstock_report.csv';
          final file = File(path);
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareXFiles([XFile(path)], text: 'Overstock Report (CSV)');
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Download exception: $e');
      return false;
    }
  }
}
