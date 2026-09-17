import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/features/complaints/view/widgets/complaint_card.dart';
import 'package:physio_ghar/features/complaints/view_model/complaints_view_model.dart';

class ComplaintSuccessScreen extends ConsumerWidget {
  const ComplaintSuccessScreen({super.key, required this.complaintId});

  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoaded = ref.watch(appDataProvider).hasValue;
    final complaint = isLoaded
        ? ref.watch(complaintByIdProvider(complaintId))
        : null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: complaint == null
          ? emptyState(
              icon: Icons.search_off_rounded,
              title: 'Complaint not found',
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                responsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppColors.pinePale,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 48,
                            color: AppColors.pine,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Semantics(
                        header: true,
                        liveRegion: true,
                        child: Text(
                          'Complaint submitted',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'The PhysioGhar admin team will review it. '
                        'Quote this reference if you contact them.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.inkMid,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.amberPale,
                            borderRadius: AppRadius.pillBorder,
                          ),
                          child: Text(
                            complaint.reference,
                            style: AppTextStyles.title.copyWith(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      complaintCard(complaint),
                      const SizedBox(height: AppSpacing.xl),
                      appButton(
                        label: 'Back to complaints',
                        variant: AppButtonVariant.secondary,
                        expand: true,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
