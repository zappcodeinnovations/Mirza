import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../core/app_theme.dart';

class DashboardDonutChartSection extends StatefulWidget {
  const DashboardDonutChartSection({
    super.key,
    required this.title,
    required this.labels,
    required this.values,
  });

  final String title;
  final List<String> labels;
  final List<double> values;

  @override
  State<DashboardDonutChartSection> createState() =>
      _DashboardDonutChartSectionState();
}

class _DashboardDonutChartSectionState
    extends State<DashboardDonutChartSection> {
  int touchedIndex = -1;

  Color getColorFromLabel(String label, int index) {
    switch (label.toLowerCase()) {
      case 'black': return Colors.black;
      case 'tan': return const Color(0xFFD2B48C);
      case 'brown': return Colors.brown;
      case 'wood': return const Color(0xFF8B5A2B);
      case 'mink': return const Color(0xFF8D6E63);
      case 'cognac': return const Color(0xFF9A4D1E);
      case 'ash': return Colors.grey;
      case 'white': return Colors.white;
      case 'silver': return Colors.grey.shade400;
      case 'universe': return Colors.deepPurple;
      case 'others': return AppTheme.neonBlue;
      case 'leather': return const Color(0xFF7B3F00);
      case 'suede': return const Color(0xFFA1887F);
      case 'patent leather': return const Color(0xFF4E342E);
      case 'pu': return Colors.blueGrey;
      default:
        final palette = [
          AppTheme.neonGreen,
          AppTheme.neonBlue,
          AppTheme.neonPink,
          AppTheme.neonOrange,
          AppTheme.neonPurple,
          const Color(0xFF4A90E2),
          const Color(0xFFF5A623),
          const Color(0xFF9013FE),
          const Color(0xFF50E3C2),
        ];
        return palette[index % palette.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.labels.isEmpty || widget.values.isEmpty) {
      return const SizedBox();
    }

    final theme = Theme.of(context);

    final total = widget.values.fold<double>(0, (sum, item) => sum + item);

    List<Map<String, dynamic>> chartData = [];

    for (int i = 0; i < widget.labels.length; i++) {
      chartData.add({'label': widget.labels[i], 'value': widget.values[i]});
    }

    chartData.sort(
      (a, b) => (b['value'] as double).compareTo(a['value'] as double),
    );

    final topItems = chartData.take(5).toList();

    double othersTotal = 0;

    if (chartData.length > 5) {
      for (var item in chartData.skip(5)) {
        othersTotal += item['value'] as double;
      }

      topItems.add({'label': 'Others', 'value': othersTotal});
    }

    if (total <= 0) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppTheme.darkAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }

                          touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),

                    sectionsSpace: 4,
                    centerSpaceRadius: 70,
                    borderData: FlBorderData(show: false),

                    sections: List.generate(topItems.length, (index) {
                      final isTouched = index == touchedIndex;

                      final value = topItems[index]['value'] as double;
                      final percentage = (value / total) * 100;

                      return PieChartSectionData(
                        borderSide: isTouched
                            ? BorderSide(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              )
                            : BorderSide.none,
                        color: getColorFromLabel(topItems[index]['label'], index),
                        value: value,

                        title: percentage < 6
                            ? ''
                            : '${percentage.toStringAsFixed(1)}%',
                        radius: isTouched ? 70 : 45,
                        titleStyle: TextStyle(
                          fontSize: isTouched ? 14 : 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),

                        badgeWidget: isTouched
                            ? _ChartBadge(
                                label: widget.labels[index],
                                value: value,
                                percentage: percentage,
                              )
                            : null,

                        badgePositionPercentageOffset: 0.95,
                      );
                    }),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            touchedIndex == -1
                                ? total.toStringAsFixed(0)
                                : widget.values[touchedIndex].toStringAsFixed(
                                    0,
                                  ),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            touchedIndex == -1
                                ? 'Total Units'
                                : widget.labels[touchedIndex],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.72,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: getColorFromLabel(topItems[index]['label'], index),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: getColorFromLabel(topItems[index]['label'], index),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        topItems[index]['label'],
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBadge extends StatelessWidget {
  const _ChartBadge({
    required this.label,
    required this.value,
    required this.percentage,
  });

  final String label;
  final double value;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 96, maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkAccent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Units: ${value.toStringAsFixed(0)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.72),
            ),
          ),

          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardReturnAnalysisChart extends StatefulWidget {
  const DashboardReturnAnalysisChart({super.key, required this.controller});

  final DashboardController controller;

  @override
  State<DashboardReturnAnalysisChart> createState() => _DashboardReturnAnalysisChartState();
}

