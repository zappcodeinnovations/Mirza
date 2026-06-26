import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/reports_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import 'widgets/weekly_report_widgets.dart';

class WeeklyReportView extends StatefulWidget {
  const WeeklyReportView({super.key});

  @override
  State<WeeklyReportView> createState() => _WeeklyReportViewState();
}

class _WeeklyReportViewState extends State<WeeklyReportView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ReportsController>(context, listen: false);
      if (controller.weeklyReportData == null) {
        controller.loadWeeklyReport();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReportsController>(context);
    final data = controller.weeklyReportData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weekly Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.download),
            tooltip: 'Download Report',
            onPressed: () async {
              bool? isExcel = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Download Weekly Report'),
                  content: const Text('Select the file format to download.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CSV'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excel'),
                    ),
                  ],
                ),
              );

              if (isExcel == null) return; // User cancelled

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Starting ${isExcel ? "Excel" : "CSV"} download...')),
                );
              }

              bool success = await controller.downloadWeeklyReport(isExcel: isExcel);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Download Successful' : 'Download Failed'),
                    backgroundColor: success ? AppTheme.neonGreen : AppTheme.neonPink,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            )
          : data == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage ?? 'No data available.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.loadWeeklyReport(),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => controller.loadWeeklyReport(),
                  color: AppTheme.neonBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          data.kpis.weekLabel,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        WeeklyKpiCards(kpis: data.kpis),
                        const SizedBox(height: 24),
                        WeeklyLast4WeeksChart(data: data.last4Weeks),
                        const SizedBox(height: 24),
                        WeeklyMonthlyComparisonChart(comparison: data.monthlyComparison),
                        const SizedBox(height: 24),
                        WeeklyBrandPortalTable(brandTable: data.brandPortalTable),
                        const SizedBox(height: 24),
                        WeeklyReturnRatesTable(returnRates: data.returnRateTable, months: data.returnRateMonths),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }
}
