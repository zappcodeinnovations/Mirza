import 'package:flutter/material.dart';
import 'package:mirzza/core/app_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controllers/sales_controller.dart';
import '../../core/app_theme.dart';
import '../../models/sales_model.dart';
import 'widgets/sales_filter_sheet.dart';

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  final ScrollController _scrollController = ScrollController();
  late SalesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<SalesController>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadInitialData();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_controller.isLoading && !_controller.isFetchingMore && _controller.hasMoreData) {
        _controller.loadSales();
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SalesFilterSheet(
        availablePlatforms: _controller.availablePlatforms,
        availableBrands: _controller.availableBrands,
        initiallySelectedPlatforms: _controller.selectedPlatforms,
        initiallySelectedBrands: _controller.selectedBrands,
        onApply: (platforms, brands) {
          _controller.updateFilters(platforms: platforms, brands: brands);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.filter),
            tooltip: 'Filter Sales',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<SalesController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            );
          }

          if (controller.errorMessage != null && controller.salesRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage!,
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.neonPink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadInitialData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonBlue,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadSales(refresh: true),
            color: AppTheme.neonBlue,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (controller.kpis != null)
                  SliverToBoxAdapter(
                    child: _buildKpisSection(theme, controller.kpis!),
                  ),
                  
                if (controller.salesRecords.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No sales found for the selected filters.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == controller.salesRecords.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
                                ),
                              ),
                            );
                          }

                          final record = controller.salesRecords[index];
                          return _buildSalesCard(theme, record);
                        },
                        childCount: controller.salesRecords.length + (controller.isFetchingMore ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpisSection(ThemeData theme, SalesKpiModel kpis) {
    final currencyFormatter = NumberFormat.currency(symbol: '£', decimalDigits: 0);
    final numberFormatter = NumberFormat.decimalPattern();

    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 16, bottom: 24),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildKpiCard(theme, 'Total Revenue', currencyFormatter.format(kpis.totalRevenue), Icons.analytics_outlined, AppTheme.neonGreen),
          _buildKpiCard(theme, 'Total Orders', numberFormatter.format(kpis.totalOrders), Icons.shopping_bag_outlined, AppTheme.neonBlue),
          _buildKpiCard(theme, 'Total Volume', numberFormatter.format(kpis.totalVolume), Icons.inventory_2_outlined, AppTheme.neonPurple),
          _buildKpiCard(theme, 'Top SKU', kpis.topSku, Icons.star_border, AppTheme.neonPink),
          _buildKpiCard(theme, 'Top Platform', kpis.topPlatform, Icons.storefront, Colors.amberAccent),
          _buildKpiCard(theme, 'Top City', kpis.topCity, Icons.location_city, Colors.tealAccent),
        ],
      ),
    );
  }

  Widget _buildKpiCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesCard(ThemeData theme, SalesRecordModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    record.skuName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '£${record.totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.neonBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${record.skuCode} | Size: ${record.size} | Color: ${record.colour}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoBadge(theme, record.platform, AppTheme.neonPink),
                const SizedBox(width: 8),
                _buildInfoBadge(theme, 'Qty: ${record.quantity}', AppTheme.neonPurple),
                const Spacer(),
                Text(
                  record.orderDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
