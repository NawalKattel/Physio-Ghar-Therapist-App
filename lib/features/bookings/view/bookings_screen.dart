import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/session_card.dart';
import 'package:physio_ghar/core/widgets/skeleton.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/bookings/view/widgets/booking_sheets.dart';
import 'package:physio_ghar/features/bookings/view/widgets/request_actions.dart';
import 'package:physio_ghar/features/bookings/view_model/bookings_view_model.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: BookingTab.values.length,
    initialIndex: ref.read(selectedBookingTabProvider).index,
    vsync: this,
  )..addListener(_onTabChanged);

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    ref
        .read(selectedBookingTabProvider.notifier)
        .select(BookingTab.values[_tabs.index]);
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedBookingTabProvider, (_, tab) {
      if (_tabs.index != tab.index) _tabs.animateTo(tab.index);
    });

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: ref
            .watch(appDataProvider)
            .when(
              loading: _loadingView,
              error: (_, _) =>
                  errorState(onRetry: () => ref.invalidate(appDataProvider)),
              data: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  responsiveCenter(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageGutter,
                      AppSpacing.md,
                      AppSpacing.pageGutter,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appEyebrow('Sessions'),
                        const SizedBox(height: AppSpacing.xxs),
                        Semantics(
                          header: true,
                          child: Text('Bookings', style: AppTextStyles.display),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _tabBar(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        for (final tab in BookingTab.values) _tabList(tab),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _tabBar() {
    return TabBar(
      controller: _tabs,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.only(right: AppSpacing.lg),
      labelColor: AppColors.pine,
      unselectedLabelColor: AppColors.inkMid,
      labelStyle: AppTextStyles.label,
      unselectedLabelStyle: AppTextStyles.label.copyWith(
        fontWeight: FontWeight.w500,
      ),
      indicatorColor: AppColors.pine,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.mist,
      tabs: [
        for (final tab in BookingTab.values)
          Tab(
            height: kMinTapTarget + 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tab.label),
                const SizedBox(width: 6),
                _countBadge(ref.watch(bookingsForTabProvider(tab)).length, tab),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tabList(BookingTab tab) {
    final sessions = ref.watch(bookingsForTabProvider(tab));
    final busy = ref.watch(bookingActionsProvider);

    if (sessions.isEmpty) return _emptyTab(tab);

    return responsiveCenter(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.md,
          AppSpacing.pageGutter,
          AppSpacing.xxl,
        ),
        itemCount: sessions.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final session = sessions[index];
          return sessionCard(
            session: session,
            showDate: true,
            onTap: () => context.push(AppRoutes.sessionDetail(session.id)),
            footer: tab == BookingTab.requests
                ? requestActions(
                    isBusy: busy.contains(session.id),
                    onAccept: () => acceptBooking(context, ref, session),
                    onDecline: () => declineBooking(context, ref, session),
                  )
                : null,
          );
        },
      ),
    );
  }
}

Widget _countBadge(int count, BookingTab tab) {
  final highlight = tab == BookingTab.requests && count > 0;
  return Container(
    constraints: const BoxConstraints(minWidth: 22),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: highlight ? AppColors.amber : AppColors.mist,
      borderRadius: AppRadius.pillBorder,
    ),
    child: Text(
      '$count',
      textAlign: TextAlign.center,
      style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.ink),
    ),
  );
}

Widget _emptyTab(BookingTab tab) {
  final (icon, title, message) = switch (tab) {
    BookingTab.requests => (
      Icons.inbox_rounded,
      'No pending requests',
      'New booking requests from patients will appear here.',
    ),
    BookingTab.upcoming => (
      Icons.calendar_month_rounded,
      'No upcoming sessions',
      'Accept a booking request to add it here.',
    ),
    BookingTab.completed => (
      Icons.task_alt_rounded,
      'No completed sessions yet',
      'Sessions you mark as completed will appear here.',
    ),
    BookingTab.cancelled => (
      Icons.event_busy_rounded,
      'No cancelled sessions',
      'Declined requests will appear here.',
    ),
  };
  return emptyState(icon: icon, title: title, message: message);
}

Widget _loadingView() {
  return ListView(
    padding: const EdgeInsets.all(AppSpacing.pageGutter),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      const SkeletonBox(width: 80, height: 14),
      const SizedBox(height: AppSpacing.xs),
      const SkeletonBox(width: 170, height: 32),
      const SizedBox(height: AppSpacing.lg),
      const SkeletonBox(height: 36, radius: AppRadius.pill),
      const SizedBox(height: AppSpacing.lg),
      for (var i = 0; i < 4; i++) ...[
        skeletonCard(),
        const SizedBox(height: AppSpacing.sm),
      ],
    ],
  );
}
