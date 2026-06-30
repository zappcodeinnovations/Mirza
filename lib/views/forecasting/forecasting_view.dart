import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/forecasting_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import 'widgets/forecasting_widgets.dart';

class ForecastingView extends StatefulWidget {
  const ForecastingView({super.key});

  @override
  State<ForecastingView> createState() => _ForecastingViewState();
}

class _ForecastingViewState extends State<ForecastingView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForecastingController>().loadForecasting();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Forecasting'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ForecastingController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.dashboard == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            );
          }

          if (controller.errorMessage != null && controller.dashboard == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      AppIcons.forecast,
                      size: 54,
                      color: AppTheme.neonPink,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF223025),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: controller.loadForecasting,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final kpis = controller.kpis!;

          final primaryKpis = [
            (
              'Forecasted Demand',
              '${kpis.forecastedDemand}',
              AppIcons.trendingUp,
              AppTheme.neonGreen,
            ),
            (
              'Inventory On Hand',
              '${kpis.inventoryOnHand}',
              AppIcons.inventory2,
              AppTheme.neonBlue,
            ),
            (
              'Inventory Gap',
              '${kpis.inventoryGap}',
              AppIcons.swap,
              AppTheme.neonPink,
            ),
            (
              'Weeks of Cover',
              kpis.weeksOfCover.toString(),
              AppIcons.time,
              AppTheme.neonOrange,
            ),
          ];

          final extraKpis = [
            (
              'Stockout Risk SKUs',
              '${kpis.skusStockoutRisk}',
              AppIcons.warning,
              AppTheme.neonPink,
            ),
            (
              'Overstock Risk SKUs',
              '${kpis.skusOverstockRisk}',
              AppIcons.inventory,
              AppTheme.neonOrange,
            ),
            (
              'Stock Lasts Weeks',
              kpis.stockLastsWeeks.toString(),
              AppIcons.time,
              AppTheme.neonGreen,
            ),
            (
              'Horizon Weeks',
              '${kpis.horizonWeeks}',
              AppIcons.calendar,
              AppTheme.neonBlue,
            ),
            (
              'Total SKUs',
              '${kpis.totalSkus}',
              AppIcons.category,
              AppTheme.neonPurple,
            ),
          ];

          return RefreshIndicator(
            onRefresh: controller.loadForecasting,
            color: AppTheme.neonBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonGreen.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Forecasting Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.cacheLastUpdated.isNotEmpty
                              ? 'Cache last updated: ${controller.cacheLastUpdated}'
                              : 'Live demand and stock planning insights',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const ForecastingSectionHeader(
                    title: 'Key KPIs',
                    subtitle: 'Top-level metrics for forecast planning',
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: primaryKpis.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.2,
                        ),
                    itemBuilder: (context, index) {
                      final item = primaryKpis[index];
                      return ForecastingKpiCard(
                        label: item.$1,
                        value: item.$2,
                        icon: item.$3,
                        color: item.$4,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: controller.toggleKpis,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.showAllKpis ? 'Show Less' : 'See More',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          controller.showAllKpis
                              ? AppIcons.arrowUp
                              : AppIcons.arrowDown,
                          color: AppTheme.neonGreen,
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: extraKpis.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 1.2,
                              ),
                          itemBuilder: (context, index) {
                            final item = extraKpis[index];
                            return ForecastingKpiCard(
                              label: item.$1,
                              value: item.$2,
                              icon: item.$3,
                              color: item.$4,
                            );
                          },
                        ),
                      ],
                    ),
                    crossFadeState: controller.showAllKpis
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                  ),
                  const SizedBox(height: 28),
                  const ForecastingSectionHeader(
                    title: 'Top 20 Forecast Risks',
                    subtitle: 'Highest-priority SKUs from the forecasting API',
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
                  Builder(builder: (context) {
                    final filteredProducts = controller.topProducts.where((p) {
                      if (_searchQuery.isEmpty) return true;
                      return p.skuCode.toLowerCase().contains(_searchQuery) ||
                             p.skuName.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: Text('No matching products found.', style: TextStyle(color: Colors.white70))),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return ForecastingProductCard(
                          product: filteredProducts[index],
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
