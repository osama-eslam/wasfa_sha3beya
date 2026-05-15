import 'package:flutter/material.dart';

class SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchCard({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          hintText: 'دوّر على وصفة...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14,
          ),
        ),
      ),
    );
  }
}
