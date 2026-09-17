import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_button.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';

Widget welcomeScreen({required VoidCallback onGetStarted}) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(child: _hero()),
                SafeArea(
                  top: false,
                  child: responsiveCenter(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageGutter,
                      AppSpacing.xl,
                      AppSpacing.pageGutter,
                      AppSpacing.md,
                    ),
                    child: _intro(onGetStarted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _hero() {
  return Container(
    width: double.infinity,
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
            _brandMark(),
            const SizedBox(height: AppSpacing.xl),
            Expanded(child: Center(child: _illustration())),
            const SizedBox(height: AppSpacing.xl),
            appEyebrow('For physiotherapists', color: AppColors.pinePale),
            const SizedBox(height: AppSpacing.xs),
            Semantics(
              header: true,
              child: Text(
                'Care that comes home.',
                style: AppTextStyles.display.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _brandMark() {
  return Row(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.amber,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.spa_rounded, size: 20, color: AppColors.ink),
      ),
      const SizedBox(width: AppSpacing.sm),
      Text(
        'PhysioGhar',
        style: AppTextStyles.title.copyWith(color: Colors.white),
      ),
    ],
  );
}

Widget _illustration() {
  return ExcludeSemantics(
    child: SizedBox(
      width: 240,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 124,
            height: 124,
            decoration: const BoxDecoration(
              color: AppColors.pinePale,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.accessibility_new_rounded,
              size: 64,
              color: AppColors.pine,
            ),
          ),
          Positioned(
            top: 8,
            left: 0,
            child: _floatingChip(Icons.home_rounded, 'Home visits'),
          ),
          Positioned(
            bottom: 8,
            right: 0,
            child: _floatingChip(
              Icons.local_hospital_rounded,
              'Clinic sessions',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _floatingChip(IconData icon, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: AppRadius.pillBorder,
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.amber),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 12)),
      ],
    ),
  );
}

Widget _intro(VoidCallback onGetStarted) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Your schedule, booking requests and patient notes — all in one place.',
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.inkMid),
      ),
      const SizedBox(height: AppSpacing.lg),
      _featureRow(
        Icons.calendar_month_rounded,
        'Manage your weekly availability',
      ),
      const SizedBox(height: AppSpacing.sm),
      _featureRow(
        Icons.event_available_rounded,
        'Accept requests and track sessions',
      ),
      const SizedBox(height: AppSpacing.sm),
      _featureRow(
        Icons.sticky_note_2_rounded,
        'Keep treatment notes for every patient',
      ),
      const SizedBox(height: AppSpacing.xl),
      appButton(
        label: 'Get started',
        icon: Icons.arrow_forward_rounded,
        onPressed: onGetStarted,
        expand: true,
      ),
    ],
  );
}

Widget _featureRow(IconData icon, String text) {
  return Row(
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
      Expanded(child: Text(text, style: AppTextStyles.body)),
    ],
  );
}
