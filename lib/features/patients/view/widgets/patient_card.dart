import 'package:flutter/material.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_avatar.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/features/patients/model/patient.dart';

Widget patientCard({
  required Patient patient,
  required DateTime? lastSession,
  required VoidCallback onTap,
}) {
  final lastSessionText = lastSession == null
      ? 'No sessions yet'
      : 'Last session: ${formatDate(lastSession)}';

  return appCard(
    onTap: onTap,
    semanticLabel:
        '${patient.name}, age ${patient.age}, ${patient.condition}. $lastSessionText',
    child: ExcludeSemantics(
      child: Row(
        children: [
          appAvatar(name: patient.name, size: 48),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                nameText(
                  patient.name,
                  style: AppTextStyles.label.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                localizedText(
                  (s) => '${s.age(patient.age)} · ${patient.condition}',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 14,
                      color: AppColors.inkMute,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      lastSessionText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.inkMute,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkMute),
        ],
      ),
    ),
  );
}
