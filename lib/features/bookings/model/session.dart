import 'package:physio_ghar/features/patients/model/patient.dart';

enum SessionStatus { request, upcoming, completed, cancelled }

enum VisitType { home, clinic }

class Session {
  const Session({
    required this.id,
    required this.patient,
    required this.start,
    required this.duration,
    required this.treatment,
    required this.visitType,
    required this.location,
    required this.status,
    this.remarks,
  });

  factory Session.fromSaved(
    Map<String, dynamic> json,
    Map<String, Patient> patients,
  ) => Session(
    id: json['id'] as String,
    patient: patients[json['patientId']]!,
    start: DateTime.parse(json['start'] as String),
    duration: Duration(minutes: json['durationMinutes'] as int),
    treatment: json['treatment'] as String,
    visitType: VisitType.values.byName(json['visitType'] as String),
    location: json['location'] as String,
    status: SessionStatus.values.byName(json['status'] as String),
    remarks: json['remarks'] as String?,
  );

  factory Session.fromJson(
    Map<String, dynamic> json, {
    required Map<String, Patient> patients,
    required DateTime today,
  }) {
    final [hour, minute] = (json['time'] as String)
        .split(':')
        .map(int.parse)
        .toList();
    final day = DateTime(
      today.year,
      today.month,
      today.day + (json['dayOffset'] as int),
    );

    return Session(
      id: json['id'] as String,
      patient: patients[json['patientId']]!,
      start: DateTime(day.year, day.month, day.day, hour, minute),
      duration: Duration(minutes: json['durationMinutes'] as int),
      treatment: json['treatment'] as String,
      visitType: VisitType.values.byName(json['visitType'] as String),
      location: json['location'] as String,
      status: SessionStatus.values.byName(json['status'] as String),
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patient.id,
    'start': start.toIso8601String(),
    'durationMinutes': duration.inMinutes,
    'treatment': treatment,
    'visitType': visitType.name,
    'location': location,
    'status': status.name,
    'remarks': remarks,
  };

  final String id;
  final Patient patient;
  final DateTime start;
  final Duration duration;
  final String treatment;
  final VisitType visitType;
  final String location;
  final SessionStatus status;

  final String? remarks;

  Session copyWith({DateTime? start, SessionStatus? status, String? remarks}) =>
      Session(
        id: id,
        patient: patient,
        start: start ?? this.start,
        duration: duration,
        treatment: treatment,
        visitType: visitType,
        location: location,
        status: status ?? this.status,
        remarks: remarks ?? this.remarks,
      );
}
