import 'package:flutter/foundation.dart';
import '../models/search_model.dart';
import '../models/product_model.dart';
import '../models/dashboard_model.dart';
import '../models/sales_model.dart';
import '../models/stock_model.dart';

class SearchController extends ChangeNotifier {
  List<SearchResult> _searchResults = [];
  List<SearchCategory> _categorizedResults = [];
  String _searchQuery = '';
  bool _isSearching = false;

  // Data from different controllers
  List<ProductModel>? _products;
  List<DashboardTopProductModel>? _dashboardTopProducts;
  List<SalesRecordModel>? _sales;
  List<StockRecordModel>? _stocks;

  // Getters
  List<SearchResult> get searchResults => _searchResults;
  List<SearchCategory> get categorizedResults => _categorizedResults;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  // Setters for data from different controllers
  void setProducts(List<ProductModel> products) {
    _products = products;
    notifyListeners();
  }

  void setDashboardTopProducts(List<DashboardTopProductModel> products) {
    _dashboardTopProducts = products;
    notifyListeners();
  }

  void setSales(List<SalesRecordModel> sales) {
    _sales = sales;
    notifyListeners();
  }

  void setStocks(List<StockRecordModel> stocks) {
    _stocks = stocks;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query.toLowerCase();
    _isSearching = true;
    notifyListeners();

    if (_searchQuery.isEmpty) {
      _searchResults = [];
      _categorizedResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _searchResults = [];
    Map<String, List<SearchResult>> categorizedMap = {};

    // Search in Products
    if (_products != null && _products!.isNotEmpty) {
      final productResults = _searchInProducts(_searchQuery);
      if (productResults.isNotEmpty) {
        categorizedMap['Products'] = productResults;
        _searchResults.addAll(productResults);
      }
    }

    // Search in Dashboard Top Products
    if (_dashboardTopProducts != null && _dashboardTopProducts!.isNotEmpty) {
      final dashboardResults = _searchInDashboardProducts(_searchQuery);
      if (dashboardResults.isNotEmpty) {
        if (categorizedMap.containsKey('Top Products')) {
          categorizedMap['Top Products']!.addAll(dashboardResults);
        } else {
          categorizedMap['Top Products'] = dashboardResults;
        }
        _searchResults.addAll(dashboardResults);
      }
    }

    // Search in Sales
    if (_sales != null && _sales!.isNotEmpty) {
      final salesResults = _searchInSales(_searchQuery);
      if (salesResults.isNotEmpty) {
        categorizedMap['Sales'] = salesResults;
        _searchResults.addAll(salesResults);
      }
    }

    // Search in Stocks
    if (_stocks != null && _stocks!.isNotEmpty) {
      final stockResults = _searchInStocks(_searchQuery);
      if (stockResults.isNotEmpty) {
        categorizedMap['Stocks'] = stockResults;
        _searchResults.addAll(stockResults);
      }
    }

    // Build categorized results
    _categorizedResults = categorizedMap.entries
        .map((e) => SearchCategory(
              name: e.key,
              icon: _getCategoryIcon(e.key),
              results: e.value,
            ))
        .toList();

    _isSearching = false;
    notifyListeners();
  }

  List<SearchResult> _searchInProducts(String query) {
    if (_products == null) return [];

    return _products!
        .where((product) {
          return product.styleName.toLowerCase().contains(query) ||
              product.skuCode.toLowerCase().contains(query) ||
              product.brand.toLowerCase().contains(query) ||
              product.color.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query) ||
              product.shoeStyleColor.toLowerCase().contains(query);
        })
        .map((product) => SearchResult(
              id: product.id.toString(),
              title: product.styleName,
              subtitle:
                  '${product.brand} • ${product.category} • SKU: ${product.skuCode}',
              category: 'Product',
              imageUrl: product.imageUrl,
              data: {
                'skuCode': product.skuCode,
                'brand': product.brand,
                'color': product.color,
                'price': product.retailPrice,
              },
            ))
        .toList();
  }

  List<SearchResult> _searchInDashboardProducts(String query) {
    if (_dashboardTopProducts == null) return [];

    return _dashboardTopProducts!
        .where((product) {
          return product.skuName.toLowerCase().contains(query) ||
              product.skuCode.toLowerCase().contains(query) ||
              product.brand.toLowerCase().contains(query) ||
              product.colour.toLowerCase().contains(query);
        })
        .map((product) => SearchResult(
              id: product.skuCode,
              title: product.skuName,
              subtitle:
                  'SKU: ${product.skuCode} • ${product.brand} • Units: ${product.units}',
              category: 'Top Product',
              data: {
                'skuCode': product.skuCode,
                'units': product.units,
                'revenue': product.revenue,
              },
            ))
        .toList();
  }

  List<SearchResult> _searchInSales(String query) {
    if (_sales == null) return [];

    return _sales!
        .where((sale) {
          return sale.skuName.toLowerCase().contains(query) ||
              sale.skuCode.toLowerCase().contains(query) ||
              sale.city.toLowerCase().contains(query) ||
              sale.brand.toLowerCase().contains(query);
        })
        .map((sale) => SearchResult(
              id: sale.id.toString(),
              title: sale.skuName,
              subtitle: '${sale.city} • ${sale.skuCode} • Qty: ${sale.quantity}',
              category: 'Sales',
              data: {
                'skuCode': sale.skuCode,
                'city': sale.city,
                'quantity': sale.quantity,
                'orderId': sale.orderId,
              },
            ))
        .toList();
  }

  List<SearchResult> _searchInStocks(String query) {
    if (_stocks == null) return [];

    return _stocks!
        .where((stock) {
          return stock.productName.toLowerCase().contains(query) ||
              stock.itemCode.toLowerCase().contains(query) ||
              stock.brand.toLowerCase().contains(query);
        })
        .map((stock) => SearchResult(
              id: stock.id.toString(),
              title: stock.productName,
              subtitle: '${stock.itemCode} • Total: ${stock.totalQty}',
              category: 'Stock',
              data: {
                'itemCode': stock.itemCode,
                'quantity': stock.totalQty,
                'brand': stock.brand,
              },
            ))
        .toList();
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Products':
        return '📦';
      case 'Top Products':
        return '⭐';
      case 'Sales':
        return '💰';
      case 'Stocks':
        return '📈';
      default:
        return '🔍';
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _categorizedResults = [];
    notifyListeners();
  }
}
