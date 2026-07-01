import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/api_client.dart';
import '../models/punch_order_model.dart';
import '../services/punch_order_service.dart';

class PunchOrderController extends ChangeNotifier {
  final PunchOrderService _service = PunchOrderService(ApiClient());

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PunchOrderModel> _orders = [];
  List<PunchOrderModel> get orders => _orders;

  List<String> _predefinedReasons = [];
  List<String> get predefinedReasons => _predefinedReasons;

  Future<void> fetchOptions() async {
    if (_predefinedReasons.isNotEmpty) return;
    final response = await _service.getPunchOrderOptions();
    if (response != null && response.success) {
      _predefinedReasons = response.predefinedReasons;
      notifyListeners();
    }
  }

  Future<void> fetchHistory({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getPunchOrderHistory();
    if (response != null && response.success) {
      _orders = response.orders;
    } else {
      _errorMessage = 'Failed to load punch order history.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<PunchOrderCreateResponseModel?> createPunchOrder(Map<String, dynamic> data) async {
    final response = await _service.createPunchOrder(data);
    if (response != null && response.success) {
      // Reload history automatically on success
      fetchHistory(refresh: true);
    }
    return response;
  }

  Future<bool> deleteOrders({List<int>? ids, bool deleteAll = false}) async {
    final success = await _service.deletePunchOrders(ids: ids, deleteAll: deleteAll);
    if (success) {
      fetchHistory(refresh: true);
    }
    return success;
  }

  Future<bool> exportOrders(BuildContext context) async {
    _isDownloading = true;
    notifyListeners();

    try {
      final response = await _service.exportPunchOrders();
      if (response != null && response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Ensure directory exists
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        
        // It could be csv or xlsx, but we'll use xlsx if Content-Type suggests it, or just fallback to xlsx/csv.
        // Assuming excel based on user's hint "export the punch order in excel"
        final file = File('${dir.path}/punch_orders_$timestamp.xlsx');
        await file.writeAsBytes(response.bodyBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Punch orders exported successfully!')),
          );
        }

        await Share.shareXFiles([XFile(file.path)], text: 'Punch Orders Export');
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to export punch orders. Please try again.')),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting punch orders: $e')),
        );
      }
      return false;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<List<String>> searchSkuOptions(String query) async {
    return await _service.searchSkuOptions(query);
  }
}
