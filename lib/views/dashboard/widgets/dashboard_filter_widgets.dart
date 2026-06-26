import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../core/app_icons.dart';

class DashboardActiveFiltersRow extends StatelessWidget {
  const DashboardActiveFiltersRow({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[];

    if (controller.selectedBrand != 'All') {
      chips.add(
        _DashboardFilterChip(
          label: 'Brand: ${controller.selectedBrand}',
          onDeleted: () => controller.setFilters(brand: 'All'),
        ),
      );
    }
    if (controller.selectedGender != 'All') {
      chips.add(
        _DashboardFilterChip(
          label: 'Gender: ${controller.selectedGender}',
          onDeleted: () => controller.setFilters(gender: 'All'),
        ),
      );
    }
    if (controller.selectedPlatform != 'All') {
      chips.add(
        _DashboardFilterChip(
          label: 'Platform: ${controller.selectedPlatform}',
          onDeleted: () => controller.setFilters(platform: 'All'),
        ),
      );
    }

    if (chips.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(AppIcons.info, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Displaying overall unfiltered data (Global)',
                style: theme.textTheme.bodySmall,
                softWrap: true,
                maxLines: 2,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Filters',
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...chips,
            GestureDetector(
              onTap: () => controller.resetFilters(),
              child: Chip(
                label: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: theme.colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void showDashboardFilterBottomSheet(
  BuildContext context,
  DashboardController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          final filters = controller.filters;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Icon(AppIcons.filter, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 20),
              _DashboardFilterGroup(
                title: 'Date Range',
                selectedValue: controller.selectedDateRange,
                options: [
                  'All',
                  ...(filters?.dateRanges.map((e) => e.label).toList() ?? []),
                ],
                onSelected: (value) {
                  controller.setFilters(dateRange: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 12),
              _DashboardFilterGroup(
                title: 'Brand',
                selectedValue: controller.selectedBrand,
                options: ['All', ...(filters?.brands ?? [])],
                onSelected: (value) {
                  controller.setFilters(brand: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 12),
              _DashboardFilterGroup(
                title: 'Gender',
                selectedValue: controller.selectedGender,
                options: ['All', ...(filters?.genders ?? [])],
                onSelected: (value) {
                  controller.setFilters(gender: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 12),
              _DashboardFilterGroup(
                title: 'Footwear Type',
                selectedValue: controller.selectedFootwearType,
                options: ['All', ...(filters?.footwearTypes ?? [])],
                onSelected: (value) {
                  controller.setFilters(footwearType: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 12),
              _DashboardFilterGroup(
                title: 'Product Type',
                selectedValue: controller.selectedProductType,
                options: ['All', ...(filters?.productTypes ?? [])],
                onSelected: (value) {
                  controller.setFilters(productType: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 12),
              _DashboardFilterGroup(
                title: 'Material',
                selectedValue: controller.selectedMaterial,
                options: ['All', ...(filters?.materials ?? [])],
                onSelected: (value) {
                  controller.setFilters(material: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 12),
              _DashboardFilterGroup(
                title: 'Marketplace',
                selectedValue: controller.selectedPlatform,
                options: ['All', ...(filters?.platforms ?? [])],
                onSelected: (value) {
                  controller.setFilters(platform: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 12),
              _DashboardFilterGroup(
                title: 'City',
                selectedValue: controller.selectedCity,
                options: ['All', ...(filters?.cities ?? [])],
                onSelected: (value) {
                  controller.setFilters(city: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 12),
              _DashboardFilterGroup(
                title: 'Season',
                selectedValue: controller.selectedSeason,
                options: [
                  'All',
                  ...(filters?.seasons.map((e) => e.seasonName).toList() ?? []),
                ],
                onSelected: (value) {
                  controller.setFilters(season: value);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(AppIcons.search),
                      label: const Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.resetFilters();
                        setModalState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

class _DashboardFilterChip extends StatelessWidget {
  const _DashboardFilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputChip(
      label: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      onDeleted: onDeleted,
      deleteIconColor: theme.colorScheme.error,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: theme.dividerColor),
    );
  }
}

class _DashboardFilterGroup extends StatelessWidget {
  const _DashboardFilterGroup({
    required this.title,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedValueNotifier = ValueNotifier<String?>(selectedValue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonHideUnderline(
            child: DropdownButtonFormField2<String>(
              isExpanded: true,
              valueListenable: selectedValueNotifier,
              items: options
                  .map(
                    (option) => DropdownItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onSelected(value);
                }
              },
              buttonStyleData: FormFieldButtonStyleData(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
              ),
              iconStyleData: IconStyleData(
                icon: const Icon(AppIcons.arrowDown),
                iconEnabledColor: theme.colorScheme.primary,
                iconDisabledColor: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 280,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(20),
                  thumbVisibility: WidgetStateProperty.all(true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
