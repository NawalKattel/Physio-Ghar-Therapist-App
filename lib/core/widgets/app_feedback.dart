import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.danger : AppColors.ink,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.fieldBorder,
        ),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: AppColors.amber,
                onPressed: onAction ?? () {},
              ),
      ),
    );
}

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
      title: Text(title, style: AppTextStyles.title),
      content: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.inkMid),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: [
        appButton(
          label: cancelLabel,
          variant: AppButtonVariant.ghost,
          compact: true,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        appButton(
          label: confirmLabel,
          variant: isDestructive
              ? AppButtonVariant.danger
              : AppButtonVariant.secondary,
          compact: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
