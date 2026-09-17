import 'package:physio_ghar/features/bookings/model/session.dart';

class Slot {
  const Slot({required this.start, this.isBlocked = false, this.id});

  factory Slot.fromSaved(Map<String, dynamic> json) => Slot(
    id: json['id'] as String?,
    start: DateTime.parse(json['start'] as String),
    isBlocked: json['isBlocked'] as bool,
  );

  final String? id;
  final DateTime start;
  final bool isBlocked;

  Map<String, dynamic> toJson() => {
    'id': id,
    'start': start.toIso8601String(),
    'isBlocked': isBlocked,
  };

  Slot copyWith({bool? isBlocked}) =>
      Slot(id: id, start: start, isBlocked: isBlocked ?? this.isBlocked);
}

enum SlotState { open, booked, blocked }

class ScheduleSlot {
  const ScheduleSlot({
    required this.start,
    required this.state,
    this.session,
    this.id,
  });

  final String? id;
  final DateTime start;
  final SlotState state;

  final Session? session;
}
