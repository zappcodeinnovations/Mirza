import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../core/app_icons.dart';
import '../../../core/app_theme.dart';

class DashboardKpiSection extends StatelessWidget {
  const DashboardKpiSection({
    super.key,
    required this.controller,
    required this.currencyFormatter,
    required this.numberFormatter,
  });

  final DashboardController controller;
  final NumberFormat currencyFormatter;
  final NumberFormat numberFormatter;

  @override
  Widget build(BuildContext context) {
    final kpi = controller.dashboardData?.kpis;
    final theme = Theme.of(context);
    final headingColor = theme.colorScheme.onSurface;
    final bodyColor = theme.textTheme.bodyMedium?.color ?? AppTheme.neonBlue;

    if (kpi == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Summary',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.4,
          children: [
            _DashboardKpiCard(
              title: 'Gross Units',
              value: numberFormatter.format(kpi.grossUnits),
              icon: AppIcons.bag,
              accentColor: AppTheme.neonOrange,
            ),
            _DashboardKpiCard(
              title: 'Gross Revenue',
              value: currencyFormatter.format(kpi.grossRevenue),
              icon: AppIcons.wallet,
              accentColor: AppTheme.neonGreen,
            ),
            _DashboardKpiCard(
              title: 'ASP',
              value: currencyFormatter.format(kpi.asp),
              icon: AppIcons.activity,
              accentColor: AppTheme.neonBlue,
            ),
            _DashboardKpiCard(
              title: 'Return Rate',
              value: '${kpi.returnRate.toStringAsFixed(1)}%',
              icon: AppIcons.refresh,
              accentColor: AppTheme.neonPink,
            ),
            if (controller.showMoreKpis) ...[
              _DashboardKpiCard(
                title: 'Sell Through',
                value: '${kpi.sellThrough.toStringAsFixed(1)}%',
                icon: AppIcons.activity,
                accentColor: Colors.green,
              ),
              _DashboardKpiCard(
                title: 'Weeks Cover',
                value: '${kpi.weeksCover.toStringAsFixed(1)}',
                icon: AppIcons.time,
                accentColor: Colors.orange,
              ),
              _DashboardKpiCard(
                title: 'Net Units',
                value: numberFormatter.format(kpi.netUnits),
                icon: AppIcons.inventory,
                accentColor: Colors.cyan,
              ),
              _DashboardKpiCard(
                title: 'Active Products',
                value: numberFormatter.format(kpi.activeProducts),
                icon: AppIcons.category,
                accentColor: Colors.purple,
              ),
              _DashboardKpiCard(
                title: 'Competitors',
                value: numberFormatter.format(kpi.competitors),
                icon: AppIcons.users,
                accentColor: Colors.red,
              ),
              _DashboardKpiCard(
                title: 'Total Orders',
                value: numberFormatter.format(kpi.totalOrders),
                icon: AppIcons.document,
                accentColor: Colors.teal,
              ),
              _DashboardKpiCard(
                title: 'Net Returns',
                value: numberFormatter.format(kpi.netReturns),
                icon: AppIcons.swap,
                accentColor: Colors.amber,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: controller.toggleMoreKpis,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.showMoreKpis ? 'Show Less' : 'Show More',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                controller.showMoreKpis ? AppIcons.arrowUp : AppIcons.arrowDown,
                color: AppTheme.neonGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardInsightsSlider extends StatelessWidget {
  const DashboardInsightsSlider({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final insights = controller.dashboardData?.autoInsights ?? [];
    final theme = Theme.of(context);

    if (insights.isEmpty) {
      return const SizedBox();
    }

    return CarouselSlider.builder(
      itemCount: insights.length,
      options: CarouselOptions(
        height: 120,
        autoPlay: true,
        viewportFraction: 1,
        enlargeCenterPage: true,
      ),
      itemBuilder: (context, index, realIndex) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.darkAccent),
          ),
          child: Row(
            children: [
              const Icon(AppIcons.star, color: AppTheme.neonOrange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insights[index],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardTopProductsSection extends StatelessWidget {
  const DashboardTopProductsSection({
    super.key,
    required this.controller,
    required this.currencyFormatter,
    required this.numberFormatter,
  });

  final DashboardController controller;
  final NumberFormat currencyFormatter;
  final NumberFormat numberFormatter;

  @override
  Widget build(BuildContext context) {
    final products = controller.dashboardData?.topProducts ?? [];
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top 10 Products',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.neonGreen,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = products[index];

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.darkAccent),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.skuName, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(item.skuCode, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Text(
                          item.brand,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        numberFormatter.format(item.units),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(item.revenue),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neonGreen,
                        ),
                      ),
                      Text(
                        '${item.returnPct}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neonPink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DashboardKpiCard extends StatelessWidget {
  const _DashboardKpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, size: 20, color: accentColor),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
