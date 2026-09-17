import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';

Widget authLayout({
  required String title,
  required String subtitle,
  required List<Widget> children,
}) {
  return Scaffold(
    backgroundColor: AppColors.cream,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          responsiveCenter(
            maxWidth: 480,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.xl,
              AppSpacing.pageGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.pine, AppColors.pineLight],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('PhysioGhar', style: AppTextStyles.title),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                appEyebrow('Therapist app'),
                const SizedBox(height: AppSpacing.xxs),
                Semantics(
                  header: true,
                  child: Text(title, style: AppTextStyles.display),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(color: AppColors.inkMid),
                ),
                const SizedBox(height: AppSpacing.xl),
                ...children,
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget authErrorBanner(String message) {
  return Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.dangerPale,
        borderRadius: AppRadius.fieldBorder,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget authSwitchLink({
  required String prompt,
  required String action,
  required VoidCallback onTap,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Flexible(
        child: Text(
          prompt,
          style: AppTextStyles.body.copyWith(color: AppColors.inkMid),
        ),
      ),
      TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pine,
          minimumSize: const Size(kMinTapTarget, kMinTapTarget),
          textStyle: AppTextStyles.label,
        ),
        child: Text(action),
      ),
    ],
  );
}

Widget passwordVisibilityToggle({
  required bool isHidden,
  required VoidCallback onToggle,
}) {
  return IconButton(
    onPressed: onToggle,
    tooltip: isHidden ? 'Show password' : 'Hide password',
    icon: Icon(
      isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      color: AppColors.inkMid,
    ),
  );
}
