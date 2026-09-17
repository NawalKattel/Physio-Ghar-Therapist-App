import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/utils/formatters.dart';
import 'package:physio_ghar/core/widgets/app_avatar.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/core/widgets/app_feedback.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/session_card.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/features/patients/model/patient.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/patients/view/widgets/note_card.dart';
import 'package:physio_ghar/features/patients/view_model/patients_view_model.dart';

class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoaded = ref.watch(appDataProvider).hasValue;
    final patient = isLoaded ? ref.watch(patientByIdProvider(patientId)) : null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Patient record', style: AppTextStyles.title),
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pine),
            )
          : patient == null
          ? emptyState(
              icon: Icons.person_search_rounded,
              title: 'Patient not found',
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            )
          : _content(context, ref, patient),
    );
  }
}

Widget _content(BuildContext context, WidgetRef ref, Patient patient) {
  final lastSession = ref.watch(lastCompletedSessionProvider(patient.id));
  final history = ref.watch(patientSessionsProvider(patient.id));
  final notes = ref.watch(patientNotesProvider(patient.id));
  final strings = ref.watch(stringsProvider);

  void addNote() => context.push(AppRoutes.newNote(patient.id));

  return ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
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
            _profileCard(patient, strings),
            const SizedBox(height: AppSpacing.md),
            _contactCard(
              patient,
              strings,
              onCall: () =>
                  showAppSnackBar(context, 'Calling ${patient.phone}… (demo)'),
            ),
            const SizedBox(height: AppSpacing.md),
            appCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appEyebrow('Condition'),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    patient.condition,
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  appEyebrow('Treatment plan'),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(patient.treatmentPlan, style: AppTextStyles.body),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            appSectionHeader(eyebrow: 'Most recent', title: 'Previous session'),
            const SizedBox(height: AppSpacing.sm),
            if (lastSession == null)
              appCard(
                child: emptyState(
                  icon: Icons.history_rounded,
                  title: 'No completed sessions yet',
                ),
              )
            else
              appCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${formatFullDate(lastSession.start)} · ${formatTime(lastSession.start)}',
                      style: AppTextStyles.label,
                    ),
                    Text(lastSession.treatment, style: AppTextStyles.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    appEyebrow('Therapist remarks'),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      lastSession.remarks?.isNotEmpty == true
                          ? lastSession.remarks!
                          : 'No remarks recorded.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: appSectionHeader(
                    eyebrow:
                        '${notes.length} ${notes.length == 1 ? 'note' : 'notes'}',
                    title: 'Notes',
                  ),
                ),
                appButton(
                  label: 'Add note',
                  icon: Icons.add_rounded,
                  variant: AppButtonVariant.secondary,
                  compact: true,
                  onPressed: addNote,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (notes.isEmpty)
              appCard(
                child: emptyState(
                  icon: Icons.sticky_note_2_outlined,
                  title: 'No notes yet',
                  message:
                      'Record progress, exercises and plans for the next session.',
                  actionLabel: 'Add note',
                  onAction: addNote,
                ),
              )
            else
              for (final note in notes)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: noteCard(
                    note: note,
                    onEdit: () =>
                        context.push(AppRoutes.editNote(patient.id, note.id)),
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),
            appSectionHeader(
              eyebrow:
                  '${history.length} ${history.length == 1 ? 'session' : 'sessions'}',
              title: 'Treatment history',
            ),
            const SizedBox(height: AppSpacing.sm),
            if (history.isEmpty)
              appCard(
                child: emptyState(
                  icon: Icons.event_note_rounded,
                  title: 'No sessions yet',
                ),
              )
            else
              for (final session in history)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: sessionCard(
                    session: session,
                    showDate: true,
                    onTap: () =>
                        context.push(AppRoutes.sessionDetail(session.id)),
                  ),
                ),
          ],
        ),
      ),
    ],
  );
}

Widget _profileCard(Patient patient, AppStrings strings) {
  return appCard(
    child: Row(
      children: [
        appAvatar(name: patient.name, size: 64),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameText(patient.name, style: AppTextStyles.headline),
              const SizedBox(height: 2),
              Text(
                '${strings.age(patient.age)} · ${patient.gender}',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _contactCard(
  Patient patient,
  AppStrings strings, {
  required VoidCallback onCall,
}) {
  return appCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        _contactRow(
          icon: Icons.phone_rounded,
          label: 'Phone',
          value: patient.phone,
          onTap: onCall,
          trailing: Icons.call_rounded,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.mist),
        _contactRow(
          icon: Icons.place_rounded,
          label: 'Address',
          value: strings.place(patient.address),
        ),
      ],
    ),
  );
}

Widget _contactRow({
  required IconData icon,
  required String label,
  required String value,
  VoidCallback? onTap,
  IconData? trailing,
}) {
  final row = Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    child: Row(
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
        if (trailing != null) Icon(trailing, size: 20, color: AppColors.pine),
      ],
    ),
  );

  if (onTap == null) return row;
  return Semantics(
    button: true,
    label: 'Call $value',
    excludeSemantics: true,
    child: InkWell(onTap: onTap, child: row),
  );
}
