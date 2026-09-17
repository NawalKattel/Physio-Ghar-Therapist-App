import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/features/account/model/therapist.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';

final therapistProvider = NotifierProvider<TherapistNotifier, Therapist>(
  TherapistNotifier.new,
);

class TherapistNotifier extends Notifier<Therapist> {
  @override
  Therapist build() => ref.watch(appDataProvider).requireValue.therapist;

  void apply(Therapist therapist) => state = therapist;

  void setAvailable(bool isAvailable) =>
      state = state.copyWith(isAvailable: isAvailable);

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required int experienceYears,
    required String specialization,
    required String address,
  }) {
    state = state.copyWith(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      experienceYears: experienceYears,
      specialization: specialization.trim(),
      address: address.trim(),
    );
  }
}
