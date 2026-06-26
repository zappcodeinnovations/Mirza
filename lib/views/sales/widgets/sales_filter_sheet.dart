import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class SalesFilterSheet extends StatefulWidget {
  final List<String> availablePlatforms;
  final List<String> availableBrands;
  final List<String> initiallySelectedPlatforms;
  final List<String> initiallySelectedBrands;
  final Function(List<String> platforms, List<String> brands) onApply;

  const SalesFilterSheet({
    super.key,
    required this.availablePlatforms,
    required this.availableBrands,
    required this.initiallySelectedPlatforms,
    required this.initiallySelectedBrands,
    required this.onApply,
  });

  @override
  State<SalesFilterSheet> createState() => _SalesFilterSheetState();
}

class _SalesFilterSheetState extends State<SalesFilterSheet> {
  late List<String> _selectedPlatforms;
  late List<String> _selectedBrands;

  @override
  void initState() {
    super.initState();
    _selectedPlatforms = List.from(widget.initiallySelectedPlatforms);
    _selectedBrands = List.from(widget.initiallySelectedBrands);
  }

  void _togglePlatform(String platform) {
    setState(() {
      if (_selectedPlatforms.contains(platform)) {
        _selectedPlatforms.remove(platform);
      } else {
        _selectedPlatforms.add(platform);
      }
    });
  }

  void _toggleBrand(String brand) {
    setState(() {
      if (_selectedBrands.contains(brand)) {
        _selectedBrands.remove(brand);
      } else {
        _selectedBrands.add(brand);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedPlatforms.clear();
      _selectedBrands.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Sales',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSectionTitle(theme, 'Brands'),
                  const SizedBox(height: 12),
                  widget.availableBrands.isEmpty
                      ? const Text('No brands available.')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.availableBrands.map((brand) {
                            final isSelected = _selectedBrands.contains(brand);
                            return FilterChip(
                              label: Text(brand),
                              selected: isSelected,
                              onSelected: (_) => _toggleBrand(brand),
                              selectedColor: AppTheme.neonBlue.withOpacity(0.2),
                              checkmarkColor: AppTheme.neonBlue,
                              labelStyle: TextStyle(
                                color: isSelected ? AppTheme.neonBlue : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Platforms'),
                  const SizedBox(height: 12),
                  widget.availablePlatforms.isEmpty
                      ? const Text('No platforms available.')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.availablePlatforms.map((platform) {
                            final isSelected = _selectedPlatforms.contains(platform);
                            return FilterChip(
                              label: Text(platform),
                              selected: isSelected,
                              onSelected: (_) => _togglePlatform(platform),
                              selectedColor: AppTheme.neonPink.withOpacity(0.2),
                              checkmarkColor: AppTheme.neonPink,
                              labelStyle: TextStyle(
                                color: isSelected ? AppTheme.neonPink : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearAll,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.neonBlue),
                  ),
                  child: const Text('Clear All', style: TextStyle(color: AppTheme.neonBlue)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedPlatforms, _selectedBrands);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }
}
