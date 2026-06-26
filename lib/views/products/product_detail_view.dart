import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import '../../models/product_model.dart';
import 'product_analytics_view.dart';

class ProductDetailView extends StatefulWidget {
  final String skuCode;
  final ProductModel? initialProduct;

  const ProductDetailView({
    super.key,
    required this.skuCode,
    this.initialProduct,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().fetchProductDetails(widget.skuCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Consumer<ProductController>(
        builder: (context, controller, child) {
          final product = controller.selectedProduct ?? widget.initialProduct;

          if (controller.isLoading && product == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            );
          }

          if (product == null) {
            return const Center(
              child: Text(
                "Product not found",
                style: TextStyle(color: Color(0xFF223025)),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              /// APP BAR
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: AppTheme.darkBg,
                elevation: 0,

                leading: IconButton(
                  icon: const Icon(AppIcons.back, color: Color(0xFF223025)),
                  onPressed: () => Navigator.pop(context),
                ),

                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      AppIcons.favorite,
                      color: Color(0xFF223025),
                    ),
                  ),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonBlue.withValues(alpha: 0.18),
                          AppTheme.darkBg,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),

                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// GLOW CIRCLE
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.neonBlue.withValues(alpha: 0.08),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonBlue.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 80,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),

                        /// PRODUCT CARD
                        Transform.rotate(
                          angle: -0.08,
                          child: Container(
                            width: 280,
                            height: 280,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(34),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.white.withValues(alpha: 0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),

                            child: Hero(
                              tag: product.skuCode,
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) {
                                        return _buildImageFallback(
                                          product.skuCode,
                                        );
                                      },
                                    )
                                  : _buildImageFallback(product.skuCode),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// BRAND
                      Text(
                        product.brand,
                        style: const TextStyle(
                          color: AppTheme.neonBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// PRODUCT NAME
                      Text(
                        product.styleName,
                        style: const TextStyle(
                          color: Color(0xFF223025),
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// SKU
                      Text(
                        "SKU : ${product.skuCode}",
                        style: const TextStyle(
                          color: Color(0xFF55605B),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// PRICE AND BADGES
                      Row(
                        children: [
                          Text(
                            "£${product.retailPrice}",
                            style: const TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            "£${product.cost}",
                            style: const TextStyle(
                              color: Color(0xFF73807A),
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Builder(
                            builder: (context) {
                              final retail =
                                  double.tryParse(
                                    product.retailPrice.toString(),
                                  ) ??
                                  0.0;
                              final cost =
                                  double.tryParse(product.cost.toString()) ??
                                  0.0;
                              if (retail < cost && cost > 0) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonPink.withValues(
                                      alpha: 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '-${(((cost - retail) / cost) * 100).round()}% OFF',
                                    style: const TextStyle(
                                      color: AppTheme.neonPink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (product.stock.total > 0
                                          ? AppTheme.neonGreen
                                          : AppTheme.neonPink)
                                      .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: product.stock.total > 0
                                        ? AppTheme.neonGreen
                                        : AppTheme.neonPink,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  product.stock.total > 0
                                      ? 'IN STOCK'
                                      : 'SOLD OUT',
                                  style: TextStyle(
                                    color: product.stock.total > 0
                                        ? AppTheme.neonGreen
                                        : AppTheme.neonPink,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// COLORS
                      const Text(
                        "Color",
                        style: TextStyle(
                          color: Color(0xFF223025),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 54,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildColorSwatch(product.color, true),
                            // Mocking additional colors for UI purpose as requested
                            if (product.color.toLowerCase() != 'black')
                              _buildColorSwatch('Black', false),
                            if (product.color.toLowerCase() != 'white')
                              _buildColorSwatch('White', false),
                            if (product.color.toLowerCase() != 'blue')
                              _buildColorSwatch('Blue', false),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// SIZES
                      const Text(
                        "Size",
                        style: TextStyle(
                          color: Color(0xFF223025),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _parseSizes(product.sizeRange).map((s) {
                            return _buildSizeChip(
                              s,
                              s == 'UK 9',
                            ); // Mocking UK 9 as selected
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// PRODUCT SUMMARY
                      ExpandableSection(
                        title: 'Product Summary',
                        initiallyExpanded: true,
                        content: Column(
                          children: [
                            _buildDetailTile(
                              'Style Color',
                              product.shoeStyleColor,
                            ),
                            _buildDetailTile(
                              'Product Type',
                              product.productType,
                            ),
                            _buildDetailTile('Occasion', product.occasion),
                            _buildDetailTile('Sole Type', product.soleType),
                            _buildDetailTile('Toe Type', product.toeType),
                            _buildDetailTile('Heel Type', product.heelType),
                            _buildDetailTile('Heel Height', product.heelHeight),
                            _buildDetailTile(
                              'Closure Type',
                              product.closureType,
                            ),
                            _buildDetailTile('Size Range', product.sizeRange),
                          ],
                        ),
                      ),

                      /// STYLE ATTRIBUTES
                      ExpandableSection(
                        title: 'Style Attributes',
                        content: Column(
                          children: [
                            _buildDetailTile(
                              'Attribute A',
                              product.styleAttributeA,
                            ),
                            _buildDetailTile(
                              'Attribute B',
                              product.styleAttributeB,
                            ),
                            _buildDetailTile(
                              'Attribute C',
                              product.styleAttributeC,
                            ),
                            _buildDetailTile(
                              'Attribute D',
                              product.styleAttributeD,
                            ),
                            _buildDetailTile(
                              'Additional Features',
                              product.additionalFeatures.isNotEmpty
                                  ? product.additionalFeatures
                                  : 'N/A',
                            ),
                            _buildDetailTile(
                              'Product URL',
                              product.productUrl.isNotEmpty
                                  ? product.productUrl
                                  : 'N/A',
                            ),
                          ],
                        ),
                      ),

                      /// PRODUCT DETAILS
                      ExpandableSection(
                        title: 'Core Details',
                        content: Column(
                          children: [
                            _buildDetailTile('Color', product.color),
                            _buildDetailTile('Brand', product.brand),
                            _buildDetailTile('Gender', product.gender),
                            _buildDetailTile('Category', product.category),
                            _buildDetailTile(
                              'Launch Date',
                              _formatDate(product.launchDate),
                            ),
                            _buildDetailTile('Status', product.status),
                            _buildDetailTile(
                              'Retail Price',
                              '£${product.retailPrice}',
                            ),
                            _buildDetailTile('Cost', '£${product.cost}'),
                          ],
                        ),
                      ),

                      /// STOCK
                      ExpandableSection(
                        title: 'Stock Details',
                        content: Column(
                          children: [
                            _buildDetailTile(
                              'As On Date',
                              _formatDate(product.stock.asOnDate),
                            ),
                            _buildDetailTile(
                              'BU 3001',
                              '${product.stock.bu3001}',
                            ),
                            _buildDetailTile(
                              'BU 3004',
                              '${product.stock.bu3004}',
                            ),
                            _buildDetailTile(
                              'BU 3006',
                              '${product.stock.bu3006}',
                            ),
                            _buildDetailTile(
                              'Total Stock',
                              '${product.stock.total}',
                            ),
                          ],
                        ),
                      ),

                      /// SALES
                      ExpandableSection(
                        title: 'Sales Analytics',
                        content: Column(
                          children: [
                            _buildDetailTile(
                              'Net Sale',
                              '${product.sales.netSale}',
                            ),
                            _buildDetailTile(
                              'Total Revenue',
                              '£${product.sales.totalRevenue}',
                            ),
                            _buildDetailTile(
                              'Total Return',
                              '${product.sales.totalReturn}',
                            ),
                            _buildDetailTile(
                              'Return Rate',
                              '${product.sales.returnRate}%',
                            ),
                            if (product.sales.byPlatform.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'By Platform',
                                  style: TextStyle(
                                    color: Color(0xFF55605B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...product.sales.byPlatform.map(
                                (platform) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.darkAccent,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          platform.platform,
                                          style: const TextStyle(
                                            color: Color(0xFF223025),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '${platform.units} units | £${platform.revenue}',
                                          style: const TextStyle(
                                            color: Color(0xFF55605B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      /// FORECAST
                      ExpandableSection(
                        title: 'Forecast',
                        content: Column(
                          children: [
                            _buildDetailTile(
                              'Forecast Units',
                              '${product.forecast.forecastUnits}',
                            ),
                            _buildDetailTile(
                              'Current Stock',
                              '${product.forecast.currentStock}',
                            ),
                            _buildDetailTile(
                              'Required Stock',
                              '${product.forecast.requiredStock}',
                            ),
                            _buildDetailTile('WOC', '${product.forecast.woc}'),
                            _buildDetailTile(
                              'Last Updated',
                              _formatDate(product.forecast.lastUpdated),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductAnalyticsView(skuCode: product.skuCode),
                              ),
                            );
                          },
                          child: const Text(
                            "View Analytics",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _parseSizes(String sizeRange) {
    if (sizeRange.isEmpty || sizeRange.toLowerCase() == 'n/a') {
      return ['UK 6', 'UK 7', 'UK 8', 'UK 9', 'UK 10', 'UK 11'];
    }
    // Using mock data for horizontal scrolling effect
    return ['UK 6', 'UK 7', 'UK 8', 'UK 9', 'UK 10', 'UK 11'];
  }

  Color _getColorFromName(String colorName) {
    final lower = colorName.toLowerCase();
    if (lower.contains('red')) return Colors.red;
    if (lower.contains('blue')) return Colors.blue;
    if (lower.contains('green')) return Colors.green;
    if (lower.contains('yellow')) return Colors.yellow;
    if (lower.contains('black')) return const Color(0xFF223025);
    if (lower.contains('white')) return Colors.white;
    if (lower.contains('grey') || lower.contains('gray')) return Colors.grey;
    if (lower.contains('pink')) return Colors.pink;
    if (lower.contains('orange')) return Colors.orange;
    if (lower.contains('purple')) return Colors.purple;
    return AppTheme.neonBlue;
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

  Widget _buildColorSwatch(String colorName, bool isSelected) {
    final color = _getColorFromName(colorName);
    return Container(
      margin: const EdgeInsets.only(right: 14),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: isSelected ? AppTheme.neonBlue : AppTheme.darkAccent,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.neonBlue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildSizeChip(String size, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.neonBlue : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? AppTheme.neonBlue : AppTheme.darkAccent,
        ),
      ),
      child: Text(
        size,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF223025),
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    final displayValue = value.isEmpty ? 'N/A' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF55605B), fontSize: 13.5),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: const TextStyle(
                color: Color(0xFF223025),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback(String skuCode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(AppIcons.shoppingBag, size: 100, color: AppTheme.neonBlue),
        const SizedBox(height: 16),
        Text(
          skuCode,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF223025),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ACCORDION COMPONENT
// ============================================================================

class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.darkAccent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Color(0xFF223025),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF55605B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: widget.content,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
