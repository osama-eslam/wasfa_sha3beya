import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/data/models/timetable_entry.dart';
import 'package:wasfa_sha3beya/features/timetable/controllers/timetable_controller.dart';
import 'package:wasfa_sha3beya/features/timetable/widgets/add_subject_sheet.dart';

class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  static const days = [
    'السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimetableController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول مواعيد الأطفال'),
        actions: [
          Obx(() => controller.profiles.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.person_add_outlined, size: 22),
                  tooltip: 'إضافة ملف جديد',
                  onPressed: () => _showAddProfileDialog(context),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.profiles.isEmpty) {
          return _NoProfilesState(theme: theme, onCreate: () => _showAddProfileDialog(context));
        }
        final selProfile = controller.selectedProfile;
        if (selProfile == null) return const SizedBox.shrink();
        return Column(
          children: [
            _ProfileTabs(
              profiles: controller.profiles,
              selectedId: controller.selectedProfileId.value ?? '',
              onSelect: (id) => controller.selectProfile(id),
              onAdd: () => _showAddProfileDialog(context),
              onDelete: (id) => _confirmDeleteProfile(context, id),
            ),
            _DayPills(
              selectedDay: controller.selectedDay.value,
              onChanged: (i) => controller.selectedDay.value = i,
            ),
            Divider(height: 1, color: theme.colorScheme.outline),
            Expanded(
              child: _buildContent(controller, theme),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.profiles.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Get.bottomSheet(
            AddSubjectSheet(
              profileId: controller.selectedProfileId.value,
            ),
            isScrollControlled: true,
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('إضافة مادة جديدة'),
        );
      }),
    );
  }

  Widget _buildContent(TimetableController controller, ThemeData theme) {
    final entries = controller.entriesForSelectedDay;
    if (entries.isEmpty) {
      final hasAny = controller.selectedProfile?.entries.isNotEmpty ?? false;
      return _EmptyDay(hasAnyEntries: hasAny, theme: theme);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: entries.length,
      itemBuilder: (_, i) => _EntryCard(entry: entries[i], theme: theme),
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('إضافة ملف طفل جديد'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'مثال: عمر, علي, سارة...',
            prefixIcon: Icon(Icons.child_care_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                Get.find<TimetableController>().addProfile(name);
                Get.back();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    ).then((_) => nameCtrl.dispose());
  }

  void _confirmDeleteProfile(BuildContext context, String id) {
    final ctrl = Get.find<TimetableController>();
    final profile = ctrl.profiles.firstWhereOrNull((p) => p.id == id);
    if (profile == null) return;
    Get.dialog(
      AlertDialog(
        title: const Text('حذف الملف'),
        content: Text('حذف ملف "${profile.name}" وجميع مواعيده؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              ctrl.deleteProfile(id);
              Get.back();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final List<dynamic> profiles;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  const _ProfileTabs({
    required this.profiles,
    required this.selectedId,
    required this.onSelect,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: profiles.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            if (i == profiles.length) {
              return _AddTab(onTap: onAdd, theme: theme);
            }
            final p = profiles[i];
            final selected = p.id == selectedId;
            return _ProfileTab(
              name: p.name,
              selected: selected,
              onTap: () => onSelect(p.id),
              onLongPress: () => onDelete(p.id),
              theme: theme,
            );
          },
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ThemeData theme;

  const _ProfileTab({
    required this.name,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : '?';
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.transparent : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: selected
                  ? theme.colorScheme.onPrimary.withValues(alpha: 0.25)
                  : theme.colorScheme.outline,
              child: Text(
                initial,
                style: TextStyle(
                  color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTab extends StatelessWidget {
  final VoidCallback onTap;
  final ThemeData theme;
  const _AddTab({required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              'إضافة',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPills extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onChanged;

  const _DayPills({
    required this.selectedDay,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: TimetablePage.days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final sel = selectedDay == i;
            return GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: sel ? Colors.transparent : theme.colorScheme.outline,
                  ),
                ),
                child: Text(
                  TimetablePage.days[i],
                  style: TextStyle(
                    color: sel ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                    fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NoProfilesState extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onCreate;
  const _NoProfilesState({required this.theme, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care_outlined,
                size: 72, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('لا يوجد ملفات أطفال بعد',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('أضف ملف طفل لبدء تنظيم الجدول',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('إضافة ملف طفل جديد'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final bool hasAnyEntries;
  final ThemeData theme;
  const _EmptyDay({required this.hasAnyEntries, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (hasAnyEntries) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 56, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('لا توجد مواعيد لهذا اليوم',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note_outlined,
              size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('لا توجد مواعيد بعد',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('أضف مادة جديدة لبدء الجدول',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final TimetableEntry entry;
  final ThemeData theme;
  const _EntryCard({required this.entry, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = entry.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(bottom: 20),
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.subjectName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.startTime}  ←  ${entry.endTime}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
              onPressed: () => _openEditSheet(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              splashRadius: 20,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  size: 20, color: theme.colorScheme.error),
              onPressed: () => _confirmDelete(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    final ctrl = Get.find<TimetableController>();
    Get.bottomSheet(
      AddSubjectSheet(
        profileId: ctrl.selectedProfileId.value,
        entry: entry,
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(BuildContext context) {
    final ctrl = Get.find<TimetableController>();
    Get.dialog(
      AlertDialog(
        title: const Text('حذف المادة'),
        content: Text('حذف "${entry.subjectName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final pid = ctrl.selectedProfileId.value;
              if (pid != null) ctrl.deleteEntry(pid, entry.id);
              Get.back();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
