import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/repository/app_repository.dart';
import 'package:physio_ghar/core/widgets/app_feedback.dart';
import 'package:physio_ghar/features/account/view_model/account_view_model.dart';

Future<void> setAvailabilityWithFeedback(
  BuildContext context,
  WidgetRef ref,
  bool isAvailable,
) async {
  showAppSnackBar(
    context,
    isAvailable
        ? "You're available for new bookings"
        : "You're now hidden from new bookings",
  );
  try {
    await saveAvailability(ref, isAvailable);
  } on RepositoryException catch (error) {
    if (context.mounted) showAppSnackBar(context, error.message, isError: true);
  }
}
