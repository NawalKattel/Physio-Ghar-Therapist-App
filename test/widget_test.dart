import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:physio_ghar/core/theme/app_text_styles.dart';
import 'package:physio_ghar/features/bookings/model/session.dart';
import 'package:physio_ghar/features/bookings/view_model/sessions_view_model.dart';
import 'package:physio_ghar/main.dart';

import 'helpers.dart';

/// Pumps the whole app at the 390×844 target and returns its container so
/// tests can check state as well as the screen.
Future<ProviderContainer> pumpApp(WidgetTester tester) async {
  AppTextStyles.useGoogleFonts = false; // no network fonts in tests
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(overrides: testOverrides());
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const PhysioGharApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Welcome → Log in with the demo account → Home.
Future<void> logInWithDemoAccount(WidgetTester tester) async {
  await tester.tap(find.text('Get started'));
  await tester.pumpAndSettle();
  expect(find.text('Welcome back'), findsOneWidget);

  await tester.tap(find.text('Use'));
  await tester.tap(find.text('Log in'));
  await tester.pumpAndSettle();
}

Finder navTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  testWidgets('login validates, rejects wrong credentials, then signs in', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'aarati.joshi@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass1');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Incorrect email or password'), findsOneWidget);

    await tester.tap(find.text('Use'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text("Today's schedule"), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('accepting a booking request moves it to Upcoming', (tester) async {
    final container = await pumpApp(tester);
    await logInWithDemoAccount(tester);

    await tester.tap(navTab('Bookings'));
    await tester.pumpAndSettle();
    expect(find.text('Anjali Thapa'), findsOneWidget); // soonest request

    await tester.tap(find.text('Accept').first);
    await tester.pumpAndSettle();

    expect(find.text('Anjali Thapa accepted · moved to Upcoming'), findsOneWidget);
    expect(find.text('Anjali Thapa'), findsNothing);
    final accepted = container.read(sessionsProvider).firstWhere((s) => s.id == 's8');
    expect(accepted.status, SessionStatus.upcoming);
  });

  testWidgets('submitting a complaint validates and shows the success screen', (tester) async {
    await pumpApp(tester);
    await logInWithDemoAccount(tester);

    await tester.tap(navTab('Account'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Report an issue'));
    await tester.tap(find.text('Report an issue'));
    await tester.pumpAndSettle();
    expect(find.text('Previous complaints'), findsOneWidget);

    await tester.tap(find.text('New complaint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit complaint'));
    await tester.pumpAndSettle();
    expect(find.text('Please choose a category'), findsOneWidget);
    expect(find.text('Enter a subject'), findsOneWidget);
    expect(find.text('Enter a description'), findsOneWidget);

    await tester.tap(find.text('Choose a category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical Issue').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'App froze on schedule');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'The schedule screen stopped responding when I added a slot.',
    );
    await tester.tap(find.text('Submit complaint'));
    await tester.pumpAndSettle();

    expect(find.text('Complaint submitted'), findsOneWidget);
    expect(find.text('PG-C-0002'), findsOneWidget);

    await tester.tap(find.text('Back to complaints'));
    await tester.pumpAndSettle();
    expect(find.text('App froze on schedule'), findsOneWidget);
  });
}
