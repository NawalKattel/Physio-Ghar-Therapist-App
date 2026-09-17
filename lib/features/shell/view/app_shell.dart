import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/core/localization/app_language.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_spacing.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';

abstract final class AppTab {
  static const home = 0;
  static const schedule = 1;
  static const bookings = 2;
  static const patients = 3;
  static const account = 4;
}

Widget appShell(StatefulNavigationShell navigationShell) {
  return Scaffold(
    body: navigationShell,
    bottomNavigationBar: Consumer(
      builder: (context, ref, _) {
        final requestCount = ref.watch(appDataProvider).hasValue
            ? ref.watch(pendingRequestCountProvider)
            : 0;

        final strings = ref.watch(stringsProvider);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: AppColors.mist, width: 1.5),
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.lg),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.lg),
            ),
            child: NavigationBar(
              elevation: 8,
              shadowColor: AppColors.ink,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.pinePale,
              height: 68,
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => AppTextStyles.label.copyWith(
                  fontSize: 12,
                  color: states.contains(WidgetState.selected)
                      ? AppColors.pine
                      : AppColors.inkMid,
                ),
              ),
              destinations: [
                _destination(
                  Icons.home_outlined,
                  Icons.home_rounded,
                  strings.navHome,
                ),
                _destination(
                  Icons.calendar_month_outlined,
                  Icons.calendar_month_rounded,
                  strings.navSchedule,
                ),
                _destination(
                  Icons.event_note_outlined,
                  Icons.event_note_rounded,
                  strings.navBookings,
                  badgeCount: requestCount,
                ),
                _destination(
                  Icons.people_alt_outlined,
                  Icons.people_alt_rounded,
                  strings.navPatients,
                ),
                _destination(
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  strings.navAccount,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

NavigationDestination _destination(
  IconData icon,
  IconData selectedIcon,
  String label, {
  int badgeCount = 0,
}) {
  Widget withBadge(IconData data, Color color) => Badge(
    isLabelVisible: badgeCount > 0,
    label: Text('$badgeCount'),
    backgroundColor: AppColors.amber,
    textColor: AppColors.ink,
    child: Icon(data, color: color),
  );

  return NavigationDestination(
    icon: withBadge(icon, AppColors.inkMid),
    selectedIcon: withBadge(selectedIcon, AppColors.pine),
    label: label,
    tooltip: badgeCount > 0 ? '$label, $badgeCount new requests' : label,
  );
}
