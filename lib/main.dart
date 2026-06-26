import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/forecasting_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/reports_controller.dart';
import 'controllers/new_launch_controller.dart';
import 'controllers/trend_controller.dart';
import 'controllers/competitors_controller.dart';
import 'controllers/sales_controller.dart';
import 'controllers/stock_controller.dart';
import 'controllers/weekly_sales_controller.dart';
import 'controllers/product_analytics_controller.dart';
import 'views/splash_view.dart';

import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => ForecastingController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => ReportsController()),
        ChangeNotifierProvider(create: (_) => NewLaunchController()),
        ChangeNotifierProvider(create: (_) => TrendController()),
        ChangeNotifierProvider(create: (_) => CompetitorsController()),
        ChangeNotifierProvider(create: (_) => SalesController()),
        ChangeNotifierProvider(create: (_) => StockController()),
        ChangeNotifierProvider(create: (_) => WeeklySalesController()),
        ChangeNotifierProvider(create: (_) => ProductAnalyticsController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirza Internationals BI & Inventory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashView(),
    );
  }
}
