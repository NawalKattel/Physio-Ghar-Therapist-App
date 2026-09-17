import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';

final currentWeekProvider = Provider<List<DateTime>>((ref) {
  final monday = startOfWeek(ref.watch(clockProvider)());
  return [
    for (var i = 0; i < 7; i++)
      DateTime(monday.year, monday.month, monday.day + i),
  ];
});

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => dateOnly(ref.watch(clockProvider)());

  void select(DateTime day) => state = dateOnly(day);
}

enum AddSlotError { past, duplicate }

final slotsProvider = NotifierProvider<SlotsNotifier, List<Slot>>(
  SlotsNotifier.new,
);

class SlotsNotifier extends Notifier<List<Slot>> {
  @override
  List<Slot> build() => ref.watch(appDataProvider).requireValue.slots;

  Slot? byStart(DateTime start) =>
      state.where((s) => s.start == start).firstOrNull;

  void apply(Slot slot) {
    state = [
      for (final s in state)
        if (s.start != slot.start) s,
      slot,
    ]..sort((a, b) => a.start.compareTo(b.start));
  }

  void block(DateTime start) {
    if (isBooked(start)) return;
    _setBlocked(start, true);
  }

  void unblock(DateTime start) => _setBlocked(start, false);

  AddSlotError? validate(DateTime start) {
    if (!start.isAfter(ref.read(clockProvider)())) return AddSlotError.past;
    if (state.any((s) => s.start == start) || isBooked(start)) {
      return AddSlotError.duplicate;
    }
    return null;
  }

  AddSlotError? add(DateTime start) {
    final error = validate(start);
    if (error != null) return error;
    apply(Slot(start: start));
    return null;
  }

  void _setBlocked(DateTime start, bool isBlocked) {
    state = [
      for (final slot in state)
        if (slot.start == start) slot.copyWith(isBlocked: isBlocked) else slot,
    ];
  }

  bool isBooked(DateTime start) => ref
      .read(sessionsProvider)
      .any((s) => s.start == start && _occupiesSlot(s));
}

final scheduleActionsProvider = Provider<ScheduleActions>(ScheduleActions.new);

class ScheduleActions {
  ScheduleActions(this._ref);

  final Ref _ref;

  SlotsNotifier get _slots => _ref.read(slotsProvider.notifier);

  Future<void> block(ScheduleSlot slot) async {
    final repository = await _ref.read(repositoryProvider.future);
    _slots.apply(await repository.blockSlot(_slotFor(slot, isBlocked: false)));
  }

  Future<void> unblock(ScheduleSlot slot) async {
    final repository = await _ref.read(repositoryProvider.future);
    _slots.apply(await repository.unblockSlot(_slotFor(slot, isBlocked: true)));
  }

  Future<AddSlotError?> add(DateTime start) async {
    final error = _slots.validate(start);
    if (error != null) return error;

    final repository = await _ref.read(repositoryProvider.future);
    _slots.apply(await repository.addSlot(start));
    return null;
  }

  Slot _slotFor(ScheduleSlot slot, {required bool isBlocked}) =>
      _slots.byStart(slot.start) ??
      Slot(id: slot.id, start: slot.start, isBlocked: isBlocked);
}

bool _occupiesSlot(Session session) =>
    session.status == SessionStatus.upcoming ||
    session.status == SessionStatus.completed;

final daySlotsProvider = Provider.family<List<ScheduleSlot>, DateTime>((
  ref,
  day,
) {
  final sessionsByStart = {
    for (final s in ref.watch(sessionsProvider))
      if (isSameDay(s.start, day) && _occupiesSlot(s)) s.start: s,
  };

  final result = <DateTime, ScheduleSlot>{
    for (final slot in ref.watch(slotsProvider))
      if (isSameDay(slot.start, day))
        slot.start: ScheduleSlot(
          id: slot.id,
          start: slot.start,
          session: sessionsByStart[slot.start],
          state: sessionsByStart.containsKey(slot.start)
              ? SlotState.booked
              : slot.isBlocked
              ? SlotState.blocked
              : SlotState.open,
        ),
  };
  for (final session in sessionsByStart.values) {
    result.putIfAbsent(
      session.start,
      () => ScheduleSlot(
        start: session.start,
        state: SlotState.booked,
        session: session,
      ),
    );
  }

  return result.values.toList()..sort((a, b) => a.start.compareTo(b.start));
});
