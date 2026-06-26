import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/new_launch_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';

class NewLaunchDetailView extends StatefulWidget {
  final String skuCode;

  const NewLaunchDetailView({super.key, required this.skuCode});

  @override
  State<NewLaunchDetailView> createState() => _NewLaunchDetailViewState();
}

class _NewLaunchDetailViewState extends State<NewLaunchDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewLaunchController>().loadNewLaunchDetails(widget.skuCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Consumer<NewLaunchController>(
        builder: (context, controller, child) {
          final details = controller.selectedProductDetails;

          if (controller.isDetailsLoading && details == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            );
          }

          if (controller.detailsErrorMessage != null && details == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AppIcons.warning, color: AppTheme.neonPink, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    controller.detailsErrorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.loadNewLaunchDetails(widget.skuCode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (details == null) {
            return const Center(
              child: Text(
                "Product not found",
                style: TextStyle(color: Color(0xFF223025)),
              ),
            );
          }

          final product = details.product;
          final forecast = details.forecast;
          final sales = details.unitsSold;
          final revenue = details.revenue;
          final stock = details.stock;
          final returns = details.returns;

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
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonPurple.withValues(alpha: 0.18),
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
                            color: AppTheme.neonPurple.withValues(alpha: 0.08),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonPurple.withValues(alpha: 0.25),
                                blurRadius: 80,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        /// PRODUCT CARD
                        Transform.rotate(
                          angle: -0.05,
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
                            child: product.imageUrl.isNotEmpty
                                ? Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => _buildImageFallback(product.skuCode),
                                  )
                                : _buildImageFallback(product.skuCode),
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
                          color: AppTheme.neonPurple,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// PRODUCT NAME
                      Text(
                        product.skuName,
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

                      /// PRICE
                      Text(
                        "£${product.retailPrice}",
                        style: const TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 22),

                      /// CHIPS
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildChip(product.category, AppTheme.neonBlue),
                          _buildChip(product.gender, AppTheme.neonPink),
                          _buildChip(product.material, AppTheme.neonOrange),
                        ],
                      ),
                      const SizedBox(height: 30),

                      /// CORE DETAILS
                      _buildSectionCard(
                        title: 'Product Attributes',
                        children: [
                          _buildDetailTile('Product Type', product.productType),
                          _buildDetailTile('Heel Type', product.heelType),
                          _buildDetailTile('Heel Height', product.heelHeight),
                          _buildDetailTile('Toe Type', product.toeType),
                          _buildDetailTile('Size Range', product.sizeRange),
                          _buildDetailTile('Launch Date', product.launchDate),
                          _buildDetailTile('Days Live', '${product.daysSince}'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// SALES & REVENUE
                      _buildSectionCard(
                        title: 'Sales & Revenue',
                        children: [
                          _buildDetailTile('Total Units Sold', '${sales.all}'),
                          _buildDetailTile('Total Revenue', '£${revenue.all}'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildMetricBox('4 Weeks', '${sales.w4} u', '£${revenue.w4}', AppTheme.neonBlue),
                              const SizedBox(width: 10),
                              _buildMetricBox('8 Weeks', '${sales.w8} u', '£${revenue.w8}', AppTheme.neonPurple),
                              const SizedBox(width: 10),
                              _buildMetricBox('12 Weeks', '${sales.w12} u', '£${revenue.w12}', AppTheme.neonOrange),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// FORECAST
                      _buildSectionCard(
                        title: 'Forecasting',
                        children: [
                          _buildDetailTile('Forecast Units', '${forecast.forecastUnits}'),
                          _buildDetailTile('Expected Revenue', '£${forecast.expectedRevenue}'),
                          _buildDetailTile('Order Recommendation', '${forecast.orderRecommendation}'),
                          _buildDetailTile('Avg Weekly Forecast', '${forecast.avgWeeklyForecast}'),
                          _buildDetailTile('Horizon', '${forecast.horizonWeeks} weeks'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// STOCK
                      _buildSectionCard(
                        title: 'Stock Overview',
                        children: [
                          _buildDetailTile('Total Stock', '${stock.total}'),
                          _buildDetailTile('Required Stock', '${stock.requiredStock}'),
                          _buildDetailTile('Weeks of Cover (WOC)', '${stock.woc}'),
                          _buildDetailTile('Status', stock.coverageStatus.toUpperCase()),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFD9E1D6), height: 1),
                          const SizedBox(height: 12),
                          _buildDetailTile('BU 3001', '${stock.bu3001}'),
                          _buildDetailTile('BU 3004', '${stock.bu3004}'),
                          _buildDetailTile('BU 3006', '${stock.bu3006}'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// RETURNS
                      _buildSectionCard(
                        title: 'Returns',
                        children: [
                          _buildDetailTile('Total Return Units', '${returns.totalUnits}'),
                          _buildDetailTile('Return Rate', '${returns.returnRate}%'),
                        ],
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildMetricBox(String title, String val1, String val2, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              val1,
              style: const TextStyle(
                color: Color(0xFF223025),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              val2,
              style: const TextStyle(
                color: Color(0xFF55605B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF55605B), fontSize: 14),
        ),
        Text(
          displayValue,
          style: const TextStyle(
            color: Color(0xFF223025),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.darkAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF223025),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ...children.expand((widget) sync* {
            yield widget;
            if (widget != children.last && widget is! SizedBox && widget is! Row && widget is! Divider) {
              yield const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Color(0xFFD9E1D6), height: 1),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildImageFallback(String skuCode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(AppIcons.shoppingBag, size: 100, color: AppTheme.neonPurple),
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
