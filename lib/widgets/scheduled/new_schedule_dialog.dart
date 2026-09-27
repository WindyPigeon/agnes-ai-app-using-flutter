// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../models/scheduled_task.dart';
import '../../state/app_state.dart';
import '../../util/id.dart';

Future<void> showNewScheduleDialog(BuildContext context, AppState appState) {
  return showDialog(
    context: context,
    builder: (context) => _NewScheduleDialog(appState: appState),
  );
}

class _NewScheduleDialog extends StatefulWidget {
  const _NewScheduleDialog({required this.appState});

  final AppState appState;

  @override
  State<_NewScheduleDialog> createState() => _NewScheduleDialogState();
}

class _NewScheduleDialogState extends State<_NewScheduleDialog> {
  final _title = TextEditingController();
  final _prompt = TextEditingController();
  RepeatFrequency _frequency = RepeatFrequency.everyDay;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    _prompt.dispose();
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty && _prompt.text.trim().isNotEmpty;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    widget.appState.addTask(ScheduledTask(
      id: generateId(),
      title: _title.text.trim(),
      prompt: _prompt.text.trim(),
      frequency: _frequency,
      hour: _time.hour,
      minute: _time.minute,
      createdAt: DateTime.now(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New scheduled task'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _title,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Please enter a task title'),
              ),
              const SizedBox(height: 16),
              const Text('Schedule', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<RepeatFrequency>(
                      initialValue: _frequency,
                      items: [
                        for (final f in RepeatFrequency.values)
                          DropdownMenuItem(value: f, child: Text(f.label)),
                      ],
                      onChanged: (v) => setState(() => _frequency = v ?? _frequency),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Text(
                          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Prompt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _prompt,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Please enter task details'),
              ),
              const SizedBox(height: 4),
              const Text(
                'This client stores scheduled tasks locally for reference only — they are not executed automatically, since there is no server component.',
                style: TextStyle(fontSize: 11.5, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _canSave ? _save : null, child: const Text('Save')),
      ],
    );
  }
}
