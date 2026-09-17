import 'package:flutter/material.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/core/widgets/app_status_pill.dart';

Widget sessionStatusPill(SessionStatus status) => switch (status) {
  SessionStatus.request => appStatusPill(
    label: 'Request',
    tone: AppPillTone.amber,
  ),
  SessionStatus.upcoming => appStatusPill(
    label: 'Upcoming',
    tone: AppPillTone.pine,
  ),
  SessionStatus.completed => appStatusPill(
    label: 'Completed',
    tone: AppPillTone.neutral,
    icon: Icons.check_rounded,
  ),
  SessionStatus.cancelled => appStatusPill(
    label: 'Cancelled',
    tone: AppPillTone.danger,
  ),
};

String sessionLocationLabel(
  Session session, [
  AppStrings strings = AppStrings.en,
]) => session.visitType == VisitType.home
    ? '${strings.homeVisit} · ${strings.place(session.location)}'
    : strings.place(session.location);

Widget sessionCard({
  required Session session,
  VoidCallback? onTap,
  bool showDate = false,
  Widget? footer,
}) {
  final time = formatTime(session.start);
  final semanticLabel =
      '${session.patient.name}, ${showDate ? '${formatShortDate(session.start)}, ' : ''}'
      '$time, ${session.treatment}, ${sessionLocationLabel(session)}, ${session.status.name}';
  const padding = EdgeInsets.all(AppSpacing.md);
  final content = _sessionContent(
    session,
    time: time,
    showDate: showDate,
    excludeSemantics: onTap != null,
  );

  if (footer == null) {
    return appCard(
      onTap: onTap,
      semanticLabel: semanticLabel,
      padding: padding,
      child: content,
    );
  }
  return appCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: onTap != null,
          label: semanticLabel,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: content),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.mist),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: footer,
        ),
      ],
    ),
  );
}

Widget _sessionContent(
  Session session, {
  required String time,
  required bool showDate,
  required bool excludeSemantics,
}) {
  return ExcludeSemantics(
    excluding: excludeSemantics,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDate) ...[
                  Text(
                    formatShortDate(session.start),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Text(time, style: AppTextStyles.title.copyWith(fontSize: 16)),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${session.duration.inMinutes} min',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.inkMute,
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(
            width: AppSpacing.xl,
            thickness: 1,
            color: AppColors.mist,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                nameText(
                  session.patient.name,
                  style: AppTextStyles.label.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(session.treatment, style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      session.visitType == VisitType.home
                          ? Icons.home_rounded
                          : Icons.local_hospital_rounded,
                      size: 14,
                      color: AppColors.inkMid,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: localizedText(
                        (s) => sessionLocationLabel(session, s),
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                sessionStatusPill(session.status),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
