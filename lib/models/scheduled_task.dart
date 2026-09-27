// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

enum RepeatFrequency { once, everyDay, everyWeek, everyMonth }

extension RepeatFrequencyLabel on RepeatFrequency {
  String get label => switch (this) {
        RepeatFrequency.once => 'Once',
        RepeatFrequency.everyDay => 'Every day',
        RepeatFrequency.everyWeek => 'Every week',
        RepeatFrequency.everyMonth => 'Every month',
      };
}

class ScheduledTask {
  ScheduledTask({
    required this.id,
    required this.title,
    required this.prompt,
    required this.frequency,
    required this.hour,
    required this.minute,
    required this.createdAt,
  });

  final String id;
  String title;
  String prompt;
  RepeatFrequency frequency;
  int hour;
  int minute;
  final DateTime createdAt;

  String get timeLabel {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $suffix';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'prompt': prompt,
        'frequency': frequency.name,
        'hour': hour,
        'minute': minute,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ScheduledTask.fromJson(Map<String, dynamic> json) => ScheduledTask(
        id: json['id'] as String,
        title: json['title'] as String,
        prompt: json['prompt'] as String,
        frequency: RepeatFrequency.values.byName(json['frequency'] as String),
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
