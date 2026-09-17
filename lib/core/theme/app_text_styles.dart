import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:physio_ghar/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static bool useGoogleFonts = true;

  static TextStyle _font(String family, TextStyle style) {
    if (!useGoogleFonts) return style.copyWith(fontFamily: family);
    return GoogleFonts.getFont(family, textStyle: style).copyWith(
      fontFamilyFallback: [GoogleFonts.notoSansDevanagari().fontFamily!],
    );
  }

  static TextStyle get display => _font(
    'Fraunces',
    const TextStyle(
      fontSize: 32,
      height: 1.15,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );
  static TextStyle get headline => _font(
    'Fraunces',
    const TextStyle(
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );
  static TextStyle get title => _font(
    'Fraunces',
    const TextStyle(
      fontSize: 20,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );
  static TextStyle get stat => _font(
    'Fraunces',
    const TextStyle(
      fontSize: 28,
      height: 1.1,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );

  static TextStyle get bodyLarge => _font(
    'Inter',
    const TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
    ),
  );
  static TextStyle get body => _font(
    'Inter',
    const TextStyle(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
    ),
  );
  static TextStyle get bodySmall => _font(
    'Inter',
    const TextStyle(
      fontSize: 13,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: AppColors.inkMid,
    ),
  );
  static TextStyle get label => _font(
    'Inter',
    const TextStyle(
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );
  static TextStyle get button => _font(
    'Inter',
    const TextStyle(fontSize: 15, height: 1.2, fontWeight: FontWeight.w600),
  );

  static TextStyle get eyebrow => _font(
    'IBM Plex Mono',
    const TextStyle(
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.2,
      color: AppColors.inkMid,
    ),
  );

  static TextTheme get textTheme => TextTheme(
    displaySmall: display,
    headlineSmall: headline,
    titleLarge: title,
    titleMedium: label.copyWith(fontSize: 16),
    titleSmall: label,
    bodyLarge: bodyLarge,
    bodyMedium: body,
    bodySmall: bodySmall,
    labelLarge: button,
    labelMedium: label.copyWith(fontSize: 12),
    labelSmall: eyebrow,
  );
}
