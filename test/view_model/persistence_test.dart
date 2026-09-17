import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/repository/local_store.dart';
import 'package:physio_ghar/core/repository/persistence.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';
import 'package:physio_ghar/features/patients/view_model/notes_view_model.dart';
import 'package:physio_ghar/features/patients/view_model/patients_view_model.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';
import 'package:physio_ghar/features/schedule/view_model/schedule_view_model.dart';

import '../helpers.dart';

void main() {
  test('changes are restored after a restart', () async {
    // One store stands in for the device across both app runs.
    final store = MemoryLocalStore();

    // First run: accept a request, block a slot, add a note, edit the profile.
    final first = await loadedContainer(store: store);
    first.read(persistenceProvider);
    first.read(sessionsProvider.notifier).accept('s8');
    first.read(slotsProvider.notifier).block(dayAt(0, 11));
    first.read(notesProvider.notifier).add(patientId: 'p2', title: 'Plan', body: 'Knee flexion');
    first.read(therapistProvider.notifier).setAvailable(false);
    // Let the pending writes finish.
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    // Second run: same device storage, fresh providers.
    final second = await loadedContainer(store: store);

    expect(
      second.read(sessionsProvider).firstWhere((s) => s.id == 's8').status,
      SessionStatus.upcoming,
    );
    expect(
      second
          .read(daySlotsProvider(dayAt(0, 0)))
          .firstWhere((s) => s.start == dayAt(0, 11))
          .state,
      SlotState.blocked,
    );
    expect(second.read(patientNotesProvider('p2')).first.title, 'Plan');
    expect(second.read(therapistProvider).isAvailable, isFalse);
  });

  test('the chosen language is restored', () async {
    final store = MemoryLocalStore();

    final first = await loadedContainer(store: store);
    first.read(persistenceProvider);
    first.read(languageProvider.notifier).set(AppLanguage.nepali);
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    final second = ProviderContainer(overrides: testOverrides(store: store));
    addTearDown(second.dispose);
    await second.read(savedLanguageProvider.future);

    expect(second.read(languageProvider), AppLanguage.nepali);
  });

  test('without saved state the bundled mock data is used', () async {
    final container = await loadedContainer();
    expect(container.read(sessionsProvider), hasLength(13));
    expect(
      container.read(sessionsProvider).firstWhere((s) => s.id == 's8').status,
      SessionStatus.request,
    );
  });
}
