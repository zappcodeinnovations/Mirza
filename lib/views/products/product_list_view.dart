import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import '../../views/search/search_view.dart';
import 'product_detail_view.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String selectedBrand = 'All';
  String selectedCategory = 'All';
  String selectedProductType = 'All';
  String selectedGender = 'All';

  Future<void> _fetchFirstPage() async {
    final controller = context.read<ProductController>();

    await controller.fetchProducts(
      search: _searchController.text.trim(),
      status: controller.selectedStatus,
      brand: selectedBrand,
      category: selectedCategory,
      productType: selectedProductType,
      gender: selectedGender,
      reset: true,
    );
  }

  Future<void> _loadMoreProducts() async {
    final controller = context.read<ProductController>();

    await controller.loadMoreProducts(
      search: _searchController.text.trim(),
      status: controller.selectedStatus,
      brand: selectedBrand,
      category: selectedCategory,
      productType: selectedProductType,
      gender: selectedGender,
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 300) {
      _loadMoreProducts();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    // Fetch initial list of products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFirstPage();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProductController>(context);
    final theme = Theme.of(context);
    final filterOptions = controller.filterOptions;

    final brands = [
      'All',
      ...(filterOptions?['brands'] as List? ?? []).map(
        (e) => e['brand_name'].toString(),
      ),
    ];

    final categories = [
      'All',
      ...(filterOptions?['categories'] as List? ?? []).map((e) => e.toString()),
    ];

    final productTypes = [
      'All',
      ...(filterOptions?['product_types'] as List? ?? []).map(
        (e) => e.toString(),
      ),
    ];

    final genders = [
      'All',
      ...(filterOptions?['genders'] as List? ?? []).map((e) => e.toString()),
    ];

    final statuses = [
      {'label': 'All', 'value': ''},
      ...(filterOptions?['statuses'] as List? ?? []).whereType<Map>().map(
        (e) => {
          'label': e['label']?.toString() ?? '',
          'value': e['value']?.toString() ?? '',
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [
          // IconButton(
          //   icon: const Icon(
          //     AppIcons.search,
          //     color: AppTheme.neonBlue,
          //   ),
          //   tooltip: "Global Search",
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => const SearchView(),
          //       ),
          //     );
          //   },
          // ),
          IconButton(
            onPressed: () {
              _showFilterBottomSheet(
                context,
                controller,
                brands,
                categories,
                productTypes,
                genders,
              );
            },

            icon: Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: AppTheme.darkSurface,

                borderRadius: BorderRadius.circular(14),
              ),

              child: const Icon(
                AppIcons.filter,
                color: AppTheme.neonBlue,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFirstPage,
        color: AppTheme.neonBlue,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name, SKU, color, gender...",
                      prefixIcon: const Icon(
                        AppIcons.search,
                        color: AppTheme.neonBlue,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                AppIcons.close,
                                color: AppTheme.neonBlue,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                controller.setSearchQuery('');
                                _fetchFirstPage();
                              },
                            )
                          : null,
                    ),
                    style: theme.textTheme.bodyLarge,
                    onChanged: (val) {
                      controller.setSearchQuery(val.trim());
                      _fetchFirstPage();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status Filter tag selector row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statuses
                          .map(
                            (status) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _buildStatusChip(
                                controller,
                                label: status['label']!.toString(),
                                value: status['value']!.toString(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (controller.kpis != null) ...[
                    SizedBox(
                      height: 115,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildKpiCard(
                            title: 'Products',
                            value: '${controller.kpis!['products'] ?? 0}',
                            icon: AppIcons.inventory2,
                            color: AppTheme.neonBlue,
                          ),
                          _buildKpiCard(
                            title: 'Brands',
                            value: '${controller.kpis!['brands'] ?? 0}',
                            icon: AppIcons.business,
                            color: AppTheme.neonGreen,
                          ),
                          _buildKpiCard(
                            title: 'Categories',
                            value: '${controller.kpis!['categories'] ?? 0}',
                            icon: AppIcons.category,
                            color: AppTheme.neonOrange,
                          ),
                          _buildKpiCard(
                            title: 'Colors',
                            value: '${controller.kpis!['colors'] ?? 0}',
                            icon: AppIcons.palette,
                            color: AppTheme.neonPink,
                          ),
                          _buildKpiCard(
                            title: 'Genders',
                            value: '${controller.kpis!['genders'] ?? 0}',
                            icon: AppIcons.users,
                            color: AppTheme.neonPurple,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ]),
              ),
            ),
            
            // Product List view
            if (controller.isLoading && controller.products.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.neonBlue,
                    ),
                  ),
                ),
              )
            else if (controller.errorMessage != null && controller.products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        AppIcons.searchOff,
                        size: 45,
                        color: AppTheme.neonBlue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.errorMessage!,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= controller.products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.neonBlue,
                              ),
                            ),
                          ),
                        );
                      }

                      final product = controller.products[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildProductCard(
                          context,
                          product,
                          controller,
                        ),
                      );
                    },
                    childCount: controller.products.length + (controller.isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
              
            const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 90,

      margin: const EdgeInsets.only(right: 10),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      decoration: BoxDecoration(
        color: AppTheme.darkSurface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: color.withValues(alpha: 0.18)),

        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Container(
                padding: const EdgeInsets.all(6),

                child: Icon(icon, color: color, size: 16),
              ),

              Icon(
                AppIcons.trendingUp,
                color: color.withValues(alpha: 0.7),
                size: 16,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            value,

            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,

            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    ProductController controller,
    List<String> brands,
    List<String> categories,
    List<String> productTypes,
    List<String> genders,
  ) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),

              decoration: const BoxDecoration(
                color: AppTheme.darkSurface,

                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),

              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,

                          decoration: BoxDecoration(
                            color: Colors.white24,

                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Filters',

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF223025),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildDropdown(
                        title: 'Brand',
                        value: selectedBrand,
                        items: brands,
                        onChanged: (val) {
                          setModalState(() {
                            selectedBrand = val!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildDropdown(
                        title: 'Category',
                        value: selectedCategory,
                        items: categories,
                        onChanged: (val) {
                          setModalState(() {
                            selectedCategory = val!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildDropdown(
                        title: 'Product Type',
                        value: selectedProductType,
                        items: productTypes,
                        onChanged: (val) {
                          setModalState(() {
                            selectedProductType = val!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildDropdown(
                        title: 'Gender',
                        value: selectedGender,
                        items: genders,
                        onChanged: (val) {
                          setModalState(() {
                            selectedGender = val!;
                          });
                        },
                      ),

                      const SizedBox(height: 26),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedBrand = 'All';
                                  selectedCategory = 'All';
                                  selectedProductType = 'All';
                                  selectedGender = 'All';
                                });

                                _searchController.clear();
                                controller.setSearchQuery('');
                                controller.setStatus('');

                                Navigator.pop(context);

                                _fetchFirstPage();
                              },

                              child: const Text('Reset'),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _fetchFirstPage();

                                Navigator.pop(context);
                              },

                              icon: const Icon(AppIcons.filterAlt),

                              label: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: const TextStyle(
            color: Color(0xFF55605B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),

          decoration: BoxDecoration(
            color: AppTheme.darkBg,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: AppTheme.darkAccent),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,

              isExpanded: true,

              dropdownColor: AppTheme.darkSurface,

              style: const TextStyle(color: Color(0xFF223025), fontSize: 14),

              icon: const Icon(
                AppIcons.arrowDown,
                color: Color(0xFF55605B),
              ),

              items: items.map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF223025)),
                  ),
                );
              }).toList(),

              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    ProductController controller, {
    required String label,
    required String value,
  }) {
    final bool active = value.isEmpty
        ? controller.selectedStatus.isEmpty
        : controller.selectedStatus == value;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        controller.setStatus(value);
        _fetchFirstPage();
      },
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.72),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: active ? AppTheme.neonBlue : AppTheme.darkSurface,
        side: BorderSide(
          color: active ? AppTheme.neonBlue : AppTheme.darkAccent,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildProductCard(
    BuildContext context,
    dynamic product,
    ProductController controller,
  ) {
    final theme = Theme.of(context);
    
    // Added debug print for image url
    debugPrint('IMAGE URL FOR SKU ${product.skuCode}: "${product.imageUrl}"');

    final rawProductName = product.styleName.isNotEmpty 
        ? '${product.styleName} ${product.color}'.trim() 
        : "Unknown Product";
    final displayProductName = _toTitleCase(rawProductName);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailView(
              skuCode: product.skuCode,
             
            )
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
        Container(
          margin: const EdgeInsets.only(top: 40, bottom: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.darkAccent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20).copyWith(top: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayProductName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "SKU: ${product.skuCode}", 
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 18),
                
                Row(
                  children: [
                    Expanded(child: _buildInfoRow(AppIcons.business, product.brand.isNotEmpty ? product.brand : "N/A")),
                    Expanded(child: _buildInfoRow(AppIcons.category, product.category.isNotEmpty ? product.category : "N/A")),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(
                      product.gender,
                      AppTheme.neonGreen,
                      icon: _getGenderIcon(product.gender),
                    ),
                    _buildTag(
                      product.color,
                      _getColorFromName(product.color),
                    ),
                    _buildTag(product.material, Colors.orange),
                    _buildTag(product.status.toString().replaceAll("_", " "), Colors.blue),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceCard(
                        context: context,
                        title: "Retail Price",
                        value: "£${product.retailPrice}",
                        color: AppTheme.neonGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPriceCard(
                        context: context,
                        title: "Cost",
                        value: "£${product.cost}",
                        color: AppTheme.neonOrange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(AppIcons.calendar, size: 15, color: Color(0xFF55605B)),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(product.launchDate),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailView(
                              skuCode: product.skuCode,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonGreen.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Text(
                              "View Details",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            SizedBox(width: 6),
                            Icon(AppIcons.arrowForward, size: 14, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        Positioned(
          top: 0,
          left: 12,
          right: 12,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppTheme.darkBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Hero(
              tag: product.skuCode,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: product.imageUrl != null && product.imageUrl.toString().trim().isNotEmpty
                    ? Image.network(
                        product.imageUrl.toString().trim(),
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('ERROR LOADING IMAGE FOR SKU ${product.skuCode}: $error');
                          return _buildImagePlaceholder(product);
                        },
                      )
                    : _buildImagePlaceholder(product),
              ),
            ),
          ),
        ),
      ],
      )
    );
  }

  Widget _buildImagePlaceholder(dynamic product) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withValues(alpha: 0.15),
            AppTheme.neonOrange.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.shoppingBag, size: 50, color: AppTheme.neonGreen),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                product.styleName.toString().isNotEmpty
                    ? product.styleName.toString()
                    : 'Unknown Product',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neonPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.neonBlue),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            value,

            style: const TextStyle(fontSize: 13, color: Color(0xFF55605B)),

            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty || dateString.toLowerCase() == 'n/a') return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = (date.year % 100).toString().padLeft(2, '0');
      return '$day/$month/$year';
    } catch (e) {
      return dateString;
    }
  }

  Color _getColorFromName(String colorName) {
    final lower = colorName.toLowerCase();
    if (lower.contains('red')) return Colors.red;
    if (lower.contains('blue')) return Colors.blue;
    if (lower.contains('green')) return Colors.green;
    if (lower.contains('yellow')) return Colors.amber.shade700;
    if (lower.contains('black')) return const Color(0xFF223025);
    if (lower.contains('white')) return const Color(0xFF94A3B8); // Slate for visibility on white background
    if (lower.contains('brown')) return Colors.brown;
    if (lower.contains('pink')) return Colors.pink;
    if (lower.contains('purple')) return Colors.purple;
    if (lower.contains('orange')) return Colors.orange;
    if (lower.contains('grey') || lower.contains('gray')) return Colors.grey;
    return Colors.teal; // default
  }

  IconData? _getGenderIcon(String gender) {
    final lower = gender.toLowerCase();
    if (lower == 'male' || lower == 'm' || lower == 'men') return Icons.male;
    if (lower == 'female' || lower == 'f' || lower == 'women') return Icons.female;
    if (lower.contains('uni') || lower.contains('all')) return Icons.transgender;
    return null;
  }

  Widget _buildPriceCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(title, style: theme.textTheme.bodySmall),

          const SizedBox(height: 6),

          Text(
            value,

            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
