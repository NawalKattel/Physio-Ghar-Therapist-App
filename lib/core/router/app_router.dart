import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:physio_ghar/features/account/view/account_screen.dart';
import 'package:physio_ghar/features/account/view/edit_profile_screen.dart';
import 'package:physio_ghar/features/account/view/profile_screen.dart';
import 'package:physio_ghar/features/auth/view/login_screen.dart';
import 'package:physio_ghar/features/auth/view/register_screen.dart';
import 'package:physio_ghar/features/auth/view_model/auth_view_model.dart';
import 'package:physio_ghar/features/bookings/view/bookings_screen.dart';
import 'package:physio_ghar/features/bookings/view/session_detail_screen.dart';
import 'package:physio_ghar/features/complaints/view/complaint_form_screen.dart';
import 'package:physio_ghar/features/complaints/view/complaint_success_screen.dart';
import 'package:physio_ghar/features/complaints/view/complaints_screen.dart';
import 'package:physio_ghar/features/dashboard/view/dashboard_screen.dart';
import 'package:physio_ghar/features/patients/view/note_editor_screen.dart';
import 'package:physio_ghar/features/patients/view/patient_detail_screen.dart';
import 'package:physio_ghar/features/patients/view/patients_screen.dart';
import 'package:physio_ghar/features/schedule/view/schedule_screen.dart';
import 'package:physio_ghar/features/shell/view/app_shell.dart';
import 'package:physio_ghar/features/welcome/view/welcome_screen.dart';

abstract final class AppRoutes {
  static const welcome = '/';
  static const home = '/home';
  static const schedule = '/schedule';
  static const bookings = '/bookings';
  static const patients = '/patients';
  static const account = '/account';
  static const profile = '$account/profile';
  static const editProfile = '$account/profile/edit';
  static const complaints = '$account/complaints';
  static const newComplaint = '$complaints/new';

  static String complaintSubmitted(String id) => '$complaints/submitted/$id';
  static const login = '/login';
  static const register = '/register';

  static const _public = {welcome, login, register};

  static bool isPublic(String location) => _public.contains(location);

  static String sessionDetail(String id) => '/session/$id';

  static String patientDetail(String patientId) => '$patients/$patientId';

  static String newNote(String patientId) => '$patients/$patientId/notes/new';

  static String editNote(String patientId, String noteId) =>
      '$patients/$patientId/notes/$noteId';
}

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.welcome,

    redirect: (context, state) {
      final isSignedIn = ref.read(authProvider) != null;
      final isPublic = AppRoutes.isPublic(state.matchedLocation);
      if (!isSignedIn && !isPublic) return AppRoutes.login;
      if (isSignedIn && isPublic) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) =>
            welcomeScreen(onGetStarted: () => context.go(AppRoutes.login)),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => appShell(navigationShell),
        branches: [
          _branch(AppRoutes.home, 'home', (_) => const DashboardScreen()),
          _branch(
            AppRoutes.schedule,
            'schedule',
            (_) => const ScheduleScreen(),
          ),
          _branch(
            AppRoutes.bookings,
            'bookings',
            (_) => const BookingsScreen(),
          ),
          _branch(
            AppRoutes.patients,
            'patients',
            (_) => const PatientsScreen(),
            routes: [
              GoRoute(
                path: ':patientId',
                name: 'patient',
                builder: (context, state) => PatientDetailScreen(
                  patientId: state.pathParameters['patientId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'notes/new',
                    name: 'newNote',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => NoteEditorScreen(
                      patientId: state.pathParameters['patientId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'notes/:noteId',
                    name: 'editNote',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => NoteEditorScreen(
                      patientId: state.pathParameters['patientId']!,
                      noteId: state.pathParameters['noteId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          _branch(
            AppRoutes.account,
            'account',
            (_) => const AccountScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'editProfile',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'complaints',
                name: 'complaints',
                builder: (context, state) => const ComplaintsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'newComplaint',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ComplaintFormScreen(),
                  ),
                  GoRoute(
                    path: 'submitted/:complaintId',
                    name: 'complaintSubmitted',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ComplaintSuccessScreen(
                      complaintId: state.pathParameters['complaintId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/session/:id',
        name: 'session',
        builder: (context, state) =>
            SessionDetailScreen(sessionId: state.pathParameters['id']!),
      ),
    ],
  );

  ref.listen(authProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(
  String path,
  String name,
  Widget Function(GoRouterState) builder, {
  List<RouteBase> routes = const [],
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        name: name,
        builder: (context, state) => builder(state),
        routes: routes,
      ),
    ],
  );
}
