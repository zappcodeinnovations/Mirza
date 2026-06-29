import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onSearchTapped;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    required this.onSearchTapped,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSearchTapped,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.darkAccent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.neonBlue.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(
              Icons.search,
              color: AppTheme.neonBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onTap: onSearchTapped,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Color(0xFF55605B),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  color: Color(0xFF30432A),
                  fontSize: 13,
                ),
                cursorColor: AppTheme.neonBlue,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
