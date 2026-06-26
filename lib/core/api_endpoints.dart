class ApiEndpoints {
  static const String baseUrl = "https://mirza.zappcode.in/api/mobile/";

  // Authentication & Signup Checks
  static const String registrationStatus = "registration-status/";
  static const String register = "register/";
  static const String login = "login/";
  static const String tokenRefresh = "token/refresh/";

  // Profile Management
  static const String profile = "profile/";
  static const String profileUpdate = "profile/update/";
  static const String forgotPassword = "profile/forgot-password/";
  static const String verifyOtp = "profile/verify-otp/";
  static const String resetPassword = "profile/reset-password/";
  static const String changePassword = "profile/change-password/";

  // Dashboard Data & Filters
  static const String dashboardFilters = "dashboard/filters/";
  static const String dashboardData = "dashboard/data/";

  // Products and Search
  static const String products = "products/";
  static String productDetails(String skuCode) => "products/$skuCode/";

  // Chatbot
  static const String chatbot = "chat/";

  // Returns Module
  static const String returns = "returns/";

  // Forecasting Module
  static const String forecasting = "forecasting/";

  // New Launch Module
  static const String newLaunch = "new-launch/";
  static String newLaunchDetails(String skuCode) => "new-launch/$skuCode/";

  // Regional Trends Keyword Module
  static const String trendSearch = "trend/search/";
  static const String trendPopular = "trend/popular/";
  static const String trendSuggest = "trend/suggest/";

  // Reports API & Table lists
  static const String overallReport = "reports/overall/";
  static const String overallReportDownload = "reports/overall/download/";

  static const String forecastReport = "reports/forecast/";
  static const String forecastReportDownload = "reports/forecast/download/";

  static const String overstockReport = "reports/overstock/";
  static const String overstockReportDownload = "reports/overstock/download/";

  static const String missingProducts = "missing-products/";
  static const String missingProductsDownload = "missing-products/download/";

  static const String weeklyReport = "weekly-report/";
  static const String weeklyReportDownload = "weekly-report/download/";

  // BI Competitors
  static const String competitors = "competitors/";

  // Sales Modules
  static const String sales = "sales/";
  static const String salesFilters = "sales/filters/";

  // Inventory & Stock Status Modules
  static const String stock = "stock/";
  static const String stockFilters = "stock/filters/";
  static const String stockDownload = "stock/download/";
  // static const String stockDownload = "stock/download/";

  // Weekly Sales Module
  static const String weeklySales = "weekly-sales/";
  static const String weeklySalesFilters = "weekly-sales/filters/";

  // Product Analytics
  static String productAnalytics(String sku) => "products/$sku/analytics/";
}
