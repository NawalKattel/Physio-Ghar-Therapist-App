import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/repository/app_repository.dart';
import 'package:physio_ghar/core/router/app_router.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_bottom_sheet.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_feedback.dart';
import 'package:physio_ghar/core/widgets/app_text_field.dart';
import 'package:physio_ghar/core/widgets/session_card.dart';
import 'package:physio_ghar/features/schedule/model/slot.dart';
import 'package:physio_ghar/features/schedule/view_model/schedule_view_model.dart';

Future<void> showSlotActionsSheet(
  BuildContext context,
  WidgetRef ref,
  ScheduleSlot slot,
) async {
  final time = formatTime(slot.start);
  final subtitle = formatFullDate(slot.start);
  final schedule = ref.read(scheduleActionsProvider);

  switch (slot.state) {
    case SlotState.open:
      final block = await _confirmSheet(
        context,
        title: '$time · Open',
        subtitle: subtitle,
        message:
            "Patients can book this time. Block it if you won't be available.",
        actionLabel: 'Block slot',
        actionIcon: Icons.lock_rounded,
        variant: AppButtonVariant.secondary,
      );
      if (!block || !context.mounted) return;
      try {
        await schedule.block(slot);
      } on RepositoryException catch (error) {
        if (context.mounted) {
          showAppSnackBar(context, error.message, isError: true);
        }
        return;
      }
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        '$time is now blocked',
        actionLabel: 'Undo',
        onAction: () => schedule.unblock(slot),
      );

    case SlotState.blocked:
      final unblock = await _confirmSheet(
        context,
        title: '$time · Blocked',
        subtitle: subtitle,
        message: 'Unblock this time to let patients book it again.',
        actionLabel: 'Unblock slot',
        actionIcon: Icons.lock_open_rounded,
        variant: AppButtonVariant.primary,
      );
      if (!unblock || !context.mounted) return;
      try {
        await schedule.unblock(slot);
      } on RepositoryException catch (error) {
        if (context.mounted) {
          showAppSnackBar(context, error.message, isError: true);
        }
        return;
      }
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        '$time is open again',
        actionLabel: 'Undo',
        onAction: () => schedule.block(slot),
      );

    case SlotState.booked:
      await showAppBottomSheet<void>(
        context: context,
        title: '$time · Booked',
        subtitle: subtitle,
        builder: (sheetContext) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (slot.session case final session?) sessionCard(session: session),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Booked slots can't be blocked. To move this session, reschedule it from Bookings.",
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (slot.session case final session?) ...[
              appButton(
                label: 'View session',
                icon: Icons.open_in_new_rounded,
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRoutes.sessionDetail(session.id));
                },
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            appButton(
              label: 'Close',
              variant: AppButtonVariant.ghost,
              expand: true,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
  }
}

Future<bool> _confirmSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String message,
  required String actionLabel,
  required IconData actionIcon,
  required AppButtonVariant variant,
}) async {
  final result = await showAppBottomSheet<bool>(
    context: context,
    title: title,
    subtitle: subtitle,
    builder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.inkMid),
        ),
        const SizedBox(height: AppSpacing.lg),
        appButton(
          label: actionLabel,
          icon: actionIcon,
          variant: variant,
          expand: true,
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        const SizedBox(height: AppSpacing.xs),
        appButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          expand: true,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> showAddSlotSheet(BuildContext context, DateTime day) async {
  final added = await showAppBottomSheet<DateTime>(
    context: context,
    title: 'Add time slot',
    subtitle: formatFullDate(day),
    builder: (_) => _AddSlotForm(day: day),
  );
  if (added != null && context.mounted) {
    showAppSnackBar(context, 'Slot added at ${formatTime(added)}');
  }
}

class _AddSlotForm extends ConsumerStatefulWidget {
  const _AddSlotForm({required this.day});

  final DateTime day;

  @override
  ConsumerState<_AddSlotForm> createState() => _AddSlotFormState();
}

class _AddSlotFormState extends ConsumerState<_AddSlotForm> {
  TimeOfDay? _time;
  String? _error;
  bool _isSaving = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Slot start time',
    );
    if (picked != null) {
      setState(() {
        _time = picked;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    final time = _time;
    if (time == null) {
      setState(() => _error = 'Pick a time for the new slot');
      return;
    }

    final day = widget.day;
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      time.hour,
      time.minute,
    );
    setState(() => _isSaving = true);

    final AddSlotError? error;
    try {
      error = await ref.read(scheduleActionsProvider).add(start);
    } on RepositoryException catch (failure) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = failure.message;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (error) {
      case AddSlotError.past:
        setState(() => _error = 'This time has already passed');
      case AddSlotError.duplicate:
        setState(() => _error = 'A slot already exists at this time');
      case null:
        Navigator.of(context).pop(start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        appFieldLabel('Start time', isRequired: true),
        Semantics(
          button: true,
          label: _time == null
              ? 'Select a start time'
              : 'Start time ${_time!.format(context)}',
          excludeSemantics: true,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.fieldBorder,
              side: BorderSide(
                color: hasError ? AppColors.danger : AppColors.mist,
                width: 1.5,
              ),
            ),
            child: InkWell(
              onTap: _pickTime,
              customBorder: const RoundedRectangleBorder(
                borderRadius: AppRadius.fieldBorder,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: AppColors.inkMid,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _time?.format(context) ?? 'Select a time',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _time == null
                                ? AppColors.inkMute
                                : AppColors.ink,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.inkMid,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _error ?? 'Slots are one hour long.',
          style: AppTextStyles.bodySmall.copyWith(
            color: hasError ? AppColors.danger : null,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        appButton(
          label: 'Add slot',
          icon: Icons.add_rounded,
          expand: true,
          isLoading: _isSaving,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.xs),
        appButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
