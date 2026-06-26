import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? kpis;
  Map<String, dynamic>? filterOptions;
  String _searchQuery = '';
  String _selectedStatus = ''; // Empty means no status filter
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  List<ProductModel> get products => _products;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  bool get hasMore => _currentPage < _totalPages;

  // Search query state modifier
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter status state modifier
  void setStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  // Load list of products with current filters
  Future<void> fetchProducts({
    String? search,
    String? status,
    String? brand,
    String? category,
    String? productType,
    String? gender,
    bool reset = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    if (reset) {
      _currentPage = 1;
      _totalPages = 1;
      _products = [];
    }

    notifyListeners();

    try {
      final response = await _productService.getProducts(
        page: _currentPage,
        searchQuery: search ?? _searchQuery,
        status: status ?? _selectedStatus,
        brand: brand,
        category: category,
        productType: productType,
        gender: gender,
      );

      final newProducts = response['products'] as List<ProductModel>;

      _products = reset ? newProducts : [..._products, ...newProducts];

      kpis = response['kpis'] as Map<String, dynamic>?;

      filterOptions = response['filter_options'] as Map<String, dynamic>?;

      print("============== FILTER OPTIONS ==============");
      print(filterOptions);

      print("============== BRANDS ==============");
      print(filterOptions?['brands']);

      print("============== CATEGORIES ==============");
      print(filterOptions?['categories']);

      print("============== PRODUCT TYPES ==============");
      print(filterOptions?['product_types']);

      print("============== GENDERS ==============");
      print(filterOptions?['genders']);

      print("============== STATUSES ==============");
      print(filterOptions?['statuses']);
      final pagination = response['pagination'] as Map<String, dynamic>?;
      _currentPage =
          (pagination?['current_page'] as num?)?.toInt() ?? _currentPage;
      _totalPages =
          (pagination?['total_pages'] as num?)?.toInt() ?? _totalPages;

      if (_products.isEmpty) {
        _errorMessage = 'No products found.';
      }
    } catch (e) {
      _errorMessage = 'Error fetching products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts({
    String? search,
    String? status,
    String? brand,
    String? category,
    String? productType,
    String? gender,
  }) async {
    if (_isLoading || _isLoadingMore || !hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _productService.getProducts(
        page: nextPage,
        searchQuery: search ?? _searchQuery,
        status: status ?? _selectedStatus,
        brand: brand,
        category: category,
        productType: productType,
        gender: gender,
      );

      final newProducts = response['products'] as List<ProductModel>;
      _products = [..._products, ...newProducts];

      final pagination = response['pagination'] as Map<String, dynamic>?;
      _currentPage = (pagination?['current_page'] as num?)?.toInt() ?? nextPage;
      _totalPages =
          (pagination?['total_pages'] as num?)?.toInt() ?? _totalPages;

      if (newProducts.isEmpty) {
        _totalPages = _currentPage;
      }
    } catch (e) {
      _errorMessage = 'Error loading more products: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load a single product SKU's full details
  Future<ProductModel?> fetchProductDetails(String skuCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final details = await _productService.getProductDetails(skuCode);
      if (details != null) {
        _selectedProduct = details;
        return details;
      } else {
        _errorMessage = 'Product details not found.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Clear selected product state
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}
