import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/reports_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';

class MissingProductsView extends StatefulWidget {
  const MissingProductsView({super.key});

  @override
  State<MissingProductsView> createState() => _MissingProductsViewState();
}

class _MissingProductsViewState extends State<MissingProductsView> {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReportsController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Missing Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.download),
            tooltip: 'Download Report',
            onPressed: () async {
              bool? isExcel = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Download Missing Products'),
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

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Starting ${isExcel ? "Excel" : "CSV"} download...')),
                );
              }

              bool success = await controller.downloadMissingProductsReport(isExcel: isExcel);
              
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
      ),
      body: controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            )
          : controller.missingProducts.isEmpty
          ? Center(
              child: Text(
                'No missing products data available.',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : RefreshIndicator(
              onRefresh: () => controller.loadAllReports(),
              color: AppTheme.neonGreen,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.missingProducts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = controller.missingProducts[index];
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
                                '${product.skuCode} - ${product.skuName}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${product.brand} | ${product.gender}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Divider(color: theme.dividerColor),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStat(context, 'Net Sale', product.netSale.toString()),
                            _buildStat(context, 'Orders', product.orders.toString()),
                            _buildStat(context, 'Units Sold', product.unitsSold.toString()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weeks: ${product.weeks}',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              'Revenue: \$${product.revenue.toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
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
}
