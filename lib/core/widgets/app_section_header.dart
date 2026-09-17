import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';

Widget appEyebrow(String text, {Color? color}) {
  return Text(
    text.toUpperCase(),
    style: color == null
        ? AppTextStyles.eyebrow
        : AppTextStyles.eyebrow.copyWith(color: color),
  );
}

Widget appSectionHeader({
  required String title,
  String? eyebrow,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[
              appEyebrow(eyebrow),
              const SizedBox(height: AppSpacing.xxs),
            ],
            Semantics(
              header: true,
              child: Text(title, style: AppTextStyles.title),
            ),
          ],
        ),
      ),
      if (actionLabel != null && onAction != null)
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.pine,
            minimumSize: const Size(kMinTapTarget, kMinTapTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            textStyle: AppTextStyles.label,
            shape: const StadiumBorder(),
          ),
          child: Text(actionLabel),
        ),
    ],
  );
}
