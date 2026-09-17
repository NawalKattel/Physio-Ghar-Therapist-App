import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/skeleton.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/patients/view/widgets/patient_card.dart';
import 'package:physio_ghar/features/patients/view_model/patients_view_model.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

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
  final patients = ref.watch(patientsProvider);

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
            appEyebrow('Records · ${patients.length} patients'),
            const SizedBox(height: AppSpacing.xxs),
            Semantics(
              header: true,
              child: Text('Patients', style: AppTextStyles.display),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (patients.isEmpty)
              emptyState(
                icon: Icons.people_alt_rounded,
                title: 'No patients yet',
                message:
                    'Patients appear here once they book a session with you.',
              )
            else
              for (final patient in patients)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: patientCard(
                    patient: patient,
                    lastSession: ref
                        .watch(lastCompletedSessionProvider(patient.id))
                        ?.start,
                    onTap: () =>
                        context.push(AppRoutes.patientDetail(patient.id)),
                  ),
                ),
          ],
        ),
      ),
    ],
  );
}

Widget _loadingView() {
  return ListView(
    padding: const EdgeInsets.all(AppSpacing.pageGutter),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      const SkeletonBox(width: 140, height: 14),
      const SizedBox(height: AppSpacing.xs),
      const SkeletonBox(width: 160, height: 32),
      const SizedBox(height: AppSpacing.lg),
      for (var i = 0; i < 6; i++) ...[
        skeletonCard(),
        const SizedBox(height: AppSpacing.sm),
      ],
    ],
  );
}
