import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/reports_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import '../../core/app_theme.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReportsController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [

          IconButton(
            icon: const Icon(AppIcons.download),
            tooltip: 'Download Report',
            onPressed: () async {
              bool success = false;
              int tabIndex = _tabController.index;
              String title;
              if (tabIndex == 0) {
                title = 'Download Overall Report';
              } else if (tabIndex == 1) {
                title = 'Download Forecast Report';
              } else {
                title = 'Download Overstock Report';
              }
              
              bool? isExcel = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(title),
                  content: const Text('Select the file format to download.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CSV'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excel'),
                    ),
                  ],
                ),
              );
              
              if (isExcel == null) return; // User cancelled
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Starting ${isExcel ? "Excel" : "CSV"} download...')),
              );
              
              if (tabIndex == 0) {
                success = await controller.downloadOverallReport(isExcel: isExcel);
              } else if (tabIndex == 1) {
                success = await controller.downloadForecastReport(isExcel: isExcel);
              } else {
                success = await controller.downloadOverstockReport(isExcel: isExcel);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Download Successful' : 'Download Failed'),
                    backgroundColor: success ? AppTheme.neonGreen : AppTheme.neonPink,
                  ),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.neonBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.neonBlue,
          tabs: const [
            Tab(text: 'Overall'),
            Tab(text: 'Forecast'),
            Tab(text: 'Overstock'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search SKU, Style, Brand...",
                prefixIcon: const Icon(AppIcons.search, color: AppTheme.neonBlue),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.close, color: AppTheme.neonBlue),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
                    ),
                  )
                : controller.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          AppIcons.warning,
                          size: 50,
                          color: AppTheme.neonPink,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage ?? 'Failed to compile report sheets.',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => controller.loadAllReports(),
                          child: const Text('Reload Deck'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => controller.loadAllReports(),
                    color: AppTheme.neonGreen,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverallTab(controller, theme),
                        _buildForecastTab(controller, theme),
                        _buildOverstockTab(controller, theme),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallTab(ReportsController controller, ThemeData theme) {
    final filteredReports = controller.overallReports.where((r) {
      if (_searchQuery.isEmpty) return true;
      return r.skuCode.toLowerCase().contains(_searchQuery) ||
             r.styleName.toLowerCase().contains(_searchQuery) ||
             r.brand.toLowerCase().contains(_searchQuery) ||
             r.category.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredReports.isEmpty) {
      return Center(child: Text('No report data available.', style: theme.textTheme.bodyLarge));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredReports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${report.skuCode} - ${report.styleName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.status,
                      style: TextStyle(
                        color: _getStatusColor(report.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${report.brand} | ${report.gender} | ${report.category}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(context, 'Gross Sold', report.grossSold.toString()),
                  _buildStat(context, 'Returns', report.returns.toString()),
                  _buildStat(context, 'Net Sold', report.netSold.toString()),
                  _buildStat(context, 'Stock', report.totalStock.toString()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Color: ${report.color}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'WoC: ${report.woc.toStringAsFixed(1)}',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildForecastTab(ReportsController controller, ThemeData theme) {
    final filteredReports = controller.forecastReports.where((r) {
      if (_searchQuery.isEmpty) return true;
      return r.skuCode.toLowerCase().contains(_searchQuery) ||
             r.styleName.toLowerCase().contains(_searchQuery) ||
             r.brand.toLowerCase().contains(_searchQuery) ||
             r.category.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredReports.isEmpty) {
      return Center(child: Text('No forecast data available.', style: theme.textTheme.bodyLarge));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredReports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${report.skuCode} - ${report.styleName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${report.brand} | ${report.gender} | ${report.category}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(context, 'Forecast', report.forecastUnits.toString()),
                  _buildStat(context, 'Current Stock', report.currentStock.toString()),
                  _buildStat(context, 'Req. Stock', report.requiredStock.toString()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Color: ${report.color}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'WoC: ${report.woc.toStringAsFixed(1)}',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverstockTab(ReportsController controller, ThemeData theme) {
    final filteredReports = controller.overstockProducts.where((r) {
      if (_searchQuery.isEmpty) return true;
      return r.skuCode.toLowerCase().contains(_searchQuery) ||
             r.styleName.toLowerCase().contains(_searchQuery) ||
             r.brand.toLowerCase().contains(_searchQuery) ||
             r.category.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredReports.isEmpty) {
      return Center(child: Text('No overstock data available.', style: theme.textTheme.bodyLarge));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredReports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = filteredReports[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${product.skuCode} - ${product.styleName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${product.brand} | ${product.gender} | ${product.category}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(context, 'Total Sales', product.totalSales.toString()),
                  _buildStat(context, 'Current Stock', product.currentStock.toString()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Color: ${product.color}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'low':
        return AppTheme.neonPink;
      case 'ok':
        return AppTheme.neonGreen;
      case 'high':
        return AppTheme.neonOrange;
      default:
        return AppTheme.neonBlue;
    }
  }
}
