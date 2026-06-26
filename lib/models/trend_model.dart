class TrendPopularKeyword {
  final String keyword;
  final double compositeScore;
  final double momentum;
  final double avgScore;
  final String launchRecommendation;
  final String fetchedAt;

  TrendPopularKeyword({
    required this.keyword,
    required this.compositeScore,
    required this.momentum,
    required this.avgScore,
    required this.launchRecommendation,
    required this.fetchedAt,
  });

  factory TrendPopularKeyword.fromJson(Map<String, dynamic> json) {
    return TrendPopularKeyword(
      keyword: json['keyword'] ?? '',
      compositeScore: (json['composite_score'] as num?)?.toDouble() ?? 0.0,
      momentum: (json['momentum'] as num?)?.toDouble() ?? 0.0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      launchRecommendation: json['launch_recommendation'] ?? '',
      fetchedAt: json['fetched_at'] ?? '',
    );
  }
}

class TrendSuggestion {
  final String label;
  final String value;
  final String source;

  TrendSuggestion({
    required this.label,
    required this.value,
    required this.source,
  });

  factory TrendSuggestion.fromJson(Map<String, dynamic> json) {
    return TrendSuggestion(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      source: json['source'] ?? '',
    );
  }
}

class TrendSearchResponse {
  final bool success;
  final String keyword;
  final String region;
  final TrendKpis? kpis;
  final List<TrendHistorical> historical;
  final TrendForecast? forecast;
  final List<TrendSeasonality> seasonality;
  final TrendRegions? regions;
  final TrendAiSummary? ai;
  final TrendMerchandise? merchandise;

  TrendSearchResponse({
    required this.success,
    required this.keyword,
    required this.region,
    this.kpis,
    required this.historical,
    this.forecast,
    required this.seasonality,
    this.regions,
    this.ai,
    this.merchandise,
  });

  factory TrendSearchResponse.fromJson(Map<String, dynamic> json) {
    return TrendSearchResponse(
      success: json['success'] ?? false,
      keyword: json['keyword'] ?? '',
      region: json['region'] ?? '',
      kpis: json['kpis'] != null ? TrendKpis.fromJson(json['kpis']) : null,
      historical: (json['historical'] as List<dynamic>?)
              ?.map((e) => TrendHistorical.fromJson(e))
              .toList() ??
          [],
      forecast: json['forecast'] != null ? TrendForecast.fromJson(json['forecast']) : null,
      seasonality: (json['seasonality'] as List<dynamic>?)
              ?.map((e) => TrendSeasonality.fromJson(e))
              .toList() ??
          [],
      regions: json['regions'] != null ? TrendRegions.fromJson(json['regions']) : null,
      ai: json['ai'] != null ? TrendAiSummary.fromJson(json['ai']) : null,
      merchandise: json['merchandise'] != null ? TrendMerchandise.fromJson(json['merchandise']) : null,
    );
  }
}

class TrendKpis {
  final double momentum;
  final double avgScore;
  final double peakScore;
  final double compositeScore;
  final double velocityScore;
  final String launchRecommendation;

  TrendKpis({
    required this.momentum,
    required this.avgScore,
    required this.peakScore,
    required this.compositeScore,
    required this.velocityScore,
    required this.launchRecommendation,
  });

  factory TrendKpis.fromJson(Map<String, dynamic> json) {
    return TrendKpis(
      momentum: (json['momentum'] as num?)?.toDouble() ?? 0.0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      peakScore: (json['peak_score'] as num?)?.toDouble() ?? 0.0,
      compositeScore: (json['composite_score'] as num?)?.toDouble() ?? 0.0,
      velocityScore: (json['velocity_score'] as num?)?.toDouble() ?? 0.0,
      launchRecommendation: json['launch_recommendation'] ?? '',
    );
  }
}

class TrendHistorical {
  final String date;
  final double trendScore;

  TrendHistorical({
    required this.date,
    required this.trendScore,
  });

