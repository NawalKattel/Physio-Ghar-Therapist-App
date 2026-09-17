import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';

Widget availabilityCard({
  required bool isAvailable,
  required ValueChanged<bool> onChanged,
}) {
  return appCard(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.xs,
      AppSpacing.sm,
    ),
    child: MergeSemantics(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.pine : AppColors.inkMute,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? 'Available' : 'Unavailable',
                  style: AppTextStyles.label,
                ),
                Text(
                  isAvailable
                      ? 'Patients can book your open slots'
                      : "You're hidden from new bookings",
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            onChanged: onChanged,
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.pine
                  : AppColors.inkMute,
            ),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    ),
  );
}
