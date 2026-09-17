import 'package:flutter/material.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';

String avatarInitials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !w.endsWith('.'))
      .toList();
  if (words.isEmpty) return '?';
  final first = words.first[0];
  final last = words.length > 1 ? words.last[0] : '';
  return (first + last).toUpperCase();
}

Widget appAvatar({
  required String name,
  double size = 44,
  Color backgroundColor = AppColors.pinePale,
  Color foregroundColor = AppColors.pine,
}) {
  return Semantics(
    label: name,
    image: true,
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: ExcludeSemantics(
        child: Text(
          avatarInitials(name),
          style: AppTextStyles.title.copyWith(
            fontSize: size * 0.38,
            color: foregroundColor,
            height: 1,
          ),
        ),
      ),
    ),
  );
}
