import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/features/patients/model/note.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends Notifier<List<Note>> {
  var _nextId = 0;

  @override
  List<Note> build() => ref.watch(appDataProvider).requireValue.notes;

  Note? byId(String id) => state.where((n) => n.id == id).firstOrNull;

  Note add({
    required String patientId,
    required String title,
    required String body,
  }) {
    final note = Note(
      id: 'note-${++_nextId}',
      patientId: patientId,
      title: title.trim(),
      body: body.trim(),
      createdAt: ref.read(clockProvider)(),
    );
    state = [...state, note];
    return note;
  }

  void put(Note note) => state = [...state.where((n) => n.id != note.id), note];

  void edit(String id, {required String title, required String body}) {
    if (byId(id) == null) throw StateError('No note with id $id');
    final now = ref.read(clockProvider)();
    state = [
      for (final n in state)
        n.id == id
            ? n.copyWith(title: title.trim(), body: body.trim(), updatedAt: now)
            : n,
    ];
  }
}
