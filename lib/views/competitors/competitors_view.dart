import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import '../../controllers/competitors_controller.dart';
import '../../core/app_theme.dart';

class CompetitorsView extends StatefulWidget {
  const CompetitorsView({super.key});

  @override
  State<CompetitorsView> createState() => _CompetitorsViewState();
}

class _CompetitorsViewState extends State<CompetitorsView> {
  final ScrollController _scrollController = ScrollController();
  late CompetitorsController _controller;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<CompetitorsController>(context, listen: false);
    
    // Load initial data if empty
    if (_controller.competitors.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadCompetitors(refresh: true);
      });
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_controller.isLoading && !_controller.isFetchingMore && _controller.hasMoreData) {
        _controller.loadCompetitors();
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $urlString'),
            backgroundColor: AppTheme.neonPink,
          ),
        );
      }
    }
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.add, color: AppTheme.neonBlue),
                title: const Text('Add Single Competitor'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddCompetitorForm(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file, color: AppTheme.neonBlue),
                title: const Text('Import from Excel/CSV'),
                onTap: () {
                  Navigator.pop(ctx);
                  _importCompetitors(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCompetitorForm(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: _AddCompetitorFormSheet(),
        );
      },
    );
  }

  Future<void> _importCompetitors(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (!mounted) return;
        
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator(color: AppTheme.neonBlue)),
        );
        
        final controller = Provider.of<CompetitorsController>(context, listen: false);
        final response = await controller.uploadCompetitors(file);
        
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Import result'),
            backgroundColor: response['success'] == true ? AppTheme.neonGreen : AppTheme.neonPink,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import: $e'),
          backgroundColor: AppTheme.neonPink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Competitors',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<CompetitorsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            );
          }

          if (controller.errorMessage != null && controller.competitors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage!,
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.neonPink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadCompetitors(refresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonBlue,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.competitors.isEmpty) {
            return Center(
              child: Text(
                'No competitors found.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final filteredCompetitors = controller.competitors.where((c) {
            if (_searchQuery.isEmpty) return true;
            return c.name.toLowerCase().contains(_searchQuery) ||
                   c.notes.toLowerCase().contains(_searchQuery) ||
                   c.createdBy.toLowerCase().contains(_searchQuery);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search Name, Notes, Creator...",
                    prefixIcon: const Icon(Icons.search, color: AppTheme.neonBlue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.neonBlue),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.loadCompetitors(refresh: true),
                  color: AppTheme.neonBlue,
                  child: filteredCompetitors.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  'No matching competitors found.',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredCompetitors.length + (controller.isFetchingMore && _searchQuery.isEmpty ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            if (index == filteredCompetitors.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
                                  ),
                                ),
                              );
                            }

                            final competitor = filteredCompetitors[index];
                            return _buildCompetitorCard(theme, competitor);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: AppTheme.neonBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCompetitorCard(ThemeData theme, var competitor) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        competitor.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.neonBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${competitor.srNo}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.neonBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (competitor.notes.isNotEmpty) ...[
                  Text(
                    competitor.notes,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Divider(color: theme.dividerColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Created By',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          competitor.createdBy,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Date',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          competitor.createdAt,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (competitor.website.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _launchUrl(competitor.website),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: AppTheme.neonBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              competitor.website,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.neonBlue,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
  }
}

class _AddCompetitorFormSheet extends StatefulWidget {
  @override
  State<_AddCompetitorFormSheet> createState() => _AddCompetitorFormSheetState();
}

class _AddCompetitorFormSheetState extends State<_AddCompetitorFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    final controller = Provider.of<CompetitorsController>(context, listen: false);
    final data = {
      'name': _nameController.text.trim(),
      'website': _websiteController.text.trim(),
      'notes': _notesController.text.trim(),
    };

    final result = await controller.addCompetitor(data);
    
    if (!mounted) return;
    
    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppTheme.neonGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppTheme.neonPink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Competitor',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(theme, 'Competitor Name *'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _websiteController,
              decoration: _inputDecoration(theme, 'Website URL'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: _inputDecoration(theme, 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
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
                  : const Text('Add Competitor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
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
    );
  }
}
