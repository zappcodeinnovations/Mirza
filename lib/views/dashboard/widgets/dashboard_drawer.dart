import 'package:flutter/material.dart';
import 'dart:io';

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
import '../../punch_order/punch_order_view.dart';
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
              icon: Icons.assignment_outlined,
              title: "Punch Order",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PunchOrderView()),
                );
              },
            ),

            DashboardDrawerItem(
              icon: AppIcons.trendingUp,
              title: "New Launch",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewLaunchView()),
                );
              },
            ),

            /*
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
            */

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

            /*
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
            */

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

            /*
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
            */

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Consumer<AuthController>(
                    builder: (context, auth, _) {
                      if (Platform.isIOS && auth.isAdminRegistrationEnabled) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.neonPink,
                                side: const BorderSide(color: AppTheme.neonPink),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _showDeleteAccountDialog(context, auth),
                              icon: const Icon(Icons.delete_forever),
                              label: const Text("Delete Account"),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(
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
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(AppIcons.logout),
                      label: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.logout();
    if (context.mounted) {
       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _showDeleteAccountDialog(BuildContext context, AuthController authController) {
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.darkSurface,
              title: const Text('Delete Account', style: TextStyle(color: AppTheme.neonPink, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: AppTheme.darkBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (authController.errorMessage != null) ...[
                     const SizedBox(height: 8),
                     Text(authController.errorMessage!, style: const TextStyle(color: AppTheme.neonPink, fontSize: 12)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (passwordController.text.isEmpty) return;
                    setState(() => isLoading = true);
                    final success = await authController.deleteAccount(passwordController.text);
                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account permanently deleted.'), backgroundColor: AppTheme.neonGreen),
                      );
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    } else if (ctx.mounted) {
                      setState(() => isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPink),
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
