import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  // Search and query e-commerce products
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    String? searchQuery,
    String? status,
    String? brand,
    String? category,
    String? productType,
    String? gender,
  }) async {
    try {
      Map<String, dynamic>? kpis;

      Map<String, dynamic>? filterOptions;

      final List<String> params = ['page=$page'];

      /// SEARCH
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(searchQuery)}');
      }

      /// STATUS
      if (status != null && status.isNotEmpty && status != 'All') {
        params.add('status=${Uri.encodeComponent(status.toLowerCase())}');
      }

      /// BRAND
      if (brand != null && brand.isNotEmpty && brand != 'All') {
        params.add('brand=${Uri.encodeComponent(brand)}');
      }

      /// CATEGORY
      if (category != null && category.isNotEmpty && category != 'All') {
        params.add('category=${Uri.encodeComponent(category)}');
      }

      /// PRODUCT TYPE
      if (productType != null &&
          productType.isNotEmpty &&
          productType != 'All') {
        params.add('product_type=${Uri.encodeComponent(productType)}');
      }

      /// GENDER
      if (gender != null && gender.isNotEmpty && gender != 'All') {
        params.add('gender=${Uri.encodeComponent(gender)}');
      }

      final String queryStr = '?${params.join('&')}';

      final response = await _apiClient.get(
        '${ApiEndpoints.products}$queryStr',
        requireAuth: true,
      );

      if (response.statusCode != 200) {
        return {
          'products': <ProductModel>[],
          'kpis': null,
          'filter_options': null,
          'pagination': null,
        };
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        return {
          'products': <ProductModel>[],
          'kpis': null,
          'filter_options': null,
          'pagination': null,
        };
      }

      /// STORE KPI + FILTER OPTIONS
      kpis = data['kpis'];

      filterOptions = data['filter_options'];

      final List<dynamic> rawItems = data['records'] is List
          ? data['records'] as List<dynamic>
          : const <dynamic>[];

      final List<ProductModel> products = rawItems
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();

      return {
        'products': products,
        'kpis': kpis,
        'filter_options': filterOptions,
        'pagination': data['pagination'],
      };
    } catch (e) {
      return {
        'products': <ProductModel>[],

        'kpis': null,

        'filter_options': null,
      };
    }
  }

  // Fetch full details of a specific product SKU
  Future<ProductModel?> getProductDetails(String skuCode) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.productDetails(skuCode),
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['product'] != null) {
          return ProductModel.fromJson(data['product']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
