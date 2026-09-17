import 'package:flutter_test/flutter_test.dart';

import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';
import 'package:physio_ghar/features/auth/view_model/auth_view_model.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';
import 'package:physio_ghar/features/complaints/view_model/complaints_view_model.dart';
import 'package:physio_ghar/features/patients/view_model/notes_view_model.dart';
import 'package:physio_ghar/features/patients/view_model/patients_view_model.dart';

import '../helpers.dart';

void main() {
  group('notes', () {
    test('add then edit a note; newest first', () async {
      final container = await loadedContainer();
      const patientId = 'p2'; // Ram Thapa
      final notes = container.read(notesProvider.notifier);

      final note = notes.add(patientId: patientId, title: ' Session Note ', body: ' Knee flexion ');
      var list = container.read(patientNotesProvider(patientId));
      expect(list.first.id, note.id);
      expect(list.first.title, 'Session Note');
      expect(list.first.body, 'Knee flexion');
      expect(list.first.isEdited, isFalse);

      notes.edit(note.id, title: 'Session Note', body: 'Knee flexion, stretching');
      list = container.read(patientNotesProvider(patientId));
      expect(list.first.body, 'Knee flexion, stretching');
      expect(list.first.isEdited, isTrue);
    });

    test('remarks on completed sessions are loaded as notes', () async {
      final container = await loadedContainer();
      final notes = container.read(patientNotesProvider('p1')); // Sita Sharma
      expect(notes.where((n) => n.sessionId == 's11'), hasLength(1));
    });
  });

  group('patients', () {
    test('last session is the most recent completed one', () async {
      final container = await loadedContainer();
      final last = container.read(lastCompletedSessionProvider('p1'));
      expect(last?.id, 's11');
      expect(last?.start, dayAt(-5, 10));
    });
  });

  group('profile', () {
    test('updating the profile keeps availability', () async {
      final container = await loadedContainer();
      final therapist = container.read(therapistProvider.notifier);
      therapist.setAvailable(false);

      therapist.updateProfile(
        name: ' Dr. Test ',
        email: 'test@example.com',
        phone: '9800000000',
        experienceYears: 3,
        specialization: 'Neuro',
        address: 'Patan',
      );

      final updated = container.read(therapistProvider);
      expect(updated.name, 'Dr. Test');
      expect(updated.experienceYears, 3);
      expect(updated.isAvailable, isFalse);
    });
  });

  group('complaints', () {
    test('submit adds a complaint with the next reference, newest first', () async {
      final container = await loadedContainer();

      final complaint = await container.read(complaintsProvider.notifier).submit(
        category: ComplaintCategory.technical,
        subject: ' App froze ',
        description: 'The schedule screen froze when adding a slot.',
      );

      expect(complaint.reference, 'PG-C-0002');
      expect(complaint.subject, 'App froze');
      expect(container.read(complaintsProvider).first.id, complaint.id);
      expect(container.read(complaintByIdProvider(complaint.id)), isNotNull);
    });
  });

  group('auth', () {
    test('demo login succeeds; wrong password fails', () async {
      final container = await loadedContainer();
      final auth = container.read(authProvider.notifier);

      expect(await auth.login(email: 'aarati.joshi@example.com', password: 'wrong'), isFalse);
      expect(container.read(authProvider), isNull);

      expect(await auth.login(email: ' AARATI.JOSHI@example.com ', password: 'physio123'), isTrue);
      expect(container.read(authProvider), isNotNull);

      await auth.logout();
      expect(container.read(authProvider), isNull);
    });

    test('register rejects a taken email and signs in a new account', () async {
      final container = await loadedContainer();
      final auth = container.read(authProvider.notifier);

      expect(
        await auth.register(
          name: 'Someone',
          email: 'aarati.joshi@example.com',
          phone: '9800000000',
          password: 'secret123',
        ),
        RegisterError.emailTaken,
      );

      expect(
        await auth.register(
          name: 'Bina Karki',
          email: 'bina@example.com',
          phone: '9811111111',
          password: 'secret123',
        ),
        isNull,
      );
      expect(container.read(authProvider)?.email, 'bina@example.com');
      expect(container.read(therapistProvider).name, 'Bina Karki');
    });
  });
}
