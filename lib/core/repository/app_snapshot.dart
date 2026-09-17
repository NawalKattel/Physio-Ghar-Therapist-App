import 'dart:convert';

import 'package:physio_ghar/core/repository/local_store.dart';
import 'package:physio_ghar/core/repository/mock_repository.dart';
import 'package:physio_ghar/features/account/model/therapist.dart';
import 'package:physio_ghar/features/auth/model/account.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';
import 'package:physio_ghar/features/patients/model/note.dart';
import 'package:physio_ghar/features/patients/model/patient.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';

class AppSnapshot {
  const AppSnapshot._();

  static const _key = 'physioghar.state.v1';

  static Future<void> save(LocalStore store, AppData data) {
    return store.write(
      _key,
      jsonEncode({
        'therapist': data.therapist.toJson(),
        'patients': [for (final p in data.patients) p.toJson()],
        'sessions': [for (final s in data.sessions) s.toJson()],
        'slots': [for (final s in data.slots) s.toJson()],
        'notes': [for (final n in data.notes) n.toJson()],
        'complaints': [for (final c in data.complaints) c.toJson()],
      }),
    );
  }

  static Future<AppData?> load(
    LocalStore store, {
    required List<Account> accounts,
  }) async {
    final raw = await store.read(_key);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final patients = [
        for (final p in json['patients'] as List)
          Patient.fromJson(p as Map<String, dynamic>),
      ];
      final patientsById = {for (final p in patients) p.id: p};

      return AppData(
        therapist: Therapist.fromJson(
          json['therapist'] as Map<String, dynamic>,
        ),
        patients: patients,
        sessions: [
          for (final s in json['sessions'] as List)
            Session.fromSaved(s as Map<String, dynamic>, patientsById),
        ],
        slots: [
          for (final s in json['slots'] as List)
            Slot.fromSaved(s as Map<String, dynamic>),
        ],
        notes: [
          for (final n in json['notes'] as List)
            Note.fromSaved(n as Map<String, dynamic>),
        ],
        complaints: [
          for (final c in json['complaints'] as List)
            Complaint.fromSaved(c as Map<String, dynamic>),
        ],
        accounts: accounts,
      );
    } on Object {
      await store.remove(_key);
      return null;
    }
  }

  static Future<void> clear(LocalStore store) => store.remove(_key);
}
