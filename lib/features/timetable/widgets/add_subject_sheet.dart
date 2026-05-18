import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/data/models/timetable_entry.dart';
import 'package:wasfa_sha3beya/features/timetable/controllers/timetable_controller.dart';

class AddSubjectSheet extends StatefulWidget {
  final String? profileId;
  final TimetableEntry? entry;

  const AddSubjectSheet({super.key, this.profileId, this.entry});

  @override
  State<AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<AddSubjectSheet> {
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final _customSubjectCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final TimetableController _ctrl;

  String? _selectedSubjectName;
  int _selectedDay = 0;
  bool _isCustomSubject = false;

  final _days = [
    'السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة',
  ];

  final _defaultSubjects = [
    'عربي', 'إنجليزي', 'رياضيات', 'علوم', 'دراسات',
  ];

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<TimetableController>();
    _selectedDay = widget.entry?.day ?? _ctrl.selectedDay.value;

    if (_isEditing) {
      final e = widget.entry!;
      if (_defaultSubjects.contains(e.subjectName)) {
        _selectedSubjectName = e.subjectName;
      } else {
        _isCustomSubject = true;
        _customSubjectCtrl.text = e.subjectName;
      }
      _startTimeCtrl.text = e.startTime;
      _endTimeCtrl.text = e.endTime;
    }
  }

  @override
  void dispose() {
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _customSubjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (c, child) =>
          Directionality(textDirection: TextDirection.ltr, child: child!),
    );
    if (t != null) {
      ctrl.text =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  String? get _subjectName {
    if (_isCustomSubject) return _customSubjectCtrl.text.trim();
    return _selectedSubjectName;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _subjectName;
    if (name == null || name.isEmpty) return;
    final pid = widget.profileId ?? _ctrl.selectedProfileId.value;
    if (pid == null) return;

    if (_isEditing) {
      _ctrl.updateEntry(
        profileId: pid,
        entryId: widget.entry!.id,
        subjectName: name,
        day: _selectedDay,
        startTime: _startTimeCtrl.text,
        endTime: _endTimeCtrl.text,
      );
    } else {
      _ctrl.addEntry(
        profileId: pid,
        subjectName: name,
        day: _selectedDay,
        startTime: _startTimeCtrl.text,
        endTime: _endTimeCtrl.text,
      );
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'تعديل المادة' : 'إضافة مادة جديدة',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<int>(
                initialValue: _selectedDay,
                decoration: InputDecoration(
                  labelText: 'اليوم',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: _days.asMap().entries.map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                )).toList(),
                onChanged: (v) => setState(() => _selectedDay = v!),
              ),
              const SizedBox(height: 14),

              if (!_isCustomSubject)
                DropdownButtonFormField<String>(
                  initialValue: _selectedSubjectName,
                  decoration: InputDecoration(
                    labelText: 'المادة',
                    prefixIcon: const Icon(Icons.book_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: [
                    ..._defaultSubjects.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    )),
                    const DropdownMenuItem(
                      value: '__custom__',
                      child: Text('إدخال مخصص...'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == '__custom__') {
                      setState(() => _isCustomSubject = true);
                    } else {
                      setState(() => _selectedSubjectName = v);
                    }
                  },
                  validator: (v) =>
                      v == null ? 'اختر مادة أو أدخل اسماً' : null,
                ),

              if (_isCustomSubject)
                TextFormField(
                  controller: _customSubjectCtrl,
                  autofocus: true,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'اسم المادة',
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () =>
                          setState(() => _isCustomSubject = false),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل اسم المادة' : null,
                ),

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeCtrl,
                      readOnly: true,
                      onTap: () => _pickTime(_startTimeCtrl),
                      decoration: InputDecoration(
                        labelText: 'وقت الدخول',
                        prefixIcon: const Icon(Icons.login_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeCtrl,
                      readOnly: true,
                      onTap: () => _pickTime(_endTimeCtrl),
                      decoration: InputDecoration(
                        labelText: 'وقت الخروج',
                        prefixIcon: const Icon(Icons.logout_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: Icon(
                      _isEditing ? Icons.save_outlined : Icons.add_rounded,
                      size: 18),
                  label: Text(
                    _isEditing ? 'حفظ التعديلات' : 'إضافة',
                    style: const TextStyle(fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
