import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';

Widget appCard({
  Key? key,
  required Widget child,
  VoidCallback? onTap,
  EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.md),
  Color color = Colors.white,
  Color borderColor = AppColors.mist,
  String? semanticLabel,
}) {
  final card = DecoratedBox(
    key: onTap == null ? key : null,
    decoration: BoxDecoration(
      borderRadius: AppRadius.cardBorder,
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorder,
        side: BorderSide(color: borderColor),
      ),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    ),
  );

  if (onTap == null) return card;
  return Semantics(key: key, button: true, label: semanticLabel, child: card);
}
