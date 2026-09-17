import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';

Widget requestActions({
  required VoidCallback onAccept,
  required VoidCallback onDecline,
  bool isBusy = false,
}) {
  return Row(
    children: [
      Expanded(
        child: appButton(
          label: 'Decline',
          variant: AppButtonVariant.outline,
          compact: true,
          expand: true,
          onPressed: isBusy ? null : onDecline,
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: appButton(
          label: 'Accept',
          icon: Icons.check_rounded,
          compact: true,
          expand: true,
          isLoading: isBusy,
          onPressed: onAccept,
        ),
      ),
    ],
  );
}
