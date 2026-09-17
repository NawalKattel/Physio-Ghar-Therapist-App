import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/widgets/app_card.dart';

Widget summaryCard({
  required String label,
  required String value,
  required IconData icon,
  Color accent = AppColors.pine,
  Color accentBackground = AppColors.pinePale,
  VoidCallback? onTap,
}) {
  return appCard(
    onTap: onTap,
    semanticLabel: '$label: $value',
    padding: const EdgeInsets.all(AppSpacing.sm),
    child: ExcludeSemantics(
      excluding: onTap != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.stat),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
