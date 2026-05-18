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
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          hintText: 'دوّر على وصفة...',
          hintTextDirection: TextDirection.rtl,
          border: InputBorder.none,
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16, vertical: 14,
          ),
        ),
      ),
    );
  }
}
