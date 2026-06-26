import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/app_icons.dart';
import '../../../core/app_theme.dart';
import '../../forecasting/forecasting_view.dart';
import '../../new_launch/new_launch_view.dart';
import '../../trend/trend_view.dart';
import '../../missing_products/missing_products_view.dart';
import '../../weekly_report/weekly_report_view.dart';
import '../../competitors/competitors_view.dart';
import '../../sales/sales_view.dart';
import '../../stock/stock_view.dart';
import '../../weekly_sales/weekly_sales_view.dart';
import 'dashboard_drawer_item.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.darkSurface,
      child: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Consumer<AuthController>(
              builder: (context, auth, _) {
                final user = auth.currentUser;
                final name = user != null ? '${user.firstName} ${user.lastName}'.trim() : 'User';
                final email = user?.email ?? '';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        child: Icon(
                          AppIcons.person,
                          size: 42,
                          color: AppTheme.darkBg,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name.isEmpty ? 'Mirza Admin' : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.isEmpty ? 'admin@mirza.com' : email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              },
            ),

            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

            DashboardDrawerItem(
              icon: AppIcons.forecast,
              title: "Forecasting",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForecastingView()),
                );
              },
            ),
            
            DashboardDrawerItem(
              icon: AppIcons.trendingUp,
              title: "New Launches",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewLaunchView()),
                );
              },
            ),

            DashboardDrawerItem(
              icon: AppIcons.search,
              title: "SEO Data Import",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrendView()),
                );
              },
            ),

            DashboardDrawerItem(
              icon: Icons.calendar_view_week,
              title: "Weekly Report",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyReportView()),
                );
              },
            ),

            DashboardDrawerItem(
              icon: Icons.error_outline,
              title: "Missing Products",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MissingProductsView()),
                );
              },
            ),

            DashboardDrawerItem(
              icon: Icons.storefront,
              title: "Competitors",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompetitorsView()),
                );
              },
            ),

            DashboardDrawerItem(
              icon: Icons.shopping_cart_checkout,
              title: "Sales",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesView()),
                );
              },
            ),

            DashboardDrawerItem(
              icon: Icons.calendar_view_month_outlined,
              title: "Weekly Sales",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklySalesView()),
                );
              },
            ),

            DashboardDrawerItem(
              icon: Icons.inventory_2_outlined,
              title: "Stock",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StockView()),
                );
              },
            ),

                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonPink,

                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 14),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: () {},

                  icon: const Icon(AppIcons.logout),

                  label: const Text("Logout"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
