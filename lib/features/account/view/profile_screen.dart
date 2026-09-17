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
import 'package:physio_ghar/core/widgets/responsive_center.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isLoaded = ref.watch(appDataProvider).hasValue;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(strings.myProfile, style: AppTextStyles.title),
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        actions: [
          if (isLoaded)
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.editProfile),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(strings.editProfile),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.pine,
                minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                textStyle: AppTextStyles.label,
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pine),
            )
          : _content(ref),
    );
  }
}

Widget _content(WidgetRef ref) {
  final therapist = ref.watch(therapistProvider);
  final strings = ref.watch(stringsProvider);

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
            Center(
              child: appAvatar(
                name: therapist.name,
                size: 96,
                backgroundColor: AppColors.amber,
                foregroundColor: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            nameText(
              therapist.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              therapist.specialization,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.inkMid),
            ),
            const SizedBox(height: AppSpacing.xl),
            appCard(
              child: Column(
                children: [
                  _infoRow(
                    Icons.mail_outline_rounded,
                    'Email',
                    therapist.email,
                  ),
                  _infoRow(Icons.phone_outlined, 'Phone', therapist.phone),
                  _infoRow(
                    Icons.workspace_premium_outlined,
                    'Experience',
                    '${therapist.experienceYears} '
                        '${therapist.experienceYears == 1 ? 'year' : 'years'}',
                  ),
                  _infoRow(
                    Icons.medical_services_outlined,
                    'Specialization',
                    therapist.specialization,
                  ),
                  _infoRow(
                    Icons.place_outlined,
                    'Address',
                    strings.place(therapist.address),
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _infoRow(
  IconData icon,
  String label,
  String value, {
  bool isLast = false,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
      ],
    ),
  );
}
