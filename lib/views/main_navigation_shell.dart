import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/reports_controller.dart';
import '../core/app_icons.dart';
import '../core/app_theme.dart';
import 'dashboard/dashboard_view.dart';
import 'products/product_list_view.dart';
import 'reports/reports_view.dart';
import 'profile/profile_view.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    ProductListView(),
    ReportsView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize Dashboard data & Reports in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('MainNavigationShell: initializing dashboard and reports');
      Provider.of<DashboardController>(
        context,
        listen: false,
      ).initializeDashboard();
      Provider.of<ReportsController>(context, listen: false).loadAllReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.darkAccent, width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(AppIcons.dashboard),
              activeIcon: Icon(AppIcons.dashboardFilled, color: AppTheme.neonGreen),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.products),
              activeIcon: Icon(AppIcons.productsFilled, color: AppTheme.neonGreen),
              label: "Products",
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.reports),
              activeIcon: Icon(AppIcons.reportsFilled, color: AppTheme.neonGreen),
              label: "Reports",
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.profile),
              activeIcon: Icon(AppIcons.profileFilled, color: AppTheme.neonGreen),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
