import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_bottom_sheet.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_feedback.dart';
import 'package:physio_ghar/core/widgets/app_text_field.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/bookings/view_model/bookings_view_model.dart';

Future<void> acceptBooking(
  BuildContext context,
  WidgetRef ref,
  Session session,
) async {
  await ref.read(bookingActionsProvider.notifier).accept(session.id);
  if (context.mounted) {
    showAppSnackBar(
      context,
      '${stringsOf(context).name(session.patient.name)} accepted · moved to Upcoming',
    );
  }
}

Future<void> declineBooking(
  BuildContext context,
  WidgetRef ref,
  Session session,
) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    title: 'Decline this request?',
    message:
        '${stringsOf(context).name(session.patient.name)} · ${formatShortDate(session.start)}, ${formatTime(session.start)}. '
        'The request will move to Cancelled.',
    confirmLabel: 'Decline',
    isDestructive: true,
  );
  if (!confirmed || !context.mounted) return;

  await ref.read(bookingActionsProvider.notifier).decline(session.id);
  if (context.mounted) {
    showAppSnackBar(context, 'Request declined · moved to Cancelled');
  }
}

Future<void> showCompleteSessionSheet(
  BuildContext context,
  Session session,
) async {
  final completed = await showAppBottomSheet<bool>(
    context: context,
    title: 'Complete session',
    subtitle:
        '${stringsOf(context).name(session.patient.name)} · ${session.treatment}',
    builder: (_) => _CompleteSessionForm(session: session),
  );
  if (completed == true && context.mounted) {
    showAppSnackBar(context, 'Session completed · moved to Completed');
  }
}

Future<void> showRescheduleSheet(BuildContext context, Session session) async {
  final newStart = await showAppBottomSheet<DateTime>(
    context: context,
    title: 'Reschedule session',
    subtitle:
        'Currently ${formatShortDate(session.start)}, ${formatTime(session.start)}',
    builder: (_) => _RescheduleForm(session: session),
  );
  if (newStart != null && context.mounted) {
    showAppSnackBar(
      context,
      'Rescheduled to ${formatShortDate(newStart)}, ${formatTime(newStart)}',
    );
  }
}

class _CompleteSessionForm extends ConsumerStatefulWidget {
  const _CompleteSessionForm({required this.session});

  final Session session;

  @override
  ConsumerState<_CompleteSessionForm> createState() =>
      _CompleteSessionFormState();
}

class _CompleteSessionFormState extends ConsumerState<_CompleteSessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _remarks = TextEditingController();

  @override
  void dispose() {
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(bookingActionsProvider.notifier)
        .complete(widget.session.id, _remarks.text);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref
        .watch(bookingActionsProvider)
        .contains(widget.session.id);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appTextField(
            label: 'Therapist remarks',
            isRequired: true,
            controller: _remarks,
            hint: 'Progress, exercises given, plan for next session…',
            minLines: 4,
            maxLines: 8,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => (value ?? '').trim().isEmpty
                ? 'Add remarks before completing'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          appButton(
            label: 'Mark as completed',
            icon: Icons.check_rounded,
            expand: true,
            isLoading: isBusy,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.xs),
          appButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            expand: true,
            onPressed: isBusy ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _RescheduleForm extends ConsumerStatefulWidget {
  const _RescheduleForm({required this.session});

  final Session session;

  @override
  ConsumerState<_RescheduleForm> createState() => _RescheduleFormState();
}

class _RescheduleFormState extends ConsumerState<_RescheduleForm> {
  DateTime? _day;
  DateTime? _time;
  String? _error;

  Future<void> _submit() async {
    final time = _time;
    if (time == null) {
      setState(() => _error = 'Choose a new time');
      return;
    }
    await ref
        .read(bookingActionsProvider.notifier)
        .reschedule(widget.session.id, time);
    if (mounted) Navigator.of(context).pop(time);
  }

  @override
  Widget build(BuildContext context) {
    final days = ref.watch(rescheduleDaysProvider);
    final day = _day ?? days.firstOrNull;
    final times = day == null
        ? const <DateTime>[]
        : ref.watch(openSlotTimesProvider(day));
    final isBusy = ref
        .watch(bookingActionsProvider)
        .contains(widget.session.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        appFieldLabel('Day', isRequired: true),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final d in days)
              _choiceChip(
                label: formatShortDate(d),
                selected: day != null && isSameDay(d, day),
                onSelected: () => setState(() {
                  _day = d;
                  _time = null;
                  _error = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        appFieldLabel('Open slot', isRequired: true),
        if (times.isEmpty)
          Text(
            'No open slots left on this day. Try another day or add a slot in Schedule.',
            style: AppTextStyles.bodySmall,
          )
        else
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final t in times)
                _choiceChip(
                  label: formatTime(t),
                  selected: t == _time,
                  onSelected: () => setState(() {
                    _time = t;
                    _error = null;
                  }),
                ),
            ],
          ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _error!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        appButton(
          label: 'Confirm new time',
          icon: Icons.event_repeat_rounded,
          variant: AppButtonVariant.secondary,
          expand: true,
          isLoading: isBusy,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.xs),
        appButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          expand: true,
          onPressed: isBusy ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

Widget _choiceChip({
  required String label,
  required bool selected,
  required VoidCallback onSelected,
}) {
  return ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onSelected(),
    showCheckmark: false,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    labelStyle: AppTextStyles.label.copyWith(
      color: selected ? Colors.white : AppColors.ink,
    ),
    selectedColor: AppColors.pine,
    backgroundColor: Colors.white,
    side: BorderSide(
      color: selected ? AppColors.pine : AppColors.mist,
      width: 1.5,
    ),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 6),
  );
}
