import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../models/weekly_report_model.dart';

final currencyFormatter = NumberFormat.currency(symbol: '€', decimalDigits: 0);

class WeeklyKpiCards extends StatelessWidget {
  final WeeklyKpisModel kpis;
  const WeeklyKpiCards({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                context,
                title: 'OTH Gross',
                value: currencyFormatter.format(kpis.othLastWeekGross),
                pctChange: kpis.othPctChange,
                icon: Icons.show_chart,
                color: AppTheme.neonBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                context,
                title: 'TC Gross',
                value: currencyFormatter.format(kpis.tcLastWeekGross),
                pctChange: kpis.tcPctChange,
                icon: Icons.stacked_line_chart,
                color: AppTheme.neonGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                context,
                title: 'OTH Returns',
                value: currencyFormatter.format(kpis.othReturns),
                pctChange: 0,
                icon: Icons.keyboard_return,
                color: AppTheme.neonPink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                context,
                title: 'TC Returns',
                value: currencyFormatter.format(kpis.tcReturns),
                pctChange: 0,
                icon: Icons.keyboard_return,
                color: AppTheme.neonPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required double pctChange,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isPositive = pctChange >= 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (pctChange != 0)
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? AppTheme.neonGreen : AppTheme.neonPink,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${pctChange.abs().toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPositive ? AppTheme.neonGreen : AppTheme.neonPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyLast4WeeksChart extends StatefulWidget {
  final List<Last4WeeksModel> data;
  const WeeklyLast4WeeksChart({super.key, required this.data});

  @override
  State<WeeklyLast4WeeksChart> createState() => _WeeklyLast4WeeksChartState();
}

class _WeeklyLast4WeeksChartState extends State<WeeklyLast4WeeksChart> {
  bool _showData = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showData = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.data.isEmpty) return const SizedBox.shrink();

    double maxY = 0;
    for (var item in widget.data) {
      if (item.total > maxY) maxY = item.total.toDouble();
    }
    maxY = maxY * 1.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Last 4 Weeks Performance",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY == 0 ? 100 : maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (!_showData) return null;
                      String label = '';
                      if (rodIndex == 0) label = 'OTH';
                      if (rodIndex == 1) label = 'TC';
                      return BarTooltipItem(
                        '$label\n${currencyFormatter.format(rod.toY)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= widget.data.length) return const SizedBox.shrink();
                        // Truncate week label to fit
                        String label = widget.data[index].week;
                        if (label.length > 6) {
                          label = label.substring(0, 6);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == maxY) return const SizedBox.shrink();
                        return Text(
                          NumberFormat.compact().format(value),
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: widget.data.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: _showData ? item.oth.toDouble() : 0,
                        color: AppTheme.neonBlue,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: _showData ? item.tc.toDouble() : 0,
                        color: AppTheme.neonGreen,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutQuart,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppTheme.neonBlue, 'OTH'),
              const SizedBox(width: 16),
              _buildLegend(AppTheme.neonGreen, 'TC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class WeeklyMonthlyComparisonChart extends StatefulWidget {
  final MonthlyComparisonModel comparison;
  const WeeklyMonthlyComparisonChart({super.key, required this.comparison});

  @override
  State<WeeklyMonthlyComparisonChart> createState() => _WeeklyMonthlyComparisonChartState();
}

class _WeeklyMonthlyComparisonChartState extends State<WeeklyMonthlyComparisonChart> {
  bool _showData = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showData = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.comparison.oth.isEmpty) return const SizedBox.shrink();

    // Since both OTH and TC have same months, just use OTH length
    double maxY = 0;
    for (var item in widget.comparison.oth) {
      if (item.current > maxY) maxY = item.current.toDouble();
      if (item.previous > maxY) maxY = item.previous.toDouble();
    }
    for (var item in widget.comparison.tc) {
      if (item.current > maxY) maxY = item.current.toDouble();
      if (item.previous > maxY) maxY = item.previous.toDouble();
    }
    maxY = maxY * 1.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monthly Comparison (OTH)",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY == 0 ? 100 : maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (!_showData) return null;
                      String label = rodIndex == 0 ? 'Current' : 'Previous';
                      return BarTooltipItem(
                        '$label\n${currencyFormatter.format(rod.toY)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= widget.comparison.oth.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            widget.comparison.oth[index].month.substring(0, 3), // Show 'Jan', 'Feb'
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == maxY) return const SizedBox.shrink();
                        return Text(
                          NumberFormat.compact().format(value),
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: widget.comparison.oth.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: _showData ? item.current.toDouble() : 0,
                        color: AppTheme.neonBlue,
                        width: 8,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      BarChartRodData(
                        toY: _showData ? item.previous.toDouble() : 0,
                        color: AppTheme.neonBlue.withOpacity(0.3),
                        width: 8,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutQuart,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppTheme.neonBlue, 'Current'),
              const SizedBox(width: 16),
              _buildLegend(AppTheme.neonBlue.withOpacity(0.3), 'Previous'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class WeeklyReturnRatesTable extends StatelessWidget {
  final List<ReturnRateTableModel> returnRates;
  final List<String> months;
  
  const WeeklyReturnRatesTable({
    super.key,
    required this.returnRates,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (returnRates.isEmpty || months.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Return Rates %",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
              columns: [
                const DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                ...months.map((m) => DataColumn(label: Text(m, style: const TextStyle(fontWeight: FontWeight.bold)))),
              ],
              rows: returnRates.map((rateData) {
                return DataRow(
                  cells: [
                    DataCell(Text(rateData.category, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ...months.map((m) {
                      double val = rateData.rates[m] ?? 0.0;
                      return DataCell(Text('$val%'));
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyBrandPortalTable extends StatelessWidget {
  final List<BrandPortalTableModel> brandTable;
  const WeeklyBrandPortalTable({super.key, required this.brandTable});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (brandTable.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Brand Portal Metrics",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
              columns: const [
                DataColumn(label: Text('Label', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('UK', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ASOS EU', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('NEXT', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: brandTable.map((row) {
                bool isTotal = row.label.toLowerCase().contains('total');
                var textStyle = isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null;
                return DataRow(
                  cells: [
                    DataCell(Text(row.label, style: textStyle)),
                    DataCell(Text(NumberFormat.compact().format(row.uk), style: textStyle)),
                    DataCell(Text(NumberFormat.compact().format(row.asosEu), style: textStyle)),
                    DataCell(Text(NumberFormat.compact().format(row.next), style: textStyle)),
                    DataCell(Text(currencyFormatter.format(row.total), style: textStyle?.copyWith(color: AppTheme.neonBlue))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
