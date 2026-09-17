import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/patients/view_model/notes_view_model.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/core/repository/app_repository.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';
import 'package:physio_ghar/features/schedule/view_model/schedule_view_model.dart';

enum BookingTab {
  requests(SessionStatus.request, 'Requests'),
  upcoming(SessionStatus.upcoming, 'Upcoming'),
  completed(SessionStatus.completed, 'Completed'),
  cancelled(SessionStatus.cancelled, 'Cancelled');

  const BookingTab(this.status, this.label);

  final SessionStatus status;
  final String label;
}

final selectedBookingTabProvider =
    NotifierProvider<SelectedBookingTabNotifier, BookingTab>(
      SelectedBookingTabNotifier.new,
    );

class SelectedBookingTabNotifier extends Notifier<BookingTab> {
  @override
  BookingTab build() => BookingTab.requests;

  void select(BookingTab tab) => state = tab;
}

final bookingsForTabProvider = Provider.family<List<Session>, BookingTab>((
  ref,
  tab,
) {
  final soonestFirst = tab == BookingTab.requests || tab == BookingTab.upcoming;
  return ref
      .watch(sessionsProvider)
      .where((s) => s.status == tab.status)
      .toList()
    ..sort(
      (a, b) => soonestFirst
          ? a.start.compareTo(b.start)
          : b.start.compareTo(a.start),
    );
});

final sessionByIdProvider = Provider.family<Session?, String>(
  (ref, id) => ref.watch(sessionsProvider).where((s) => s.id == id).firstOrNull,
);

final rescheduleDaysProvider = Provider<List<DateTime>>((ref) {
  final today = dateOnly(ref.watch(clockProvider)());
  return ref
      .watch(currentWeekProvider)
      .where((d) => !d.isBefore(today))
      .toList();
});

final openSlotTimesProvider = Provider.family<List<DateTime>, DateTime>((
  ref,
  day,
) {
  final now = ref.watch(clockProvider)();
  return [
    for (final slot in ref.watch(daySlotsProvider(day)))
      if (slot.state == SlotState.open && slot.start.isAfter(now)) slot.start,
  ];
});

final bookingActionsProvider =
    NotifierProvider<BookingActionsNotifier, Set<String>>(
      BookingActionsNotifier.new,
    );

class BookingActionsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  Future<void> accept(String id) => _run(
    id,
    (repository, session) async =>
        _sessions.apply(await repository.acceptSession(session)),
  );

  Future<void> decline(String id) => _run(
    id,
    (repository, session) async =>
        _sessions.apply(await repository.declineSession(session)),
  );

  Future<void> complete(String id, String remarks) =>
      _run(id, (repository, session) async {
        final (completed, note) = await repository.completeSession(
          session,
          remarks,
        );
        _sessions.apply(completed);
        ref.read(notesProvider.notifier).put(note);
      });

  Future<void> reschedule(String id, DateTime newStart) => _run(
    id,
    (repository, session) async =>
        _sessions.apply(await repository.rescheduleSession(session, newStart)),
  );

  SessionsNotifier get _sessions => ref.read(sessionsProvider.notifier);

  Future<void> _run(
    String id,
    Future<void> Function(AppRepository repository, Session session) action,
  ) async {
    if (state.contains(id)) return;
    state = {...state, id};
    try {
      final repository = await ref.read(repositoryProvider.future);
      await action(repository, _sessions.byId(id)!);
    } finally {
      state = {...state}..remove(id);
    }
  }
}
