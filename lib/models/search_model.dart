class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String? imageUrl;
  final Map<String, dynamic>? data;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.imageUrl,
    this.data,
  });
}

class SearchCategory {
  final String name;
  final String icon;
  final List<SearchResult> results;

  SearchCategory({
    required this.name,
    required this.icon,
    required this.results,
  });
}
