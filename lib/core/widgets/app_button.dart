import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

Widget appButton({
  Key? key,
  required String label,
  required VoidCallback? onPressed,
  AppButtonVariant variant = AppButtonVariant.primary,
  IconData? icon,
  bool isLoading = false,
  bool expand = false,
  bool compact = false,
}) {
  final (background, foreground, border) = _buttonColors(variant);
  final enabled = onPressed != null;

  final showMuted = !enabled && !isLoading;
  final contentColor = showMuted ? AppColors.inkMute : foreground;

  final button = TextButton(
    onPressed: isLoading ? null : onPressed,
    style: TextButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: showMuted && background != Colors.transparent
          ? AppColors.mist
          : background,
      disabledForegroundColor: contentColor,
      minimumSize: Size(kMinTapTarget, compact ? kMinTapTarget : 52),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.md : AppSpacing.xl,
      ),
      shape: const StadiumBorder(),
      side: border == null
          ? null
          : BorderSide(color: showMuted ? AppColors.mist : border, width: 1.5),
      textStyle: AppTextStyles.button,
      tapTargetSize: MaterialTapTargetSize.padded,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: contentColor,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.xs),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );

  final wrapped = Semantics(
    key: key,
    button: true,
    enabled: enabled && !isLoading,
    label: isLoading ? '$label, loading' : null,
    child: button,
  );

  return expand ? SizedBox(width: double.infinity, child: wrapped) : wrapped;
}

(Color, Color, Color?) _buttonColors(AppButtonVariant variant) =>
    switch (variant) {
      AppButtonVariant.primary => (AppColors.amber, AppColors.ink, null),
      AppButtonVariant.secondary => (AppColors.pine, Colors.white, null),
      AppButtonVariant.outline => (
        Colors.transparent,
        AppColors.pine,
        AppColors.pine,
      ),
      AppButtonVariant.ghost => (Colors.transparent, AppColors.pine, null),
      AppButtonVariant.danger => (AppColors.danger, Colors.white, null),
    };
