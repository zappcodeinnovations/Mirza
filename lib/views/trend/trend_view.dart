import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/trend_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import '../../models/trend_model.dart';
import 'widgets/trend_widgets.dart';

class TrendView extends StatefulWidget {
  const TrendView({super.key});

  @override
  State<TrendView> createState() => _TrendViewState();
}

class _TrendViewState extends State<TrendView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrendController>().loadPopularKeywords();
    });

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
        });
        if (query.isNotEmpty && query.length >= 2) {
          // Only passing brand as 'OFF THE HOOK' based on API payload example,
          // ideally this would be dynamic if there was a brand picker.
          context.read<TrendController>().loadSuggestions(
            brand: 'OFF THE HOOK',
            gender: 'Women',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String keyword) {
    if (keyword.isEmpty) return;
    _searchController.text = keyword;
    _searchFocusNode.unfocus();
    context.read<TrendController>().searchTrend(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            Expanded(
              child: Consumer<TrendController>(
                builder: (context, controller, child) {
                  if (controller.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.neonPurple,
                      ),
                    );
                  }

                  // SHOW SEARCH RESULTS
                  if (controller.searchResult != null) {
                    return _buildSearchResults(controller.searchResult!);
                  }

                  // SHOW SUGGESTIONS IF TYPING
                  if (_searchFocusNode.hasFocus && _searchQuery.isNotEmpty) {
                    return _buildSuggestions(controller);
                  }

                  // OTHERWISE SHOW POPULAR KEYWORDS
                  return _buildPopularKeywords(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(AppIcons.back, color: Color(0xFF223025)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          const Text(
            "SEO Data Import",
            style: TextStyle(
              color: Color(0xFF223025),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkAccent),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Color(0xFF223025)),
                decoration: const InputDecoration(
                  hintText: 'Search keywords, trends...',
                  hintStyle: TextStyle(color: Color(0xFF55605B)),
                  prefixIcon: Icon(
                    AppIcons.search,
                    color: Color(0xFF55605B),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: _submitSearch,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _submitSearch(_searchController.text.trim()),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(AppIcons.search, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(TrendController controller) {
    if (controller.isSuggesting && controller.suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Loading suggestions...",
          style: TextStyle(color: Color(0xFF55605B)),
        ),
      );
    }

    if (controller.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = controller.suggestions[index];
        return ListTile(
          leading: const Icon(AppIcons.trendingUp, color: AppTheme.neonPurple),
          title: Text(
            suggestion.label,
            style: const TextStyle(
              color: Color(0xFF223025),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Source: ${suggestion.source}',
            style: const TextStyle(color: Color(0xFF55605B), fontSize: 12),
          ),
          onTap: () => _submitSearch(suggestion.value),
        );
      },
    );
  }

  Widget _buildPopularKeywords(TrendController controller) {
    if (controller.isLoadingPopular) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.neonPurple),
      );
    }

    if (controller.popularErrorMessage != null) {
      return Center(
        child: Text(
          controller.popularErrorMessage!,
          style: const TextStyle(color: AppTheme.neonPink),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Popular Keywords",
            style: TextStyle(
              color: Color(0xFF223025),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadPopularKeywords(),
              color: AppTheme.neonPurple,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.popularKeywords.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pk = controller.popularKeywords[index];
                  return InkWell(
                    onTap: () => _submitSearch(pk.keyword),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.darkAccent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  AppIcons.activity,
                                  color: AppTheme.neonBlue,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pk.keyword,
                                    style: const TextStyle(
                                      color: Color(0xFF223025),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pk.launchRecommendation,
                                    style: const TextStyle(
                                      color: Color(0xFF55605B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                pk.avgScore.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppTheme.neonPurple,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
                                "Avg Score",
                                style: TextStyle(
                                  color: Color(0xFF55605B),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(TrendSearchResponse data) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<TrendController>().searchTrend(data.keyword);
      },
      color: AppTheme.neonPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Results for "${data.keyword}"',
                  style: const TextStyle(
                    color: Color(0xFF223025),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.neonBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.region,
                    style: const TextStyle(
                      color: AppTheme.neonBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// KPIS
            if (data.kpis != null) ...[
              TrendKpiGrid(kpis: data.kpis!),
              const SizedBox(height: 24),
            ],

            /// AI SUMMARY
            if (data.ai != null) ...[
              TrendAiSummaryCard(aiData: data.ai!),
              const SizedBox(height: 24),
            ],

            /// HISTORICAL CHART
            if (data.historical.isNotEmpty) ...[
              TrendLineChart(historical: data.historical),
              const SizedBox(height: 24),
            ],

            /// MERCHANDISE
            if (data.merchandise != null) ...[
              TrendMerchandiseCard(merchandise: data.merchandise!),
              const SizedBox(height: 40), // Bottom padding
            ],
          ],
        ),
      ),
    );
  }
}
