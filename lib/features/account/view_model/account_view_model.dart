import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';

Future<void> saveProfile(
  WidgetRef ref, {
  required String name,
  required String email,
  required String phone,
  required String experienceYears,
  required String specialization,
  required String address,
}) async {
  final repository = await ref.read(repositoryProvider.future);
  final updated = await repository.updateProfile(
    ref
        .read(therapistProvider)
        .copyWith(
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          experienceYears: int.parse(experienceYears.trim()),
          specialization: specialization.trim(),
          address: address.trim(),
        ),
  );
  ref.read(therapistProvider.notifier).apply(updated);
}

Future<void> saveAvailability(WidgetRef ref, bool isAvailable) async {
  ref.read(therapistProvider.notifier).setAvailable(isAvailable);
  final repository = await ref.read(repositoryProvider.future);
  final updated = await repository.setAvailability(isAvailable);
  ref.read(therapistProvider.notifier).apply(updated);
}
