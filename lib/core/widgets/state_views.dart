import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';

Widget emptyState({
  required IconData icon,
  required String title,
  String? message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return _stateLayout(
    icon: icon,
    iconColor: AppColors.pine,
    iconBackground: AppColors.pinePale,
    title: title,
    message: message,
    action: actionLabel != null && onAction != null
        ? appButton(
            label: actionLabel,
            onPressed: onAction,
            variant: AppButtonVariant.outline,
            compact: true,
          )
        : null,
  );
}

Widget errorState({
  required VoidCallback onRetry,
  String title = 'Something went wrong',
  String message = "We couldn't load your data. Please try again.",
  String retryLabel = 'Retry',
}) {
  return _stateLayout(
    icon: Icons.cloud_off_rounded,
    iconColor: AppColors.danger,
    iconBackground: AppColors.dangerPale,
    title: title,
    message: message,
    action: appButton(
      label: retryLabel,
      icon: Icons.refresh_rounded,
      onPressed: onRetry,
      variant: AppButtonVariant.secondary,
      compact: true,
    ),
  );
}

Widget _stateLayout({
  required IconData icon,
  required Color iconColor,
  required Color iconBackground,
  required String title,
  String? message,
  Widget? action,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.inkMid),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action,
          ],
        ],
      ),
    ),
  );
}
