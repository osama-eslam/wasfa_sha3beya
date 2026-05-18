import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/widgets/banner_ad_widget.dart';
import 'package:wasfa_sha3beya/features/market_list/controllers/market_list_controller.dart';

class MarketListPage extends StatefulWidget {
  const MarketListPage({super.key});

  @override
  State<MarketListPage> createState() => _MarketListPageState();
}

class _MarketListPageState extends State<MarketListPage> {
  late final MarketListController _ctrl;
  int _selectedTab = 0;
  final _addCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(MarketListController());
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات السوق'),
        actions: [
          Obx(() {
            final items = _ctrl.itemsForDay(_selectedTab);
            return IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'مشاركة القائمة',
              onPressed: items.isNotEmpty
                  ? () => _ctrl.shareDayList(_selectedTab)
                  : null,
            );
          }),
        ],
      ),
      body: Column(
        children: [
          _SegmentedTabs(
            selectedIndex: _selectedTab,
            onChanged: (i) => setState(() => _selectedTab = i),
          ),
          Divider(height: 1, color: theme.colorScheme.outline),
          Expanded(
            child: Obx(() {
              final items = _ctrl.itemsForDay(_selectedTab);
              if (items.isEmpty) {
                return _EmptyList(theme: theme);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: items.length,
                itemBuilder: (_, i) => _ChecklistItem(
                  item: items[i],
                  onToggle: () => _ctrl.toggleItem(_selectedTab, items[i].id),
                  onDelete: () =>
                      _ctrl.deleteItem(_selectedTab, items[i].id),
                  onEdit: (text) =>
                      _ctrl.updateItemText(_selectedTab, items[i].id, text),
                  theme: theme,
                ),
              );
            }),
          ),
          Divider(height: 1, color: theme.colorScheme.outline),
          const BannerAdWidget(),
          Container(height: 1, color: theme.colorScheme.outline),
          _AddItemBar(
            controller: _addCtrl,
            focusNode: _focusNode,
            onAdd: _addItem,
            theme: theme,
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.addItem(_selectedTab, text);
    _addCtrl.clear();
    _focusNode.requestFocus();
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabs = ['الإثنين', 'الأربعاء', 'الجمعة'];

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final sel = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? theme.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      color: sel ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                      fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  final ThemeData theme;
  const _EmptyList({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('القائمة فارغة',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text('أضف طلباتك من الأسفل',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;
  final ThemeData theme;

  const _ChecklistItem({
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Icon(
                item.isChecked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: item.isChecked
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _editItem(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  item.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: item.isChecked
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 14, 16, 14),
              child: Icon(Icons.delete_outline_rounded,
                  size: 20, color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _editItem(BuildContext context) {
    final ctrl = TextEditingController(text: item.text);
    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الطلب'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'اسم الطلب',
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isNotEmpty) {
                onEdit(t);
                Get.back();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }
}

class _AddItemBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;
  final ThemeData theme;

  const _AddItemBar({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: theme.colorScheme.surface,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: bottomInset > 0 ? bottomInset + 8 : MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'أضف طلباً...',
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onAdd,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(Icons.add_rounded,
                    color: theme.colorScheme.onPrimary, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
