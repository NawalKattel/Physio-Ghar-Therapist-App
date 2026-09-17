import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';

final sessionsProvider = NotifierProvider<SessionsNotifier, List<Session>>(
  SessionsNotifier.new,
);

class SessionsNotifier extends Notifier<List<Session>> {
  @override
  List<Session> build() => ref.watch(appDataProvider).requireValue.sessions;

  Session? byId(String id) => state.where((s) => s.id == id).firstOrNull;

  void apply(Session session) =>
      state = [for (final s in state) s.id == session.id ? session : s];

  void accept(String id) => _update(
    id,
    from: SessionStatus.request,
    (s) => s.copyWith(status: SessionStatus.upcoming),
  );

  void decline(String id) => _update(
    id,
    from: SessionStatus.request,
    (s) => s.copyWith(status: SessionStatus.cancelled),
  );

  void complete(String id, String remarks) => _update(
    id,
    from: SessionStatus.upcoming,
    (s) => s.copyWith(status: SessionStatus.completed, remarks: remarks.trim()),
  );

  void reschedule(String id, DateTime newStart) => _update(
    id,
    from: SessionStatus.upcoming,
    (s) => s.copyWith(start: newStart),
  );

  void _update(
    String id,
    Session Function(Session) change, {
    required SessionStatus from,
  }) {
    final session = byId(id);
    if (session == null) throw StateError('No session with id $id');
    if (session.status != from) {
      throw StateError(
        'Session $id is ${session.status.name}, expected ${from.name}',
      );
    }
    state = [for (final s in state) s.id == id ? change(s) : s];
  }
}

final pendingRequestCountProvider = Provider<int>(
  (ref) => ref
      .watch(sessionsProvider)
      .where((s) => s.status == SessionStatus.request)
      .length,
);
