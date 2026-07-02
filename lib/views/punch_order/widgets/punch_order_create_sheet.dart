import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../../../controllers/punch_order_controller.dart';
import '../../../core/app_theme.dart';
import '../../../models/punch_order_model.dart';

class PunchOrderCreateSheet extends StatefulWidget {
  const PunchOrderCreateSheet({super.key});

  @override
  State<PunchOrderCreateSheet> createState() => _PunchOrderCreateSheetState();
}

class _PunchOrderCreateSheetState extends State<PunchOrderCreateSheet> {
  final _formKey = GlobalKey<FormState>();

  final _skuSearchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  bool _isNewManual = false;
  final _selectedReason = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PunchOrderController>(context, listen: false).fetchOptions();
    });
  }

  @override
  void dispose() {
    _skuSearchController.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    _descriptionController.dispose();
    _selectedReason.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final controller = Provider.of<PunchOrderController>(context, listen: false);

    String skuCode = _skuSearchController.text.trim();
    String skuName = skuCode;
    
    if (skuCode.contains(' - ')) {
       final parts = skuCode.split(' - ');
       skuCode = parts[0].trim();
       skuName = parts.sublist(1).join(' - ').trim();
    }

    final data = {
      "sku_code": skuCode,
      "sku_name": skuName,
      "quantity": int.tryParse(_quantityController.text.trim()) ?? 0,
      "reason": _reasonController.text.trim(),
      "description": _descriptionController.text.trim(),
      "is_new_manual": _isNewManual,
    };

    final response = await controller.createPunchOrder(data);

    setState(() {
      _isSubmitting = false;
    });

    if (response != null && response.success) {
      if (mounted) {
        Navigator.pop(context); // Close the sheet
        _showAnalysisDialog(context, response.analysis);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to punch order. Please try again.'),
            backgroundColor: AppTheme.neonPink,
          ),
        );
      }
    }
  }

  void _showAnalysisDialog(BuildContext context, PunchOrderAnalysisModel? analysis) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: const Text('Order Punched Successfully', style: TextStyle(fontWeight: FontWeight.bold)),
          content: analysis == null
              ? const Text('No analysis data available.')
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAnalysisRow('Forecast Units', analysis.forecastUnits.toString(), theme),
                      _buildAnalysisRow('Recommended Qty', analysis.recommendedQty.toString(), theme),
                      _buildAnalysisRow('Current Stock', analysis.currentStock.toString(), theme),
                      _buildAnalysisRow('Difference', analysis.difference.toString(), theme),
                      const SizedBox(height: 16),
                      Text('Forecast Reason', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.neonBlue)),
                      const SizedBox(height: 4),
                      Text(analysis.forecastReason, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Text('Difference Reason', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.neonBlue)),
                      const SizedBox(height: 4),
                      Text(analysis.differenceReason, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppTheme.neonBlue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Punch New Order',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final controller = Provider.of<PunchOrderController>(context, listen: false);
                  final options = await controller.searchSkuOptions(textEditingValue.text);
                  return options;
                },
                onSelected: (String selection) {
                  _skuSearchController.text = selection;
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  textEditingController.addListener(() {
                    if (_skuSearchController.text != textEditingController.text) {
                       _skuSearchController.text = textEditingController.text;
                    }
                  });
                  
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: _inputDecoration(theme, 'SKU Code or Name *'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'SKU Code or Name is required' : null,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surface,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 48,
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _quantityController,
                decoration: _inputDecoration(theme, 'Quantity *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Quantity is required';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              Consumer<PunchOrderController>(
                builder: (context, controller, child) {
                  final reasons = controller.predefinedReasons;
                  return DropdownButtonFormField2<String>(
                    decoration: _inputDecoration(theme, 'Select Reason *'),
                    valueListenable: _selectedReason,
                    isExpanded: true,
                    items: reasons.map((reason) {
                      return DropdownItem<String>(
                        value: reason,
                        child: Text(
                          reason,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedReason.value = val;
                        if (val != 'Custom Reason') {
                          _reasonController.text = val ?? '';
                        } else {
                          _reasonController.clear();
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Please select a reason' : null,
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.darkAccent),
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  );
                },
              ),
              if (_selectedReason.value == 'Custom Reason') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  decoration: _inputDecoration(theme, 'Custom Reason *'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Reason is required' : null,
                ),
              ],
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(theme, 'Description (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              
              // SwitchListTile(
              //   title: Text('New Manual Order', style: theme.textTheme.bodyMedium),
              //   value: _isNewManual,
              //   activeColor: AppTheme.neonBlue,
              //   contentPadding: EdgeInsets.zero,
              //   onChanged: (val) {
              //     setState(() {
              //       _isNewManual = val;
              //     });
              //   },
              // ),
              // const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Submit Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.neonBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.neonPink),
      ),
    );
  }
}
