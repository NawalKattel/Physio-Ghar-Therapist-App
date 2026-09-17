import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_avatar.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/session_card.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/bookings/view/widgets/booking_sheets.dart';
import 'package:physio_ghar/features/bookings/view/widgets/request_actions.dart';
import 'package:physio_ghar/features/bookings/view_model/bookings_view_model.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoaded = ref.watch(appDataProvider).hasValue;
    final session = isLoaded ? ref.watch(sessionByIdProvider(sessionId)) : null;
    final isBusy = ref.watch(bookingActionsProvider).contains(sessionId);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Session details', style: AppTextStyles.title),
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pine),
            )
          : session == null
          ? emptyState(
              icon: Icons.search_off_rounded,
              title: 'Session not found',
              message: 'It may have been removed.',
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            )
          : _details(session, ref.watch(stringsProvider)),
      bottomNavigationBar: session == null
          ? null
          : _actionBar(context, ref, session, isBusy),
    );
  }
}

Widget _details(Session session, AppStrings strings) {
  final patient = session.patient;

  return ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
    children: [
      responsiveCenter(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.xs,
          AppSpacing.pageGutter,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            appCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appAvatar(name: patient.name, size: 56),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        nameText(patient.name, style: AppTextStyles.title),
                        const SizedBox(height: 2),
                        Text(
                          '${strings.age(patient.age)} · ${patient.gender}',
                          style: AppTextStyles.bodySmall,
                        ),
                        Text(patient.condition, style: AppTextStyles.bodySmall),
                        const SizedBox(height: AppSpacing.sm),
                        sessionStatusPill(session.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            appCard(
              child: Column(
                children: [
                  _infoRow(
                    Icons.medical_services_rounded,
                    'Treatment',
                    session.treatment,
                  ),
                  _infoRow(
                    Icons.calendar_today_rounded,
                    'Date',
                    formatFullDate(session.start),
                  ),
                  _infoRow(
                    Icons.schedule_rounded,
                    'Time',
                    '${formatTime(session.start)} · ${session.duration.inMinutes} min',
                  ),
                  _infoRow(
                    session.visitType == VisitType.home
                        ? Icons.home_rounded
                        : Icons.local_hospital_rounded,
                    'Visit type',
                    session.visitType == VisitType.home
                        ? strings.homeVisit
                        : 'Clinic session',
                  ),
                  _infoRow(
                    Icons.place_rounded,
                    'Location',
                    strings.place(session.location),
                    isLast: true,
                  ),
                ],
              ),
            ),
            if (session.status == SessionStatus.completed) ...[
              const SizedBox(height: AppSpacing.md),
              appCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appEyebrow('Therapist remarks'),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      session.remarks?.isNotEmpty == true
                          ? session.remarks!
                          : 'No remarks recorded.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
            if (session.status == SessionStatus.cancelled) ...[
              const SizedBox(height: AppSpacing.md),
              _notice(
                'This request was declined, so no session will take place.',
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

Widget _infoRow(
  IconData icon,
  String label,
  String value, {
  bool isLast = false,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.pinePale,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.pine),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.inkMute,
                ),
              ),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _notice(String message) {
  return Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: AppColors.dangerPale,
      borderRadius: AppRadius.fieldBorder,
    ),
    child: Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 20,
          color: AppColors.danger,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );
}

Widget? _actionBar(
  BuildContext context,
  WidgetRef ref,
  Session session,
  bool isBusy,
) {
  final Widget actions;
  switch (session.status) {
    case SessionStatus.request:
      actions = requestActions(
        isBusy: isBusy,
        onAccept: () => acceptBooking(context, ref, session),
        onDecline: () => declineBooking(context, ref, session),
      );
    case SessionStatus.upcoming:
      actions = Row(
        children: [
          Expanded(
            child: appButton(
              label: 'Reschedule',
              icon: Icons.event_repeat_rounded,
              variant: AppButtonVariant.outline,
              expand: true,
              onPressed: isBusy
                  ? null
                  : () => showRescheduleSheet(context, session),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: appButton(
              label: 'Complete',
              icon: Icons.check_rounded,
              expand: true,
              onPressed: isBusy
                  ? null
                  : () => showCompleteSessionSheet(context, session),
            ),
          ),
        ],
      );
    case SessionStatus.completed || SessionStatus.cancelled:
      return null;
  }

  return DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppColors.mist)),
    ),
    child: SafeArea(
      top: false,
      child: responsiveCenter(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.sm,
          AppSpacing.pageGutter,
          AppSpacing.sm,
        ),
        child: actions,
      ),
    ),
  );
}
