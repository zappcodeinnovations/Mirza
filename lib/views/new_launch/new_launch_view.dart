import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/new_launch_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import 'widgets/new_launch_widgets.dart';

class NewLaunchView extends StatefulWidget {
  const NewLaunchView({super.key});

  @override
  State<NewLaunchView> createState() => _NewLaunchViewState();
}

class _NewLaunchViewState extends State<NewLaunchView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewLaunchController>().loadNewLaunch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('New Launch'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              context.read<NewLaunchController>().loadNewLaunch();
            },
          ),
        ],
      ),
      body: Consumer<NewLaunchController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.neonBlue),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    AppIcons.warning,
                    color: AppTheme.neonPink,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.loadNewLaunch,
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

          if (controller.dashboard == null) {
            return const Center(child: Text('No data available'));
          }

          final kpis = controller.kpis!;
          final products = controller.products;

          return RefreshIndicator(
            onRefresh: controller.loadNewLaunch,
            color: AppTheme.neonBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NewLaunchSectionHeader(
                      title: 'Performance Overview',
                      subtitle: 'Key metrics for recent product launches',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          NewLaunchKpiCard(
                            label: 'Total Launches',
                            value: '${kpis.totalNewLaunches}',
                            icon: AppIcons.trendingUp,
                            color: AppTheme.neonBlue,
                          ),
                          const SizedBox(width: 12),
                          NewLaunchKpiCard(
                            label: 'Total Units Sold',
                            value: '${kpis.totalUnitsSold}',
                            icon: AppIcons.bag,
                            color: AppTheme.neonGreen,
                          ),
                          const SizedBox(width: 12),
                          NewLaunchKpiCard(
                            label: 'Avg Days Live',
                            value: '${kpis.avgDaysLive}',
                            icon: AppIcons.calendar,
                            color: AppTheme.neonOrange,
                          ),
                          const SizedBox(width: 12),
                          NewLaunchKpiCard(
                            label: 'Available Stock',
                            value: '${kpis.availableStock}',
                            icon: AppIcons.inventory,
                            color: AppTheme.neonPurple,
                          ),
                          if (kpis.topSeller != null) ...[
                            const SizedBox(width: 12),
                            NewLaunchKpiCard(
                              label: 'Top Seller',
                              value: kpis.topSeller!.skuName,
                              icon: AppIcons.star,
                              color: AppTheme.neonPink,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const NewLaunchSectionHeader(
                      title: 'Recent Products',
                      subtitle: 'List of recently launched products',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search SKU, Style...",
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
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      final filteredProducts = products.where((p) {
                        if (_searchQuery.isEmpty) return true;
                        return p.skuCode.toLowerCase().contains(_searchQuery) ||
                               p.skuName.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filteredProducts.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No matching products found.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return NewLaunchProductCard(product: filteredProducts[index]);
                        },
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
