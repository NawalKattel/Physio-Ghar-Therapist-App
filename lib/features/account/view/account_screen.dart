import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_avatar.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';
import 'package:physio_ghar/core/widgets/app_feedback.dart';
import 'package:physio_ghar/core/widgets/app_section_header.dart';
import 'package:physio_ghar/core/widgets/availability_card.dart';
import 'package:physio_ghar/features/account/view/widgets/availability_feedback.dart';
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/core/widgets/skeleton.dart';
import 'package:physio_ghar/core/widgets/state_views.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';
import 'package:physio_ghar/features/auth/view_model/auth_view_model.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

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
  final therapist = ref.watch(therapistProvider);
  final strings = ref.watch(stringsProvider);
  final language = ref.watch(languageProvider);

  Future<void> logout() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Log out?',
      message: "You'll need to log in again to see your sessions and patients.",
      confirmLabel: strings.logout,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    showAppSnackBar(context, "You've logged out");
    ref.read(authProvider.notifier).logout();
  }

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
            Semantics(
              header: true,
              child: Text(strings.account, style: AppTextStyles.display),
            ),
            const SizedBox(height: AppSpacing.lg),
            appCard(
              onTap: () => context.push(AppRoutes.profile),
              semanticLabel:
                  '${therapist.name}, ${therapist.specialization}. ${strings.myProfile}',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    appAvatar(
                      name: therapist.name,
                      size: 56,
                      backgroundColor: AppColors.amber,
                      foregroundColor: AppColors.ink,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          nameText(therapist.name, style: AppTextStyles.title),
                          Text(
                            therapist.specialization,
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            therapist.email,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.inkMute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkMute,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            appEyebrow(strings.profileSection),
            const SizedBox(height: AppSpacing.xs),
            _menuGroup([
              _menuRow(
                icon: Icons.person_outline_rounded,
                label: strings.myProfile,
                onTap: () => context.push(AppRoutes.profile),
              ),
              _menuRow(
                icon: Icons.edit_outlined,
                label: strings.editProfile,
                onTap: () => context.push(AppRoutes.editProfile),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),
            appEyebrow(strings.preferencesSection),
            const SizedBox(height: AppSpacing.xs),
            availabilityCard(
              isAvailable: therapist.isAvailable,
              onChanged: (value) =>
                  setAvailabilityWithFeedback(context, ref, value),
            ),
            const SizedBox(height: AppSpacing.sm),
            appCard(
              child: Row(
                children: [
                  _menuIcon(Icons.translate_rounded),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(strings.language, style: AppTextStyles.label),
                  ),
                  _languageToggle(
                    selected: language,
                    onSelected: (value) =>
                        ref.read(languageProvider.notifier).set(value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            appEyebrow(strings.supportSection),
            const SizedBox(height: AppSpacing.xs),
            _menuGroup([
              _menuRow(
                icon: Icons.report_problem_outlined,
                label: strings.reportIssue,
                onTap: () => context.push(AppRoutes.complaints),
              ),
              _menuRow(
                icon: Icons.logout_rounded,
                label: strings.logout,
                onTap: logout,
                isDestructive: true,
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: appEyebrow(
                'PhysioGhar Therapist · v1.0.0',
                color: AppColors.inkMute,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _menuGroup(List<Widget> rows) {
  return appCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0)
            const Divider(
              height: 1,
              thickness: 1,
              indent: 64,
              color: AppColors.mist,
            ),
          row,
        ],
      ],
    ),
  );
}

Widget _menuRow({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool isDestructive = false,
}) {
  final color = isDestructive ? AppColors.danger : AppColors.ink;
  return Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              _menuIcon(icon, isDestructive: isDestructive),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(color: color),
                ),
              ),
              if (!isDestructive)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkMute,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _menuIcon(IconData icon, {bool isDestructive = false}) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: isDestructive ? AppColors.dangerPale : AppColors.pinePale,
      shape: BoxShape.circle,
    ),
    child: Icon(
      icon,
      size: 18,
      color: isDestructive ? AppColors.danger : AppColors.pine,
    ),
  );
}

Widget _languageToggle({
  required AppLanguage selected,
  required ValueChanged<AppLanguage> onSelected,
}) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.mist,
      borderRadius: AppRadius.pillBorder,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final language in AppLanguage.values)
          Semantics(
            button: true,
            selected: language == selected,
            label: language.nativeName,
            excludeSemantics: true,
            child: Material(
              color: language == selected ? AppColors.pine : Colors.transparent,
              shape: const StadiumBorder(),
              child: InkWell(
                onTap: () => onSelected(language),
                customBorder: const StadiumBorder(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: kMinTapTarget,
                    minHeight: kMinTapTarget,
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        language.shortLabel,
                        style: AppTextStyles.label.copyWith(
                          color: language == selected
                              ? Colors.white
                              : AppColors.inkMid,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _loadingView() {
  return ListView(
    padding: const EdgeInsets.all(AppSpacing.pageGutter),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      const SkeletonBox(width: 150, height: 32),
      const SizedBox(height: AppSpacing.lg),
      skeletonCard(),
      const SizedBox(height: AppSpacing.xl),
      for (var i = 0; i < 4; i++) ...[
        const SkeletonBox(height: 56, radius: AppRadius.card),
        const SizedBox(height: AppSpacing.sm),
      ],
    ],
  );
}
