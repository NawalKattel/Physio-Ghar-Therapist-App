import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';

Widget slotTile({required ScheduleSlot slot, required VoidCallback onTap}) {
  return Consumer(
    builder: (context, ref, _) =>
        _slotTile(slot, onTap, ref.watch(stringsProvider)),
  );
}

Widget _slotTile(ScheduleSlot slot, VoidCallback onTap, AppStrings strings) {
  final time = formatTime(slot.start);
  final session = slot.session;

  final (
    background,
    border,
    timeColor,
    subtitleColor,
    badgeBackground,
    badgeForeground,
    label,
    icon,
    subtitle,
  ) = switch (slot.state) {
    SlotState.open => (
      Colors.white,
      AppColors.pine.withValues(alpha: 0.35),
      AppColors.ink,
      AppColors.inkMid,
      AppColors.pinePale,
      AppColors.pine,
      'Open',
      Icons.event_available_rounded,
      'Available for booking',
    ),
    SlotState.booked => (
      AppColors.pine,
      AppColors.pine,
      Colors.white,
      Colors.white.withValues(alpha: 0.85),
      Colors.white.withValues(alpha: 0.18),
      Colors.white,
      'Booked',
      Icons.person_rounded,
      session == null
          ? 'Booked'
          : '${strings.name(session.patient.name)} · ${session.treatment}',
    ),
    SlotState.blocked => (
      AppColors.mist,
      AppColors.mist,
      AppColors.inkMute,
      AppColors.inkMid,
      Colors.white,
      AppColors.inkMid,
      'Blocked',
      Icons.lock_rounded,
      'Not available',
    ),
  };

  return appCard(
    onTap: onTap,
    color: background,
    borderColor: border,
    semanticLabel: '$time, $label, $subtitle',
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
    child: ExcludeSemantics(
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              time,
              style: AppTextStyles.title.copyWith(
                fontSize: 16,
                color: timeColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              subtitle,
              style: AppTextStyles.body.copyWith(color: subtitleColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: badgeBackground,
              borderRadius: AppRadius.pillBorder,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: badgeForeground),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.eyebrow.copyWith(color: badgeForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
