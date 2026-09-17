import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/app_status_pill.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';

IconData complaintCategoryIcon(ComplaintCategory category) =>
    switch (category) {
      ComplaintCategory.patient => Icons.personal_injury_outlined,
      ComplaintCategory.booking => Icons.event_busy_outlined,
      ComplaintCategory.payment => Icons.payments_outlined,
      ComplaintCategory.technical => Icons.bug_report_outlined,
      ComplaintCategory.other => Icons.help_outline_rounded,
    };

Widget complaintCard(Complaint complaint) {
  return appCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              complaintCategoryIcon(complaint.category),
              size: 18,
              color: AppColors.pine,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: appEyebrow(complaint.category.label)),
            appStatusPill(label: 'Submitted', tone: AppPillTone.amber),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          complaint.subject,
          style: AppTextStyles.label.copyWith(fontSize: 15),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          complaint.description,
          style: AppTextStyles.bodySmall,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${complaint.reference} · ${formatDateTime(complaint.submittedAt)}',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkMute),
        ),
      ],
    ),
  );
}
