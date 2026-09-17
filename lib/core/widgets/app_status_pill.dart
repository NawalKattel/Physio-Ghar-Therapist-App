import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';

enum AppPillTone { amber, pine, pineSolid, neutral, danger }

Widget appStatusPill({
  required String label,
  required AppPillTone tone,
  IconData? icon,
}) {
  final (background, foreground, accent) = switch (tone) {
    AppPillTone.amber => (AppColors.amberPale, AppColors.ink, AppColors.amber),
    AppPillTone.pine => (AppColors.pinePale, AppColors.pine, AppColors.pine),
    AppPillTone.pineSolid => (AppColors.pine, Colors.white, Colors.white),
    AppPillTone.neutral => (
      AppColors.mist,
      AppColors.inkMid,
      AppColors.inkMute,
    ),
    AppPillTone.danger => (
      AppColors.dangerPale,
      AppColors.danger,
      AppColors.danger,
    ),
  };

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: AppSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: background,
      borderRadius: AppRadius.pillBorder,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 14, color: accent)
        else
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.label.copyWith(fontSize: 12, color: foreground),
        ),
      ],
    ),
  );
}
