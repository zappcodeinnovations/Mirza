import 'package:flutter/material.dart';
import 'package:mirzza/views/dashboard/widgets/dashboard_appbar.dart';
import 'package:mirzza/views/dashboard/widgets/dashboard_drawer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import 'widgets/dashboard_chart_widgets.dart';
import 'widgets/dashboard_filter_widgets.dart';
import 'widgets/dashboard_summary_widgets.dart';
import '../chat/widgets/floating_chat_bot.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      symbol: '€',
      decimalDigits: 2,
    );
    final numberFormatter = NumberFormat.decimalPattern();

    return Scaffold(
      drawer: const DashboardDrawer(),
      appBar: DashboardAppBar(controller: controller),
      body: Stack(
        children: [
          controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.neonBlue,
                    ),
                  ),
                )
              : controller.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        AppIcons.cloudOff,
                        size: 50,
                        color: AppTheme.neonPink,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.errorMessage!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.72),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => controller.initializeDashboard(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      controller.fetchMetrics(showLoadingIndicator: true),
                  color: AppTheme.neonBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// ACTIVE FILTERS
                        DashboardActiveFiltersRow(controller: controller),

                        const SizedBox(height: 20),

                        /// KPI SECTION
                        DashboardKpiSection(
                          controller: controller,
                          currencyFormatter: currencyFormatter,
                          numberFormatter: numberFormatter,
                        ),

                        const SizedBox(height: 24),

                        /// AUTO INSIGHTS
                        DashboardInsightsSlider(controller: controller),

                        const SizedBox(height: 24),

                        /// TOP PRODUCTS
                        DashboardTopProductsSection(
                          controller: controller,
                          currencyFormatter: currencyFormatter,
                          numberFormatter: numberFormatter,
                        ),

                        const SizedBox(height: 24),

                        /// STYLE MIX
                        DashboardDonutChartSection(
                          title: "Style Mix",
                          labels:
                              controller.dashboardData?.styleMix?.labels ?? [],
                          values:
                              controller.dashboardData?.styleMix?.values ?? [],
                        ),

                        const SizedBox(height: 24),

                        /// COLOR MIX
                        DashboardDonutChartSection(
                          title: "Color Mix",
                          labels:
                              controller.dashboardData?.colorMix?.labels ?? [],
                          values:
                              controller.dashboardData?.colorMix?.values ?? [],
                        ),

                        const SizedBox(height: 24),

                        /// MATERIAL MIX
                        DashboardDonutChartSection(
                          title: "Material Mix",
                          labels:
                              controller.dashboardData?.materialMix?.labels ??
                              [],
                          values:
                              controller.dashboardData?.materialMix?.values ??
                              [],
                        ),

                        const SizedBox(height: 24),

                        /// RETURN ANALYSIS
                        DashboardReturnAnalysisChart(controller: controller),

                        const SizedBox(height: 24),

                        /// SEASONAL GRAPH
                        DashboardSeasonalChart(controller: controller),

                        const SizedBox(height: 24),

                        /// CITY GRAPH
                        DashboardCityWiseChart(controller: controller),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
          const Positioned.fill(
            child: IgnorePointer(ignoring: true, child: SizedBox.shrink()),
          ),
          const FloatingChatBot(),
        ],
      ),
    );
  }
}
