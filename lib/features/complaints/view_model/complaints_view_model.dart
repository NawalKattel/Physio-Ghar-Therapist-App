import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';

final complaintsProvider =
    NotifierProvider<ComplaintsNotifier, List<Complaint>>(
      ComplaintsNotifier.new,
    );

class ComplaintsNotifier extends Notifier<List<Complaint>> {
  @override
  List<Complaint> build() =>
      [...ref.watch(appDataProvider).requireValue.complaints]
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

  Complaint? byId(String id) => state.where((c) => c.id == id).firstOrNull;

  Future<Complaint> submit({
    required ComplaintCategory category,
    required String subject,
    required String description,
  }) async {
    final repository = await ref.read(repositoryProvider.future);
    final complaint = await repository.submitComplaint(
      category: category,
      subject: subject,
      description: description,
    );
    state = [complaint, ...state];
    return complaint;
  }
}

final complaintByIdProvider = Provider.family<Complaint?, String>(
  (ref, id) =>
      ref.watch(complaintsProvider).where((c) => c.id == id).firstOrNull,
);
