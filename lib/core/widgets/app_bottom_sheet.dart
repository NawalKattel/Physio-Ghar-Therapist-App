import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  String? subtitle,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          0,
          AppSpacing.pageGutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTextStyles.headline),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: AppTextStyles.body.copyWith(color: AppColors.inkMid),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            builder(context),
          ],
        ),
      ),
    ),
  );
}
