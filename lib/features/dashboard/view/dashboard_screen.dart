import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/features/bookings/view_model/bookings_view_model.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_avatar.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/features/account/view/widgets/availability_feedback.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/session_card.dart';
import 'package:physio_ghar/core/widgets/skeleton.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/core/widgets/summary_card.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/account/model/therapist.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/dashboard/view_model/dashboard_view_model.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';

const _upcomingPreviewCount = 3;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: ref
            .watch(appDataProvider)
            .when(
              loading: _loadingView,
              error: (_, _) => SafeArea(
                child: errorState(
                  onRetry: () => ref.invalidate(appDataProvider),
                ),
              ),
              data: (_) => _content(context, ref),
            ),
      ),
    );
  }
}

Widget _content(BuildContext context, WidgetRef ref) {
  final now = ref.watch(clockProvider)();
  final therapist = ref.watch(therapistProvider);
  final summary = ref.watch(dashboardSummaryProvider);
  final today = ref.watch(todaySessionsProvider);
  final upcoming = ref
      .watch(upcomingSessionsProvider)
      .take(_upcomingPreviewCount)
      .toList();

  void setAvailable(bool value) =>
      setAvailabilityWithFeedback(context, ref, value);
  void openTab(BookingTab tab) {
    ref.read(selectedBookingTabProvider.notifier).select(tab);
    context.go(AppRoutes.bookings);
  }

  void openSession(Session session) =>
      context.push(AppRoutes.sessionDetail(session.id));

  return ListView(
    padding: EdgeInsets.zero,
    children: [
      _header(
        therapist: therapist,
        now: now,
        onAvailabilityChanged: setAvailable,
      ),
      responsiveCenter(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.lg,
          AppSpacing.pageGutter,
          AppSpacing.xxl,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _summaryRow(summary, onOpenTab: openTab),
              const SizedBox(height: AppSpacing.xl),
              appSectionHeader(
                eyebrow:
                    '${today.length} ${today.length == 1 ? 'session' : 'sessions'}',
                title: "Today's schedule",
              ),
              const SizedBox(height: AppSpacing.sm),
              _sessionList(
                today,
                onOpen: openSession,
                empty: emptyState(
                  icon: Icons.event_available_rounded,
                  title: 'No sessions today',
                  message:
                      'Enjoy the free time. New bookings will show up here.',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              appSectionHeader(
                eyebrow: 'Next few days',
                title: 'Upcoming sessions',
                actionLabel: 'See all',
                onAction: () => openTab(BookingTab.upcoming),
              ),
              const SizedBox(height: AppSpacing.sm),
              _sessionList(
                upcoming,
                onOpen: openSession,
                showDate: true,
                empty: emptyState(
                  icon: Icons.calendar_month_rounded,
                  title: 'No upcoming sessions',
                  message: 'Accepted booking requests will appear here.',
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _header({
  required Therapist therapist,
  required DateTime now,
  required ValueChanged<bool> onAvailabilityChanged,
}) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.pine, AppColors.pineLight],
      ),
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(AppSpacing.xxl),
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: responsiveCenter(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.md,
          AppSpacing.pageGutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                appAvatar(
                  name: therapist.name,
                  size: 52,
                  backgroundColor: AppColors.amber,
                  foregroundColor: AppColors.ink,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appEyebrow(greetingFor(now), color: AppColors.pinePale),
                      const SizedBox(height: 2),
                      nameText(
                        therapist.name,
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        therapist.specialization,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.pinePale,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.pinePale,
                ),
                Text(
                  formatFullDate(now),
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _availabilityTile(therapist.isAvailable, onAvailabilityChanged),
          ],
        ),
      ),
    ),
  );
}

Widget _availabilityTile(bool isAvailable, ValueChanged<bool> onChanged) {
  return MergeSemantics(
    child: Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: AppRadius.cardBorder,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAvailable ? AppColors.amber : AppColors.inkMute,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAvailable ? 'Available' : 'Unavailable',
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                  Text(
                    isAvailable
                        ? 'Patients can book you'
                        : 'Hidden from new bookings',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.pinePale,
                    ),
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
                    ? AppColors.amber
                    : Colors.white.withValues(alpha: 0.25),
              ),
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _summaryRow(
  ({int todaySessions, int requests, int completed}) summary, {
  required ValueChanged<BookingTab> onOpenTab,
}) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: summaryCard(
            label: "Today's sessions",
            value: '${summary.todaySessions}',
            icon: Icons.today_rounded,
            onTap: () => onOpenTab(BookingTab.upcoming),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: summaryCard(
            label: 'Upcoming requests',
            value: '${summary.requests}',
            icon: Icons.inbox_rounded,
            onTap: () => onOpenTab(BookingTab.requests),
            accent: AppColors.amber,
            accentBackground: AppColors.amberPale,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: summaryCard(
            label: 'Completed sessions',
            value: '${summary.completed}',
            icon: Icons.task_alt_rounded,
            onTap: () => onOpenTab(BookingTab.completed),
            accent: AppColors.inkMid,
            accentBackground: AppColors.mist,
          ),
        ),
      ],
    ),
  );
}

Widget _sessionList(
  List<Session> sessions, {
  required Widget empty,
  required ValueChanged<Session> onOpen,
  bool showDate = false,
}) {
  if (sessions.isEmpty) return appCard(child: empty);
  return Column(
    children: [
      for (final (index, session) in sessions.indexed) ...[
        if (index > 0) const SizedBox(height: AppSpacing.sm),
        sessionCard(
          session: session,
          showDate: showDate,
          onTap: () => onOpen(session),
        ),
      ],
    ],
  );
}

Widget _loadingView() {
  return SafeArea(
    child: responsiveCenter(
      padding: const EdgeInsets.all(AppSpacing.pageGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SkeletonBox(height: 180, radius: AppSpacing.xl),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(child: SkeletonBox(height: 112, radius: AppRadius.card)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox(height: 112, radius: AppRadius.card)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox(height: 112, radius: AppRadius.card)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < 3; i++) ...[
            skeletonCard(),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    ),
  );
}
