import 'package:flutter/foundation.dart';

enum ReminderType { pill, vitamin, medication }

/// Napi ismétlődő egészségügyi emlékeztető.
@immutable
class Reminder {
  const Reminder({
    this.id,
    required this.type,
    required this.title,
    required this.hour,
    required this.minute,
    this.enabled = true,
  });

  final int? id;
  final ReminderType type;
  final String title;
  final int hour;
  final int minute;
  final bool enabled;

  Reminder copyWith({int? id, bool? enabled}) => Reminder(
        id: id ?? this.id,
        type: type,
        title: title,
        hour: hour,
        minute: minute,
        enabled: enabled ?? this.enabled,
      );

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
