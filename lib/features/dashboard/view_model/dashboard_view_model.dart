import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';

final todaySessionsProvider = Provider<List<Session>>((ref) {
  final today = ref.watch(clockProvider)();
  return ref
      .watch(sessionsProvider)
      .where(
        (s) =>
            isSameDay(s.start, today) &&
            (s.status == SessionStatus.upcoming ||
                s.status == SessionStatus.completed),
      )
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
});

final upcomingSessionsProvider = Provider<List<Session>>((ref) {
  final today = ref.watch(clockProvider)();
  final endOfToday = DateTime(today.year, today.month, today.day + 1);
  return ref
      .watch(sessionsProvider)
      .where(
        (s) =>
            s.status == SessionStatus.upcoming && !s.start.isBefore(endOfToday),
      )
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
});

final dashboardSummaryProvider =
    Provider<({int todaySessions, int requests, int completed})>((ref) {
      return (
        todaySessions: ref.watch(todaySessionsProvider).length,
        requests: ref.watch(pendingRequestCountProvider),
        completed: ref
            .watch(sessionsProvider)
            .where((s) => s.status == SessionStatus.completed)
            .length,
      );
    });
