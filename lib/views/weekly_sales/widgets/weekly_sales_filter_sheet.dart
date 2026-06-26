import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class WeeklySalesFilterSheet extends StatefulWidget {
  final List<String> availableFinancialYears;
  final List<String> initiallySelectedFinancialYears;
  final Function(List<String> financialYears) onApply;

  const WeeklySalesFilterSheet({
    super.key,
    required this.availableFinancialYears,
    required this.initiallySelectedFinancialYears,
    required this.onApply,
  });

  @override
  State<WeeklySalesFilterSheet> createState() => _WeeklySalesFilterSheetState();
}

class _WeeklySalesFilterSheetState extends State<WeeklySalesFilterSheet> {
  late List<String> _selectedFinancialYears;

  @override
  void initState() {
    super.initState();
    _selectedFinancialYears = List.from(widget.initiallySelectedFinancialYears);
  }

  void _toggleFinancialYear(String fy) {
    setState(() {
      if (_selectedFinancialYears.contains(fy)) {
        _selectedFinancialYears.remove(fy);
      } else {
        _selectedFinancialYears.add(fy);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedFinancialYears.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Weekly Sales',
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
          const SizedBox(height: 16),
          Text(
            'Financial Years',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          widget.availableFinancialYears.isEmpty
              ? const Text('No financial years available.')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.availableFinancialYears.map((fy) {
                    final isSelected = _selectedFinancialYears.contains(fy);
                    return FilterChip(
                      label: Text(fy),
                      selected: isSelected,
                      onSelected: (_) => _toggleFinancialYear(fy),
                      selectedColor: AppTheme.neonBlue.withOpacity(0.2),
                      checkmarkColor: AppTheme.neonBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.neonBlue : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearAll,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.neonBlue),
                  ),
                  child: const Text('Clear', style: TextStyle(color: AppTheme.neonBlue)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedFinancialYears);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
