import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/features/patients/model/note.dart';
import 'package:physio_ghar/features/patients/model/patient.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/patients/view_model/notes_view_model.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';

final patientsProvider = Provider<List<Patient>>(
  (ref) =>
      [...ref.watch(appDataProvider).requireValue.patients]
        ..sort((a, b) => a.name.compareTo(b.name)),
);

final patientByIdProvider = Provider.family<Patient?, String>(
  (ref, id) => ref.watch(patientsProvider).where((p) => p.id == id).firstOrNull,
);

final patientSessionsProvider = Provider.family<List<Session>, String>(
  (ref, patientId) =>
      ref
          .watch(sessionsProvider)
          .where((s) => s.patient.id == patientId)
          .toList()
        ..sort((a, b) => b.start.compareTo(a.start)),
);

final lastCompletedSessionProvider = Provider.family<Session?, String>(
  (ref, patientId) => ref
      .watch(patientSessionsProvider(patientId))
      .where((s) => s.status == SessionStatus.completed)
      .firstOrNull,
);

final patientNotesProvider = Provider.family<List<Note>, String>(
  (ref, patientId) =>
      ref.watch(notesProvider).where((n) => n.patientId == patientId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
);

Future<bool> saveNote(
  WidgetRef ref, {
  required String patientId,
  String? noteId,
  required String title,
  required String body,
}) async {
  final repository = await ref.read(repositoryProvider.future);
  final notes = ref.read(notesProvider.notifier);

  if (noteId == null) {
    notes.put(
      await repository.addNote(patientId: patientId, title: title, body: body),
    );
    return true;
  }
  final existing = notes.byId(noteId)!;
  notes.put(await repository.editNote(existing, title: title, body: body));
  return false;
}
