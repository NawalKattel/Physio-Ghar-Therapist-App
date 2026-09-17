import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/features/auth/model/account.dart';
import 'package:physio_ghar/features/patients/model/note.dart';
import 'package:physio_ghar/features/patients/model/patient.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';
import 'package:physio_ghar/features/account/model/therapist.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';

class AppData {
  const AppData({
    required this.therapist,
    required this.patients,
    required this.sessions,
    required this.slots,
    required this.notes,
    required this.accounts,
    required this.complaints,
  });

  factory AppData.empty() => AppData(
    therapist: const Therapist(
      name: '',
      email: '',
      phone: '',
      experienceYears: 0,
      specialization: '',
      address: '',
      isAvailable: false,
    ),
    patients: const [],
    sessions: const [],
    slots: const [],
    notes: const [],
    accounts: const [],
    complaints: const [],
  );

  final Therapist therapist;
  final List<Patient> patients;
  final List<Session> sessions;
  final List<Slot> slots;
  final List<Note> notes;
  final List<Account> accounts;
  final List<Complaint> complaints;
}

Note sessionRemarksNote(
  Session session,
  String remarks, {
  required DateTime at,
}) => Note(
  id: 'session-${session.id}',
  patientId: session.patient.id,
  title: 'Session remarks · ${session.treatment}',
  body: remarks.trim(),
  createdAt: at,
  sessionId: session.id,
);

class MockRepository {
  MockRepository({
    required this.clock,
    this.latency = const Duration(milliseconds: 600),
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  static const _assetPath = 'lib/core/repository/physio_ghar.json';

  final DateTime Function() clock;
  final Duration latency;
  final AssetBundle _bundle;

  Future<AppData> load() async {
    await Future<void>.delayed(latency);
    final json =
        jsonDecode(await _bundle.loadString(_assetPath))
            as Map<String, dynamic>;

    final patients = [
      for (final p in json['patients'] as List)
        Patient.fromJson(p as Map<String, dynamic>),
    ];
    final patientsById = {for (final p in patients) p.id: p};
    final today = clock();

    final sessions = [
      for (final s in json['sessions'] as List)
        Session.fromJson(
          s as Map<String, dynamic>,
          patients: patientsById,
          today: today,
        ),
    ];

    return AppData(
      accounts: [
        for (final a in json['accounts'] as List)
          Account.fromJson(a as Map<String, dynamic>),
      ],
      therapist: Therapist.fromJson(json['therapist'] as Map<String, dynamic>),
      patients: patients,
      sessions: sessions,
      slots: _buildWeekSlots(json['schedule'] as Map<String, dynamic>, today),
      complaints: [
        for (final c in json['complaints'] as List)
          Complaint.fromJson(c as Map<String, dynamic>, today: today),
      ],
      notes: [
        for (final n in json['notes'] as List)
          Note.fromJson(n as Map<String, dynamic>, today: today),

        for (final s in sessions)
          if (s.status == SessionStatus.completed &&
              (s.remarks ?? '').isNotEmpty)
            sessionRemarksNote(s, s.remarks!, at: s.start.add(s.duration)),
      ],
    );
  }

  List<Slot> _buildWeekSlots(Map<String, dynamic> schedule, DateTime today) {
    final slotTimes = (schedule['slotTimes'] as List).cast<String>();
    final dayOff = _weekdays.indexOf(schedule['dayOff'] as String) + 1;
    final blocked = {
      for (final b in schedule['blocked'] as List)
        _at(
          DateTime(
            today.year,
            today.month,
            today.day + (b['dayOffset'] as int),
          ),
          b['time'] as String,
        ),
    };

    final monday = startOfWeek(today);
    return [
      for (var i = 0; i < 7; i++)
        if (DateTime(monday.year, monday.month, monday.day + i) case final day
            when day.weekday != dayOff)
          for (final time in slotTimes)
            Slot(
              start: _at(day, time),
              isBlocked: blocked.contains(_at(day, time)),
            ),
    ];
  }

  static const _weekdays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static DateTime _at(DateTime day, String time) {
    final [hour, minute] = time.split(':').map(int.parse).toList();
    return DateTime(day.year, day.month, day.day, hour, minute);
  }
}
