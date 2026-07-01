import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controllers/stock_controller.dart';
import '../../core/app_theme.dart';
import '../../models/stock_model.dart';
import 'widgets/stock_filter_sheet.dart';

class StockView extends StatefulWidget {
  const StockView({super.key});

  @override
  State<StockView> createState() => _StockViewState();
}

class _StockViewState extends State<StockView> {
  final ScrollController _scrollController = ScrollController();
  late StockController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<StockController>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadInitialData();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_controller.isLoading && !_controller.isFetchingMore && _controller.hasMoreData) {
        _controller.loadStock();
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StockFilterSheet(
        availableBrands: _controller.availableBrands,
        availableBusinessUnits: _controller.availableBusinessUnits,
        initiallySelectedBrands: _controller.selectedBrands,
        initiallySelectedBusinessUnits: _controller.selectedBusinessUnits,
        onApply: (brands, businessUnits) {
          _controller.updateFilters(brands: brands, businessUnits: businessUnits);
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
          'Stock Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<StockController>(
            builder: (context, controller, child) {
              if (controller.isDownloading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.neonBlue),
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'Download Stock Report',
                onPressed: () => controller.downloadStockReport(context),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Stock',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<StockController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            );
          }

          if (controller.errorMessage != null && controller.stockRecords.isEmpty) {
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

          final filteredRecords = controller.stockRecords.where((record) {
            final query = _searchQuery.toLowerCase();
            return record.productName.toLowerCase().contains(query) ||
                   record.itemCode.toLowerCase().contains(query);
          }).toList();

          return RefreshIndicator(
            onRefresh: () => controller.loadStock(refresh: true),
            color: AppTheme.neonBlue,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (controller.kpis != null)
                  SliverToBoxAdapter(
                    child: _buildKpisSection(theme, controller.kpis!),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by SKU or Name...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.neonBlue),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                  
                if (filteredRecords.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        _searchQuery.isNotEmpty 
                            ? 'No results found for "$_searchQuery".'
                            : 'No stock found for the selected filters.',
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
                          if (index == filteredRecords.length) {
                            if (_searchQuery.isNotEmpty) return const SizedBox.shrink();
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
                                ),
                              ),
                            );
                          }

                          final record = filteredRecords[index];
                          return _buildStockCard(theme, record);
                        },
                        childCount: filteredRecords.length + (controller.isFetchingMore && _searchQuery.isEmpty ? 1 : 0),
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

  Widget _buildKpisSection(ThemeData theme, StockKpiModel kpis) {
    final numberFormatter = NumberFormat.decimalPattern();

    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 16, bottom: 24),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildKpiCard(theme, 'All Stock', numberFormatter.format(kpis.allStock), Icons.inventory_2_outlined, AppTheme.neonBlue),
          _buildKpiCard(theme, 'BU 3001', numberFormatter.format(kpis.bu3001Total), Icons.storefront, AppTheme.neonGreen),
          _buildKpiCard(theme, 'BU 3004', numberFormatter.format(kpis.bu3004Total), Icons.storefront, AppTheme.neonPurple),
          _buildKpiCard(theme, 'BU 3006', numberFormatter.format(kpis.bu3006Total), Icons.storefront, AppTheme.neonPink),
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

  Widget _buildStockCard(ThemeData theme, StockRecordModel record) {
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
                    record.productName.isNotEmpty ? record.productName : record.itemCode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total QTY: ${record.totalQty}',
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
              'Item Code: ${record.itemCode} | Brand: ${record.brand}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildBuQty(theme, record.businessUnit1, record.qty1, AppTheme.neonGreen)),
                const SizedBox(width: 8),
                Expanded(child: _buildBuQty(theme, record.businessUnit2, record.qty2, AppTheme.neonPurple)),
                const SizedBox(width: 8),
                Expanded(child: _buildBuQty(theme, record.businessUnit3, record.qty3, AppTheme.neonPink)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuQty(ThemeData theme, String bu, int qty, Color color) {
    if (bu.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'BU $bu',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$qty',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
