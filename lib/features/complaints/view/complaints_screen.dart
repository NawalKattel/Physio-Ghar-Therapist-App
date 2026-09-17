import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/features/complaints/model/complaint.dart';
import 'package:physio_ghar/features/complaints/view/widgets/complaint_card.dart';
import 'package:physio_ghar/features/complaints/view_model/complaints_view_model.dart';

class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isLoaded = ref.watch(appDataProvider).hasValue;
    void newComplaint() => context.push(AppRoutes.newComplaint);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(strings.reportIssue, style: AppTextStyles.title),
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pine),
            )
          : _content(ref.watch(complaintsProvider), onNew: newComplaint),
      bottomNavigationBar: !isLoaded
          ? null
          : SafeArea(
              top: false,
              child: responsiveCenter(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.sm,
                  AppSpacing.pageGutter,
                  AppSpacing.sm,
                ),
                child: appButton(
                  label: 'New complaint',
                  icon: Icons.add_rounded,
                  expand: true,
                  onPressed: newComplaint,
                ),
              ),
            ),
    );
  }
}

Widget _content(List<Complaint> complaints, {required VoidCallback onNew}) {
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
              color: AppColors.pinePale,
              borderColor: AppColors.pinePale,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.pine,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Had a problem with a patient, booking, payment or the app? '
                      'Tell the PhysioGhar admin team and they will look into it.',
                      style: AppTextStyles.body.copyWith(color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            appSectionHeader(
              eyebrow: '${complaints.length} submitted',
              title: 'Previous complaints',
            ),
            const SizedBox(height: AppSpacing.sm),
            if (complaints.isEmpty)
              appCard(
                child: emptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No complaints yet',
                  message: 'Anything you report will be listed here.',
                  actionLabel: 'Report an issue',
                  onAction: onNew,
                ),
              )
            else
              for (final complaint in complaints)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: complaintCard(complaint),
                ),
          ],
        ),
      ),
    ],
  );
}