  factory TrendHistorical.fromJson(Map<String, dynamic> json) {
    return TrendHistorical(
      date: json['date'] ?? '',
      trendScore: (json['trend_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TrendForecast {
  final List<String> dates;
  final List<double> values;
  final List<double> upper;
  final List<double> lower;

  TrendForecast({
    required this.dates,
    required this.values,
    required this.upper,
    required this.lower,
  });

  factory TrendForecast.fromJson(Map<String, dynamic> json) {
    return TrendForecast(
      dates: (json['dates'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      values: (json['values'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      upper: (json['upper'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      lower: (json['lower'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
    );
  }
}

class TrendSeasonality {
  final int week;
  final double avgScore;

  TrendSeasonality({
    required this.week,
    required this.avgScore,
  });

  factory TrendSeasonality.fromJson(Map<String, dynamic> json) {
    return TrendSeasonality(
      week: (json['week'] as num?)?.toInt() ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TrendRegions {
  final List<TrendRegionData> data;

  TrendRegions({required this.data});

  factory TrendRegions.fromJson(Map<String, dynamic> json) {
    return TrendRegions(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TrendRegionData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TrendRegionData {
  final double score;
  final String region;

  TrendRegionData({
    required this.score,
    required this.region,
  });

  factory TrendRegionData.fromJson(Map<String, dynamic> json) {
    return TrendRegionData(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      region: json['region'] ?? '',
    );
  }
}

class TrendAiSummary {
  final String summary;
  final List<TrendAiRiskOpportunity> risksOpportunities;

  TrendAiSummary({
    required this.summary,
    required this.risksOpportunities,
  });

  factory TrendAiSummary.fromJson(Map<String, dynamic> json) {
    return TrendAiSummary(
      summary: json['summary'] ?? '',
      risksOpportunities: (json['risks_opportunities'] as List<dynamic>?)
              ?.map((e) => TrendAiRiskOpportunity.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TrendAiRiskOpportunity {
  final String text;
  final String type; // 'risk' or 'opportunity'

  TrendAiRiskOpportunity({
    required this.text,
    required this.type,
  });

  factory TrendAiRiskOpportunity.fromJson(Map<String, dynamic> json) {
    return TrendAiRiskOpportunity(
      text: json['text'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class TrendMerchandise {
  final TrendPriceContext? priceContext;
  final List<TrendBestBuyMonth> bestBuyMonths;
  final TrendStockAlert? stockAlert;

  TrendMerchandise({
    this.priceContext,
    required this.bestBuyMonths,
    this.stockAlert,
  });

  factory TrendMerchandise.fromJson(Map<String, dynamic> json) {
    return TrendMerchandise(
      priceContext: json['price_context'] != null ? TrendPriceContext.fromJson(json['price_context']) : null,
      bestBuyMonths: (json['best_buy_months'] as List<dynamic>?)
              ?.map((e) => TrendBestBuyMonth.fromJson(e))
              .toList() ??
          [],
      stockAlert: json['stock_alert'] != null ? TrendStockAlert.fromJson(json['stock_alert']) : null,
    );
  }
}

class TrendPriceContext {
  final double avgPrice;
  final double maxPrice;
  final double minPrice;
  final double sweetLow;
  final double sweetHigh;
  final int matchedSkuCount;

  TrendPriceContext({
    required this.avgPrice,
    required this.maxPrice,
    required this.minPrice,
    required this.sweetLow,
    required this.sweetHigh,
    required this.matchedSkuCount,
  });

  factory TrendPriceContext.fromJson(Map<String, dynamic> json) {
    return TrendPriceContext(
      avgPrice: (json['avg_price'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['max_price'] as num?)?.toDouble() ?? 0.0,
      minPrice: (json['min_price'] as num?)?.toDouble() ?? 0.0,
      sweetLow: (json['sweet_low'] as num?)?.toDouble() ?? 0.0,
      sweetHigh: (json['sweet_high'] as num?)?.toDouble() ?? 0.0,
      matchedSkuCount: (json['matched_sku_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class TrendBestBuyMonth {
  final String month;
  final double avgScore;

  TrendBestBuyMonth({
    required this.month,
    required this.avgScore,
  });

  factory TrendBestBuyMonth.fromJson(Map<String, dynamic> json) {
    return TrendBestBuyMonth(
      month: json['month'] ?? '',
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TrendStockAlert {
  final String type;
  final String label;
  final double score;

  TrendStockAlert({
    required this.type,
    required this.label,
    required this.score,
  });

  factory TrendStockAlert.fromJson(Map<String, dynamic> json) {
    return TrendStockAlert(
      type: json['type'] ?? '',
      label: json['label'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
