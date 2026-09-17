import 'package:physio_ghar/core/repository/mock_repository.dart';
import 'package:physio_ghar/features/account/model/therapist.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';
import 'package:physio_ghar/features/patients/model/note.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';

class RepositoryException implements Exception {
  const RepositoryException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'RepositoryException($code): $message';
}

abstract interface class AppRepository {
  bool get requiresAuth;

  Future<Therapist> login({required String email, required String password});

  Future<Therapist> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> logout();

  Future<AppData> loadAll();

  Future<Session> acceptSession(Session session);
  Future<Session> declineSession(Session session);

  Future<(Session, Note)> completeSession(Session session, String remarks);

  Future<Session> rescheduleSession(Session session, DateTime newStart);

  Future<Slot> addSlot(DateTime start);
  Future<Slot> blockSlot(Slot slot);
  Future<Slot> unblockSlot(Slot slot);

  Future<Note> addNote({
    required String patientId,
    required String title,
    required String body,
  });

  Future<Note> editNote(
    Note note, {
    required String title,
    required String body,
  });

  Future<Therapist> updateProfile(Therapist profile);
  Future<Therapist> setAvailability(bool isAvailable);

  Future<Complaint> submitComplaint({
    required ComplaintCategory category,
    required String subject,
    required String description,
  });
}
