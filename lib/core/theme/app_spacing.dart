import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  static const double pageGutter = 20;
}

abstract final class AppRadius {
  static const double field = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static const BorderRadius cardBorder = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius fieldBorder = BorderRadius.all(
    Radius.circular(field),
  );
  static const BorderRadius pillBorder = BorderRadius.all(
    Radius.circular(pill),
  );
}

const double kMinTapTarget = 44;

const double kMaxContentWidth = 600;
