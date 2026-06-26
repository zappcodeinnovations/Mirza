import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_icons.dart';
import '../../../models/trend_model.dart';

class TrendKpiGrid extends StatelessWidget {
  final TrendKpis kpis;

  const TrendKpiGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Performance Indicators",
          style: TextStyle(
            color: Color(0xFF223025),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildKpiCard('Momentum', '+${kpis.momentum.toStringAsFixed(1)}%', AppTheme.neonBlue),
            const SizedBox(width: 12),
            _buildKpiCard('Composite', kpis.compositeScore.toStringAsFixed(1), AppTheme.neonPurple),
            const SizedBox(width: 12),
            _buildKpiCard('Avg Score', kpis.avgScore.toStringAsFixed(1), AppTheme.neonOrange),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(AppIcons.trendingUp, color: AppTheme.neonGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Launch Recommendation',
                      style: TextStyle(color: Color(0xFF55605B), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kpis.launchRecommendation,
                      style: const TextStyle(
                        color: Color(0xFF223025),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF55605B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrendAiSummaryCard extends StatelessWidget {
  final TrendAiSummary aiData;

  const TrendAiSummaryCard({super.key, required this.aiData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.darkAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.activity, color: AppTheme.neonPink),
              const SizedBox(width: 10),
              const Text(
                "AI Market Summary",
                style: TextStyle(
                  color: Color(0xFF223025),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            aiData.summary,
            style: const TextStyle(
              color: Color(0xFF55605B),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (aiData.risksOpportunities.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFD9E1D6)),
            const SizedBox(height: 16),
            ...aiData.risksOpportunities.map((item) {
              final isRisk = item.type == 'risk';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isRisk ? AppIcons.warning : AppIcons.trendingUp,
                      color: isRisk ? AppTheme.neonPink : AppTheme.neonGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.text,
                        style: const TextStyle(
                          color: Color(0xFF223025),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ]
        ],
      ),
    );
  }
}

class TrendLineChart extends StatelessWidget {
  final List<TrendHistorical> historical;

  const TrendLineChart({super.key, required this.historical});

  @override
  Widget build(BuildContext context) {
    if (historical.isEmpty) return const SizedBox.shrink();

    // Parse dates to get X coordinates (just indexing for simplicity)
    final spots = historical.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.trendScore);
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.darkAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Historical Trend Score",
            style: TextStyle(
              color: Color(0xFF223025),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.neonBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.neonBlue.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrendMerchandiseCard extends StatelessWidget {
  final TrendMerchandise merchandise;

  const TrendMerchandiseCard({super.key, required this.merchandise});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.darkAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Merchandising Context",
            style: TextStyle(
              color: Color(0xFF223025),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          if (merchandise.priceContext != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Avg Price", style: TextStyle(color: Color(0xFF55605B))),
                Text(
                  "£${merchandise.priceContext!.avgPrice.toStringAsFixed(2)}",
                  style: const TextStyle(color: Color(0xFF223025), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sweet Spot", style: TextStyle(color: Color(0xFF55605B))),
                Text(
                  "£${merchandise.priceContext!.sweetLow.toStringAsFixed(2)} - £${merchandise.priceContext!.sweetHigh.toStringAsFixed(2)}",
                  style: const TextStyle(color: Color(0xFF223025), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Matched SKUs", style: TextStyle(color: Color(0xFF55605B))),
                Text(
                  "${merchandise.priceContext!.matchedSkuCount}",
                  style: const TextStyle(color: Color(0xFF223025), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFD9E1D6)),
            const SizedBox(height: 16),
          ],
          
          if (merchandise.bestBuyMonths.isNotEmpty) ...[
            const Text("Best Buy Months", style: TextStyle(color: Color(0xFF55605B))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: merchandise.bestBuyMonths.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.neonOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${m.month} (${m.avgScore.toInt()})",
                    style: const TextStyle(color: AppTheme.neonOrange, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }
}
