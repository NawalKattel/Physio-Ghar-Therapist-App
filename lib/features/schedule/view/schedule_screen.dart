import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/availability_card.dart';
import 'package:physio_ghar/features/account/view/widgets/availability_feedback.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/skeleton.dart';
import 'package:physio_ghar/features/schedule/view/widgets/slot_tile.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/schedule/view_model/schedule_view_model.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';
import 'package:physio_ghar/features/schedule/view/widgets/schedule_sheets.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              data: (_) => _content(context, ref),
            ),
      ),
    );
  }
}

Widget _content(BuildContext context, WidgetRef ref) {
  final week = ref.watch(currentWeekProvider);
  final selected = ref.watch(selectedDateProvider);
  final today = dateOnly(ref.watch(clockProvider)());
  final isAvailable = ref.watch(therapistProvider.select((t) => t.isAvailable));
  final slots = ref.watch(daySlotsProvider(selected));

  int count(SlotState state) => slots.where((s) => s.state == state).length;

  return ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
    children: [
      responsiveCenter(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.md,
          AppSpacing.pageGutter,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            appEyebrow('This week · ${formatDateRange(week.first, week.last)}'),
            const SizedBox(height: AppSpacing.xxs),
            Semantics(
              header: true,
              child: Text('Schedule', style: AppTextStyles.display),
            ),
            const SizedBox(height: AppSpacing.md),
            availabilityCard(
              isAvailable: isAvailable,
              onChanged: (value) =>
                  setAvailabilityWithFeedback(context, ref, value),
            ),
            if (!isAvailable) ...[
              const SizedBox(height: AppSpacing.xs),
              _unavailableBanner(),
            ],
            const SizedBox(height: AppSpacing.lg),
            _weekStrip(
              week: week,
              selected: selected,
              today: today,
              onSelect: ref.read(selectedDateProvider.notifier).select,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          formatFullDate(selected),
                          style: AppTextStyles.title,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${count(SlotState.open)} open · ${count(SlotState.booked)} booked · '
                        '${count(SlotState.blocked)} blocked',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                appButton(
                  label: 'Add slot',
                  icon: Icons.add_rounded,
                  variant: AppButtonVariant.secondary,
                  compact: true,
                  onPressed: () => showAddSlotSheet(context, selected),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _legend(),
            const SizedBox(height: AppSpacing.md),
            if (slots.isEmpty)
              emptyState(
                icon: Icons.event_busy_rounded,
                title: 'No slots on this day',
                message: 'Add a time slot so patients can book you.',
                actionLabel: 'Add slot',
                onAction: () => showAddSlotSheet(context, selected),
              )
            else
              for (final slot in slots)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: slotTile(
                    slot: slot,
                    onTap: () => showSlotActionsSheet(context, ref, slot),
                  ),
                ),
          ],
        ),
      ),
    ],
  );
}

Widget _unavailableBanner() {
  return Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: AppColors.amberPale,
      borderRadius: AppRadius.fieldBorder,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.ink),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            "You're hidden from new bookings. Existing sessions stay booked and "
            'you can still edit your slots.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    ),
  );
}

Widget _weekStrip({
  required List<DateTime> week,
  required DateTime selected,
  required DateTime today,
  required ValueChanged<DateTime> onSelect,
}) {
  return Row(
    children: [
      for (final (index, day) in week.indexed) ...[
        if (index > 0) const SizedBox(width: 6),
        Expanded(
          child: _dayChip(
            day: day,
            isSelected: isSameDay(day, selected),
            isToday: isSameDay(day, today),
            onTap: () => onSelect(day),
          ),
        ),
      ],
    ],
  );
}

Widget _dayChip({
  required DateTime day,
  required bool isSelected,
  required bool isToday,
  required VoidCallback onTap,
}) {
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: isSelected
          ? AppColors.pine
          : isToday
          ? AppColors.pine.withValues(alpha: 0.5)
          : AppColors.mist,
      width: 1.5,
    ),
  );
  final foreground = isSelected ? Colors.white : AppColors.ink;

  return Semantics(
    button: true,
    selected: isSelected,
    label: '${formatFullDate(day)}${isToday ? ', today' : ''}',
    excludeSemantics: true,
    child: Material(
      color: isSelected ? AppColors.pine : Colors.white,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                formatWeekdayShort(day),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: isSelected ? AppColors.pinePale : AppColors.inkMid,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${day.day}',
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  color: foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.amber : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _legend() {
  Widget item(Color fill, Color border, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: border, width: 1.5),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.bodySmall),
    ],
  );

  return Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.xxs,
    children: [
      item(Colors.white, AppColors.pine.withValues(alpha: 0.35), 'Open'),
      item(AppColors.pine, AppColors.pine, 'Booked'),
      item(AppColors.mist, AppColors.inkMute, 'Blocked'),
    ],
  );
}

Widget _loadingView() {
  return ListView(
    padding: const EdgeInsets.all(AppSpacing.pageGutter),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      const SkeletonBox(width: 160, height: 14),
      const SizedBox(height: AppSpacing.xs),
      const SkeletonBox(width: 180, height: 32),
      const SizedBox(height: AppSpacing.md),
      const SkeletonBox(height: 64, radius: AppRadius.card),
      const SizedBox(height: AppSpacing.lg),
      Row(
        children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            const Expanded(child: SkeletonBox(height: 72, radius: 14)),
          ],
        ],
      ),
      const SizedBox(height: AppSpacing.xl),
      for (var i = 0; i < 5; i++) ...[
        const SkeletonBox(height: 52, radius: AppRadius.card),
        const SizedBox(height: AppSpacing.xs),
      ],
    ],
  );
}
