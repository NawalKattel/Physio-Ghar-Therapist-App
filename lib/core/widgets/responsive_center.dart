import 'package:flutter/widgets.dart';

import 'package:physio_ghar/core/theme/app_spacing.dart';

Widget responsiveCenter({
  required Widget child,
  double maxWidth = kMaxContentWidth,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
    horizontal: AppSpacing.pageGutter,
  ),
}) {
  return Align(
    alignment: Alignment.topCenter,

    heightFactor: 1,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}