class _DashboardReturnAnalysisChartState extends State<DashboardReturnAnalysisChart> {
  bool _showData = false;

  void _checkVisibility() {
    if (!mounted || _showData) return;
    
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final position = renderObject.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      
      // If the top of the chart is visible in the viewport
      if (position.dy < screenHeight - 100) {
        setState(() {
          _showData = true;
        });
        return;
      }
    }
    
    if (mounted && !_showData) {
      Future.delayed(const Duration(milliseconds: 100), _checkVisibility);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chart = widget.controller.dashboardData?.returnAnalysis;

    if (chart == null || chart.labels.isEmpty || chart.values.isEmpty) {
      return const SizedBox();
    }

    final theme = Theme.of(context);
    final maxValue = chart.values.fold<double>(0, (max, v) => v > max ? v : max);
    final maxY = maxValue > 0 ? (maxValue * 1.2) : 10.0;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkAccent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Return Analysis',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
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
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chart.labels.length) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: Transform.translate(
                              offset: const Offset(-30, 0),
                              child: Transform.rotate(
                                angle: -0.7,
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 60,
                                  child: Text(
                                    chart.labels[index],
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(chart.labels.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: _showData ? chart.values[index] : 0,
                        color: AppTheme.neonPink,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppTheme.darkBg,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 1200),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}
class DashboardSeasonalChart extends StatelessWidget {
  const DashboardSeasonalChart({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final chart = controller.dashboardData?.seasonalTop;

    if (chart == null || chart.labels.isEmpty || chart.values.isEmpty) {
      return const SizedBox();
    }

    return _DashboardBarChartSection(
      title: 'Seasonal Performance',
      labels: chart.labels,
      values: chart.values,
      accentColor: AppTheme.neonBlue,
      valueSuffix: '',
    );
  }
}

class DashboardCityWiseChart extends StatelessWidget {
  const DashboardCityWiseChart({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final chart = controller.dashboardData?.cityProducts;

    if (chart == null || chart.products.isEmpty || chart.values.isEmpty) {
      return const SizedBox();
    }

    return DashboardDonutChartSection(
      title: 'City Wise Products',
      labels: chart.products,
      values: chart.values,
    );
  }
}

class _DashboardBarChartSection extends StatelessWidget {
  const _DashboardBarChartSection({
    required this.title,
    required this.labels,
    required this.values,
    required this.accentColor,
    required this.valueSuffix,
  });

  final String title;
  final List<String> labels;
  final List<double> values;
  final Color accentColor;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty || values.isEmpty) {
      return const SizedBox();
    }

    final theme = Theme.of(context);

    final itemCount = labels.length < values.length
        ? labels.length
        : values.length;
    final visibleCount = itemCount > 6 ? 6 : itemCount;
    final maxValue = values
        .take(visibleCount)
        .fold<double>(0, (max, value) => value > max ? value : max);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkAccent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ...List<Widget>.generate(visibleCount, (index) {
            final ratio = maxValue <= 0 ? 0.0 : values[index] / maxValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          labels[index],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        valueSuffix.isEmpty
                            ? values[index].toStringAsFixed(1)
                            : '${values[index].toStringAsFixed(1)}$valueSuffix',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: ratio,
                      backgroundColor: AppTheme.darkBg,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DashboardDonutPainter extends CustomPainter {
  _DashboardDonutPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, item) => sum + item);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.22;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final backgroundPaint = Paint()
      ..color = AppTheme.darkBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, math.pi * 2, false, backgroundPaint);

    if (total <= 0) {
      return;
    }

    var startAngle = -math.pi / 2;
    for (var index = 0; index < values.length; index++) {
      final sweepAngle = (values[index] / total) * math.pi * 2;
      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    final centerPaint = Paint()
      ..color = AppTheme.darkSurface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth * 0.9, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _DashboardDonutPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
