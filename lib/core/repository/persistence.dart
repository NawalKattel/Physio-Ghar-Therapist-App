import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/core/repository/app_snapshot.dart';
import 'package:physio_ghar/core/repository/mock_repository.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';
import 'package:physio_ghar/features/complaints/view_model/complaints_view_model.dart';
import 'package:physio_ghar/features/patients/view_model/notes_view_model.dart';
import 'package:physio_ghar/features/schedule/view_model/schedule_view_model.dart';

const _languageKey = 'physioghar.language';

final savedLanguageProvider = FutureProvider<AppLanguage?>((ref) async {
  final saved = await ref.watch(localStoreProvider).read(_languageKey);
  return AppLanguage.values.where((l) => l.name == saved).firstOrNull;
});

final persistenceProvider = Provider<void>((ref) {
  ref.listen(languageProvider, (_, language) {
    ref.read(localStoreProvider).write(_languageKey, language.name);
  });

  if (!ref.watch(appDataProvider).hasValue) return;
  void save() {
    final loaded = ref.read(appDataProvider).requireValue;
    AppSnapshot.save(
      ref.read(localStoreProvider),
      AppData(
        therapist: ref.read(therapistProvider),
        patients: loaded.patients,
        sessions: ref.read(sessionsProvider),
        slots: ref.read(slotsProvider),
        notes: ref.read(notesProvider),
        complaints: ref.read(complaintsProvider),
        accounts: loaded.accounts,
      ),
    );
  }

  ref.listen(sessionsProvider, (_, _) => save());
  ref.listen(slotsProvider, (_, _) => save());
  ref.listen(notesProvider, (_, _) => save());
  ref.listen(complaintsProvider, (_, _) => save());
  ref.listen(therapistProvider, (_, _) => save());
});
