import 'package:flutter_test/flutter_test.dart';

import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';
import 'package:physio_ghar/features/schedule/view_model/schedule_view_model.dart';

import '../helpers.dart';

void main() {
  SlotState stateAt(container, DateTime start) => container
      .read(daySlotsProvider(dateOnly(start)))
      .firstWhere((ScheduleSlot s) => s.start == start)
      .state;

  test('the week runs Monday to Sunday', () async {
    final container = await loadedContainer();
    final week = container.read(currentWeekProvider);

    expect(week, hasLength(7));
    expect(week.first.weekday, DateTime.monday);
    expect(week.last.weekday, DateTime.sunday);
  });

  test('slot states come from the template and the sessions', () async {
    final container = await loadedContainer();

    expect(stateAt(container, dayAt(0, 9)), SlotState.open);
    expect(stateAt(container, dayAt(0, 10)), SlotState.booked); // Sita Sharma
    expect(stateAt(container, dayAt(0, 12)), SlotState.blocked);
  });

  test('Saturday is the day off: no open or blocked slots', () async {
    final container = await loadedContainer();
    final saturday = container.read(currentWeekProvider)[DateTime.saturday - 1];
    // Mock dates are relative, so a session can land on the day off; it
    // still shows as booked.
    expect(
      container.read(daySlotsProvider(saturday)).map((s) => s.state),
      everyElement(SlotState.booked),
    );
  });

  test('block and unblock an open slot', () async {
    final container = await loadedContainer();
    final slots = container.read(slotsProvider.notifier);
    final start = dayAt(0, 11);

    slots.block(start);
    expect(stateAt(container, start), SlotState.blocked);

    slots.unblock(start);
    expect(stateAt(container, start), SlotState.open);
  });

  test('a booked slot cannot be blocked', () async {
    final container = await loadedContainer();
    final start = dayAt(0, 10);

    container.read(slotsProvider.notifier).block(start);

    expect(stateAt(container, start), SlotState.booked);
  });

  test('add slot rejects past and duplicate times, then adds an open slot', () async {
    final container = await loadedContainer();
    final slots = container.read(slotsProvider.notifier);

    expect(slots.add(dayAt(0, 8, 30)), AddSlotError.past);
    expect(slots.add(dayAt(0, 11)), AddSlotError.duplicate);

    final evening = dayAt(0, 18);
    expect(slots.add(evening), isNull);
    expect(stateAt(container, evening), SlotState.open);
    expect(container.read(daySlotsProvider(dateOnly(evening))).last.start, evening);
  });

  test('accepting a request books its slot', () async {
    final container = await loadedContainer();
    final start = dayAt(1, 13); // Anjali Thapa's request (s8)
    expect(stateAt(container, start), SlotState.open);

    container.read(sessionsProvider.notifier).accept('s8');

    expect(stateAt(container, start), SlotState.booked);
  });

  test('rescheduling frees the old slot and books the new one', () async {
    final container = await loadedContainer();
    final oldStart = dayAt(0, 10);
    final newStart = dayAt(0, 11);

    container.read(sessionsProvider.notifier).reschedule('s2', newStart);

    expect(stateAt(container, oldStart), SlotState.open);
    expect(stateAt(container, newStart), SlotState.booked);
  });
}
