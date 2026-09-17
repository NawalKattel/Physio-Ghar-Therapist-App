import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/features/patients/model/note.dart';

Widget noteCard({required Note note, required VoidCallback onEdit}) {
  return appCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: AppTextStyles.label.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      formatDateTime(note.createdAt),
                      if (note.isEdited) 'Edited',
                      if (note.sessionId != null) 'From session',
                    ].join(' · '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.inkMute,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              tooltip: 'Edit note',
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.pine,
              ),
              style: IconButton.styleFrom(
                minimumSize: const Size(kMinTapTarget, kMinTapTarget),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(note.body, style: AppTextStyles.body),
      ],
    ),
  );
}
