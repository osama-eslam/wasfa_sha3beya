import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';

class CategoryRow extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryRow({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(
              -1.0 +
                  (AppConstants.categories.indexWhere(
                        (c) => c.name == selectedCategory,
                      ) *
                      2 /
                      (AppConstants.categories.length - 1)),
              0,
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppConstants.categories
                    .firstWhere((c) => c.name == selectedCategory)
                    .color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.categories.length,
            itemBuilder: (context, index) {
              final cat = AppConstants.categories[index];
              final isSelected = cat.name == selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => onCategorySelected(cat.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: cat.color.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          color: isSelected ? Colors.white : Colors.black87,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
