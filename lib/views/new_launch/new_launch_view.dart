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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewLaunchController>().loadNewLaunch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('New Launches'),
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
                    if (products.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No products found.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return NewLaunchProductCard(product: products[index]);
                        },
                      ),
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
