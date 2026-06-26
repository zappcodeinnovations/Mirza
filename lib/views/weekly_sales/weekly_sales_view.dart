import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controllers/weekly_sales_controller.dart';
import '../../core/app_theme.dart';
import '../../models/weekly_sales_model.dart';
import 'widgets/weekly_sales_filter_sheet.dart';

class WeeklySalesView extends StatefulWidget {
  const WeeklySalesView({super.key});

  @override
  State<WeeklySalesView> createState() => _WeeklySalesViewState();
}

class _WeeklySalesViewState extends State<WeeklySalesView> {
  final ScrollController _scrollController = ScrollController();
  late WeeklySalesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<WeeklySalesController>(context, listen: false);
    
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
        _controller.loadWeeklySales();
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeeklySalesFilterSheet(
        availableFinancialYears: _controller.availableFinancialYears,
        initiallySelectedFinancialYears: _controller.selectedFinancialYears,
        onApply: (financialYears) {
          _controller.updateFilters(financialYears: financialYears);
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
          'Weekly Sales',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Weekly Sales',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<WeeklySalesController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            );
          }

          if (controller.errorMessage != null && controller.records.isEmpty) {
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
            onRefresh: () => controller.loadWeeklySales(refresh: true),
            color: AppTheme.neonBlue,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (controller.kpis != null)
                  SliverToBoxAdapter(
                    child: _buildKpisSection(theme, controller.kpis!),
                  ),
                  
                if (controller.records.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No weekly sales found for the selected filters.',
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
                          if (index == controller.records.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
                                ),
                              ),
                            );
                          }

                          final record = controller.records[index];
                          return _buildWeeklySalesCard(theme, record);
                        },
                        childCount: controller.records.length + (controller.isFetchingMore ? 1 : 0),
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

  Widget _buildKpisSection(ThemeData theme, WeeklySalesKpiModel kpis) {
    final currencyFormatter = NumberFormat.currency(symbol: '£', decimalDigits: 0);
    final numberFormatter = NumberFormat.decimalPattern();

    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 16, bottom: 24),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildKpiCard(theme, 'Net Sale', currencyFormatter.format(kpis.netSale), Icons.monetization_on_outlined, AppTheme.neonBlue),
          _buildKpiCard(theme, 'Total Return', currencyFormatter.format(kpis.totalReturn), Icons.assignment_return_outlined, AppTheme.neonPink),
          _buildKpiCard(theme, 'Total Records', numberFormatter.format(kpis.totalRecords), Icons.receipt_long_outlined, AppTheme.neonPurple),
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

  Widget _buildWeeklySalesCard(ThemeData theme, WeeklySalesRecordModel record) {
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
                    record.skuCode,
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
                    'Net: £${record.netSale.toStringAsFixed(2)}',
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
              'FY: ${record.financialYear} | Return: £${record.totalReturn.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppTheme.neonPurple),
                const SizedBox(width: 4),
                Text(
                  'Week of ${record.weekStartDate}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.neonPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
