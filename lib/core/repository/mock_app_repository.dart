import 'package:physio_ghar/core/repository/app_repository.dart';
import 'package:physio_ghar/core/repository/mock_repository.dart';
import 'package:physio_ghar/features/account/model/therapist.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';
import 'package:physio_ghar/features/patients/model/note.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';

class MockAppRepository implements AppRepository {
  MockAppRepository({required this.source, required this.clock});

  final MockRepository source;
  final DateTime Function() clock;

  static const _actionLatency = Duration(milliseconds: 400);

  AppData? _loaded;
  final _createdAccounts = <String, String>{};
  var _nextId = 0;
  var _complaintCount = 0;

  @override
  bool get requiresAuth => false;

  Future<AppData> _data() async => _loaded ??= await source.load();

  String _id(String prefix) => '$prefix-${++_nextId}';

  @override
  Future<Therapist> login({
    required String email,
    required String password,
  }) async {
    final data = await _data();
    await Future<void>.delayed(_actionLatency);

    final matches =
        data.accounts.any((a) => a.matches(email, password)) ||
        _createdAccounts[email.trim().toLowerCase()] == password;
    if (!matches) {
      throw const RepositoryException(
        code: 'INVALID_CREDENTIALS',
        message: 'Incorrect email or password.',
      );
    }
    return data.therapist;
  }

  @override
  Future<Therapist> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _data();
    await Future<void>.delayed(_actionLatency);

    final address = email.trim().toLowerCase();
    final taken =
        data.accounts.any((a) => a.email.toLowerCase() == address) ||
        _createdAccounts.containsKey(address);
    if (taken) {
      throw const RepositoryException(
        code: 'EMAIL_TAKEN',
        message: 'An account with this email already exists.',
      );
    }

    _createdAccounts[address] = password;
    return data.therapist.copyWith(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AppData> loadAll() => _data();

  @override
  Future<Session> acceptSession(Session session) => _change(
    session,
    SessionStatus.request,
    (s) => s.copyWith(status: SessionStatus.upcoming),
  );

  @override
  Future<Session> declineSession(Session session) => _change(
    session,
    SessionStatus.request,
    (s) => s.copyWith(status: SessionStatus.cancelled),
  );

  @override
  Future<(Session, Note)> completeSession(
    Session session,
    String remarks,
  ) async {
    final completed = await _change(
      session,
      SessionStatus.upcoming,
      (s) =>
          s.copyWith(status: SessionStatus.completed, remarks: remarks.trim()),
    );
    return (completed, sessionRemarksNote(completed, remarks, at: clock()));
  }

  @override
  Future<Session> rescheduleSession(Session session, DateTime newStart) =>
      _change(
        session,
        SessionStatus.upcoming,
        (s) => s.copyWith(start: newStart),
      );

  Future<Session> _change(
    Session session,
    SessionStatus from,
    Session Function(Session) change,
  ) async {
    await Future<void>.delayed(_actionLatency);
    if (session.status != from) {
      throw RepositoryException(
        code: 'SESSION_INVALID_STATUS',
        message: 'This session is ${session.status.name}, not ${from.name}.',
      );
    }
    return change(session);
  }

  @override
  Future<Slot> addSlot(DateTime start) async {
    await Future<void>.delayed(_actionLatency);
    return Slot(id: _id('slot'), start: start);
  }

  @override
  Future<Slot> blockSlot(Slot slot) async {
    await Future<void>.delayed(_actionLatency);
    return slot.copyWith(isBlocked: true);
  }

  @override
  Future<Slot> unblockSlot(Slot slot) async {
    await Future<void>.delayed(_actionLatency);
    return slot.copyWith(isBlocked: false);
  }

  @override
  Future<Note> addNote({
    required String patientId,
    required String title,
    required String body,
  }) async {
    await Future<void>.delayed(_actionLatency);
    return Note(
      id: _id('note'),
      patientId: patientId,
      title: title.trim(),
      body: body.trim(),
      createdAt: clock(),
    );
  }

  @override
  Future<Note> editNote(
    Note note, {
    required String title,
    required String body,
  }) async {
    await Future<void>.delayed(_actionLatency);
    return note.copyWith(
      title: title.trim(),
      body: body.trim(),
      updatedAt: clock(),
    );
  }

  @override
  Future<Therapist> updateProfile(Therapist profile) async {
    await Future<void>.delayed(_actionLatency);
    return profile;
  }

  @override
  Future<Therapist> setAvailability(bool isAvailable) async =>
      (await _data()).therapist.copyWith(isAvailable: isAvailable);

  @override
  Future<Complaint> submitComplaint({
    required ComplaintCategory category,
    required String subject,
    required String description,
  }) async {
    final data = await _data();
    await Future<void>.delayed(_actionLatency);

    final number = data.complaints.length + ++_complaintCount;
    return Complaint(
      id: _id('complaint'),
      reference: 'PG-C-${number.toString().padLeft(4, '0')}',
      category: category,
      subject: subject.trim(),
      description: description.trim(),
      submittedAt: clock(),
    );
  }
}
