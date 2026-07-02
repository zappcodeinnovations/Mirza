import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controllers/punch_order_controller.dart';
import '../../core/app_theme.dart';
import '../../models/punch_order_model.dart';
import 'widgets/punch_order_create_sheet.dart';

class PunchOrderView extends StatefulWidget {
  const PunchOrderView({super.key});

  @override
  State<PunchOrderView> createState() => _PunchOrderViewState();
}

class _PunchOrderViewState extends State<PunchOrderView> {
  late PunchOrderController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<PunchOrderController>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PunchOrderCreateSheet(),
    );
  }

  void _confirmDelete(BuildContext context, {List<int>? ids, bool deleteAll = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(deleteAll ? 'Delete All Orders?' : 'Delete Order?', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(deleteAll
            ? 'Are you sure you want to delete all punched orders? This cannot be undone.'
            : 'Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _controller.deleteOrders(ids: ids, deleteAll: deleteAll);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPink),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punch Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<PunchOrderController>(
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
                icon: const Icon(Icons.download),
                tooltip: 'Export Orders',
                onPressed: () => controller.exportOrders(context),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_all') {
                _confirmDelete(context, deleteAll: true);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('Delete All'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        backgroundColor: AppTheme.neonBlue,
      ),
      body: Consumer<PunchOrderController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.neonBlue),
            );
          }

          if (controller.errorMessage != null && controller.orders.isEmpty) {
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
                    onPressed: () => controller.fetchHistory(refresh: true),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonBlue),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredOrders = controller.orders.where((order) {
            final query = _searchQuery.toLowerCase();
            return order.skuName.toLowerCase().contains(query) ||
                   order.skuCode.toLowerCase().contains(query);
          }).toList();

          return RefreshIndicator(
            onRefresh: () => controller.fetchHistory(refresh: true),
            color: AppTheme.neonBlue,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by SKU or Name...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
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
                if (filteredOrders.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No results found for "$_searchQuery".'
                            : 'No punch orders found.',
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
                          final order = filteredOrders[index];
                          return _buildOrderCard(theme, order);
                        },
                        childCount: filteredOrders.length,
                      ),
                    ),
                  ),
                  
                // Extra space at bottom so FAB doesn't cover last item
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(ThemeData theme, PunchOrderModel order) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy HH:mm');
    final String dateString = order.punchedAt != null ? formatter.format(order.punchedAt!) : 'N/A';

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
                    order.skuName.isNotEmpty ? order.skuName : order.skuCode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.neonPink),
                  onPressed: () => _confirmDelete(context, ids: [order.id]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${order.skuCode}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoBadge(theme, 'Qty: ${order.quantity}', AppTheme.neonBlue),
                const SizedBox(width: 8),
                _buildInfoBadge(theme, 'Stock: ${order.currentStock ?? 0}', AppTheme.neonGreen),
                const SizedBox(width: 8),
                _buildInfoBadge(theme, 'Diff: ${order.difference ?? 0}', order.difference != null && order.difference! < 0 ? AppTheme.neonPink : AppTheme.neonPurple),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text('Reason: ${order.reason}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('By: ${order.punchedByName}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    Text(dateString, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
                TextButton(
                  onPressed: () => _showAnalysisDialog(context, order),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View Analysis', style: TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisDialog(BuildContext context, PunchOrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: const Text('Analysis Report', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnalysisRow('Forecast Units', order.forecastUnits?.toString() ?? 'N/A', theme),
                _buildAnalysisRow('Recommended Qty', order.recommendedQty?.toString() ?? 'N/A', theme),
                _buildAnalysisRow('Current Stock', order.currentStock?.toString() ?? 'N/A', theme),
                _buildAnalysisRow('Difference', order.difference?.toString() ?? 'N/A', theme),
                const SizedBox(height: 16),
                if (order.forecastReason != null && order.forecastReason!.isNotEmpty) ...[
                  Text('Forecast Reason', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.neonBlue)),
                  const SizedBox(height: 4),
                  Text(order.forecastReason!, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                ],
                if (order.differenceReason != null && order.differenceReason!.isNotEmpty) ...[
                  Text('Difference Reason', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.neonBlue)),
                  const SizedBox(height: 4),
                  Text(order.differenceReason!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppTheme.neonBlue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
