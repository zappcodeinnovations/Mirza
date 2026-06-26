import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class StockFilterSheet extends StatefulWidget {
  final List<String> availableBrands;
  final List<String> availableBusinessUnits;
  final List<String> initiallySelectedBrands;
  final List<String> initiallySelectedBusinessUnits;
  final Function(List<String> brands, List<String> businessUnits) onApply;

  const StockFilterSheet({
    super.key,
    required this.availableBrands,
    required this.availableBusinessUnits,
    required this.initiallySelectedBrands,
    required this.initiallySelectedBusinessUnits,
    required this.onApply,
  });

  @override
  State<StockFilterSheet> createState() => _StockFilterSheetState();
}

class _StockFilterSheetState extends State<StockFilterSheet> {
  late List<String> _selectedBrands;
  late List<String> _selectedBusinessUnits;

  @override
  void initState() {
    super.initState();
    _selectedBrands = List.from(widget.initiallySelectedBrands);
    _selectedBusinessUnits = List.from(widget.initiallySelectedBusinessUnits);
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

  void _toggleBusinessUnit(String bu) {
    setState(() {
      if (_selectedBusinessUnits.contains(bu)) {
        _selectedBusinessUnits.remove(bu);
      } else {
        _selectedBusinessUnits.add(bu);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedBrands.clear();
      _selectedBusinessUnits.clear();
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
                'Filter Stock',
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
                  _buildSectionTitle(theme, 'Business Units'),
                  const SizedBox(height: 12),
                  widget.availableBusinessUnits.isEmpty
                      ? const Text('No business units available.')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.availableBusinessUnits.map((bu) {
                            final isSelected = _selectedBusinessUnits.contains(bu);
                            return FilterChip(
                              label: Text('BU $bu'),
                              selected: isSelected,
                              onSelected: (_) => _toggleBusinessUnit(bu),
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
                    widget.onApply(_selectedBrands, _selectedBusinessUnits);
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
