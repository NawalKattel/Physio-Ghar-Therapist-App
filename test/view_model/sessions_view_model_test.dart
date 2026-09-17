import 'package:flutter_test/flutter_test.dart';

import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/bookings/view_model/bookings_view_model.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';
import 'package:physio_ghar/features/patients/view_model/patients_view_model.dart';

import '../helpers.dart';

void main() {
  // Mock data: s8 is Anjali Thapa's request, s2 is Sita Sharma's upcoming
  // 10:00 visit today.
  const requestId = 's8';
  const upcomingId = 's2';

  Session session(container, String id) =>
      container.read(sessionsProvider).firstWhere((Session s) => s.id == id);

  test('accept moves a request to upcoming', () async {
    final container = await loadedContainer();
    expect(container.read(pendingRequestCountProvider), 3);

    container.read(sessionsProvider.notifier).accept(requestId);

    expect(session(container, requestId).status, SessionStatus.upcoming);
    expect(container.read(pendingRequestCountProvider), 2);
    expect(
      container.read(bookingsForTabProvider(BookingTab.requests)).map((s) => s.id),
      isNot(contains(requestId)),
    );
    expect(
      container.read(bookingsForTabProvider(BookingTab.upcoming)).map((s) => s.id),
      contains(requestId),
    );
  });

  test('decline moves a request to cancelled', () async {
    final container = await loadedContainer();
    container.read(sessionsProvider.notifier).decline(requestId);
    expect(session(container, requestId).status, SessionStatus.cancelled);
  });

  test('complete marks an upcoming session completed with trimmed remarks', () async {
    final container = await loadedContainer();
    container.read(sessionsProvider.notifier).complete(upcomingId, '  Pain down to 2/10.  ');

    final completed = session(container, upcomingId);
    expect(completed.status, SessionStatus.completed);
    expect(completed.remarks, 'Pain down to 2/10.');
  });

  test('reschedule moves an upcoming session to a new time', () async {
    final container = await loadedContainer();
    final newStart = dayAt(1, 11);
    container.read(sessionsProvider.notifier).reschedule(upcomingId, newStart);
    expect(session(container, upcomingId).start, newStart);
  });

  test('status changes outside the allowed flow are rejected', () async {
    final container = await loadedContainer();
    final sessions = container.read(sessionsProvider.notifier);

    expect(() => sessions.complete(requestId, 'x'), throwsStateError);
    expect(() => sessions.accept(upcomingId), throwsStateError);
    expect(() => sessions.accept('missing'), throwsStateError);
  });

  test('completing through the booking actions saves the remarks as a note', () async {
    final container = await loadedContainer();
    const patientId = 'p1'; // Sita Sharma
    final notesBefore = container.read(patientNotesProvider(patientId)).length;

    await container.read(bookingActionsProvider.notifier).complete(upcomingId, 'Core work done.');

    final notes = container.read(patientNotesProvider(patientId));
    expect(notes.length, notesBefore + 1);
    expect(notes.first.body, 'Core work done.');
    expect(notes.first.sessionId, upcomingId);
    expect(container.read(bookingActionsProvider), isEmpty);
  });

  test('requests are listed soonest first, completed most recent first', () async {
    final container = await loadedContainer();

    final requests = container.read(bookingsForTabProvider(BookingTab.requests));
    final completed = container.read(bookingsForTabProvider(BookingTab.completed));

    expect(requests.map((s) => s.start), orderedEquals([...requests.map((s) => s.start)]..sort()));
    expect(
      completed.map((s) => s.start),
      orderedEquals([...completed.map((s) => s.start)]..sort((a, b) => b.compareTo(a))),
    );
  });
}
