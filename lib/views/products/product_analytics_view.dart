import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../controllers/product_analytics_controller.dart';
import '../../models/product_analytics_model.dart';
import '../../core/app_theme.dart';

class ProductAnalyticsView extends StatefulWidget {
  final String skuCode;

  const ProductAnalyticsView({super.key, required this.skuCode});

  @override
  State<ProductAnalyticsView> createState() => _ProductAnalyticsViewState();
}

class _ProductAnalyticsViewState extends State<ProductAnalyticsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductAnalyticsController>().loadAnalytics(widget.skuCode);
    });
  }

  void _onTimeframeSelected(String timeframe) {
    if (timeframe == 'Custom') {
      context.read<ProductAnalyticsController>().setTimeframe(
        'Custom', 
        widget.skuCode,
        from: '2026-04-12',
        to: '2026-05-24'
      );
    } else {
      context.read<ProductAnalyticsController>().setTimeframe(timeframe, widget.skuCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF223025)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics - ${widget.skuCode}',
          style: const TextStyle(
            color: Color(0xFF223025),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ProductAnalyticsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            );
          }

          if (controller.errorMessage != null && controller.analyticsData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: AppTheme.neonPink),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadAnalytics(widget.skuCode),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonBlue),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = controller.analyticsData;
          if (data == null) {
            return const Center(
              child: Text(
                'No analytics data available.',
                style: TextStyle(color: Color(0xFF55605B)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeframeSelector(controller.selectedTimeframe),
                const SizedBox(height: 30),
                if (data.kpis != null) _buildKpiGrid(data.kpis!),
                const SizedBox(height: 30),
                
                if (data.weeklySales.isNotEmpty) ...[
                  const Text(
                    'Weekly Revenue Trend',
                    style: TextStyle(
                      color: Color(0xFF223025),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRevenueChart(data.weeklySales),
                  const SizedBox(height: 30),
                ],

                if (data.weeklyStock.isNotEmpty) ...[
                  const Text(
                    'Stock Burndown',
                    style: TextStyle(
                      color: Color(0xFF223025),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStockChart(data.weeklyStock),
                  const SizedBox(height: 30),
                ],

                if (data.seasonSales.isNotEmpty) ...[
                  const Text(
                    'Sales By Season',
                    style: TextStyle(
                      color: Color(0xFF223025),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSeasonSalesChart(data.seasonSales),
                  const SizedBox(height: 30),
                ],

                if (data.citySales.isNotEmpty) ...[
                  const Text(
                    'Top Cities',
                    style: TextStyle(
                      color: Color(0xFF223025),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCitySalesChart(data.citySales),
                  const SizedBox(height: 30),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeframeSelector(String selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('All', selected == 'All'),
          _buildChip('8 Weeks', selected == '8 Weeks'),
          _buildChip('Custom', selected == 'Custom'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) _onTimeframeSelected(label);
        },
        selectedColor: AppTheme.neonBlue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF55605B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.neonBlue : AppTheme.darkAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(ProductAnalyticsKpi kpis) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildKpiCard('Total Revenue', '£${kpis.totalRevenue.toStringAsFixed(2)}'),
        _buildKpiCard('Total Sold', '${kpis.totalSold}'),
        _buildKpiCard('Total Returns', '${kpis.totalReturns}'),
        _buildKpiCard('Avg Weekly Sales', '${kpis.avgWeeklySales.toStringAsFixed(1)}'),
        _buildKpiCard('Num Weeks', '${kpis.numWeeks}'),
        _buildKpiCard('Amount Lost', '£${kpis.amountLost.toStringAsFixed(2)}', isNegative: true),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, {bool isNegative = false}) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkAccent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF55605B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isNegative ? AppTheme.neonPink : const Color(0xFF223025),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<WeeklySalesData> sales) {
    if (sales.isEmpty) return const SizedBox.shrink();

    final spots = sales.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.revenue);
    }).toList();

    double maxY = sales.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 10;

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkAccent),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          final animatedSpots = spots.map((e) => FlSpot(e.x, e.y * animValue)).toList();
          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppTheme.darkAccent,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: (spots.length / 5).ceilToDouble().clamp(1.0, double.infinity),
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < sales.length) {
                        String label = sales[idx].week;
                        if (label.length > 5) {
                          label = label.substring(label.length - 5);
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Color(0xFF55605B),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxY / 4).clamp(1.0, double.infinity),
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF55605B),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: 0,
              maxY: maxY * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: animatedSpots,
                  isCurved: true,
                  color: AppTheme.neonBlue,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonBlue.withValues(alpha: 0.3),
                        AppTheme.neonBlue.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 150),
            curve: Curves.linear,
          );
        },
      ),
    );
  }

  Widget _buildStockChart(List<WeeklyStockData> stockData) {
    if (stockData.isEmpty) return const SizedBox.shrink();

    final spots = stockData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.remainingStock);
    }).toList();

    double maxY = stockData.map((e) => e.remainingStock).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 10;

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkAccent),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          final animatedSpots = spots.map((e) => FlSpot(e.x, e.y * animValue)).toList();
          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppTheme.darkAccent,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: (spots.length / 5).ceilToDouble().clamp(1.0, double.infinity),
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < stockData.length) {
                        String label = stockData[idx].week;
                        if (label.length > 5) label = label.substring(label.length - 5);
                        return SideTitleWidget(
                          meta: meta,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(label, style: const TextStyle(color: Color(0xFF55605B), fontSize: 10)),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxY / 4).clamp(1.0, double.infinity),
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Color(0xFF55605B), fontSize: 10),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: 0,
              maxY: maxY * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: animatedSpots,
                  isCurved: true,
                  color: AppTheme.neonPink,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonPink.withValues(alpha: 0.3),
                        AppTheme.neonPink.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 150),
            curve: Curves.linear,
          );
        },
      ),
    );
  }

  Widget _buildSeasonSalesChart(List<SeasonSalesData> seasonSales) {
    if (seasonSales.isEmpty) return const SizedBox.shrink();

    double maxY = seasonSales.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 10;

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkAccent),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < seasonSales.length) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            seasonSales[idx].season,
                            style: const TextStyle(color: Color(0xFF55605B), fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxY / 4).clamp(1.0, double.infinity),
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Color(0xFF55605B), fontSize: 10),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppTheme.darkAccent,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: seasonSales.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.revenue * animValue,
                      color: AppTheme.neonGreen,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                );
              }).toList(),
            ),
            duration: const Duration(milliseconds: 150),
            curve: Curves.linear,
          );
        },
      ),
    );
  }

  Widget _buildCitySalesChart(List<CitySalesData> citySales) {
    if (citySales.isEmpty) return const SizedBox.shrink();

    // Show top 5 cities
    final topCities = citySales.take(5).toList();
    double maxY = topCities.map((e) => e.qty.toDouble()).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 10;

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkAccent),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < topCities.length) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              topCities[idx].city,
                              style: const TextStyle(color: Color(0xFF55605B), fontSize: 9),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxY / 4).clamp(1.0, double.infinity),
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Color(0xFF55605B), fontSize: 10),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppTheme.darkAccent,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: topCities.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.qty.toDouble() * animValue,
                      color: Colors.purpleAccent,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                );
              }).toList(),
            ),
            duration: const Duration(milliseconds: 150),
            curve: Curves.linear,
          );
        },
      ),
    );
  }
}
