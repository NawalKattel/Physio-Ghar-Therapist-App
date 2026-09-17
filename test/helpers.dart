import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/core/repository/local_store.dart';
import 'package:physio_ghar/core/repository/mock_app_repository.dart';
import 'package:physio_ghar/core/repository/mock_repository.dart';

/// Fixed "now" for every test: Wednesday 16 Sep 2026, 9:00 AM. The mock
/// data is relative to today, so this pins every date.
final testNow = DateTime(2026, 9, 16, 9);

/// The mock API payload, read from disk once.
final _mockJson = File('lib/core/repository/physio_ghar.json').readAsStringSync();

/// Serves the mock JSON from memory, so tests don't depend on real asset
/// I/O or on the asset cache shared between tests.
class _MemoryAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(utf8.encode(_mockJson));
}

/// Overrides that make the app deterministic: fixed clock, no load delay,
/// in-memory data.
List<Override> testOverrides({LocalStore? store}) => [
  clockProvider.overrideWithValue(() => testNow),
  localStoreProvider.overrideWithValue(store ?? MemoryLocalStore()),
  // Tests always run against the bundled data, never the live API.
  mockRepositoryProvider.overrideWithValue(
    MockRepository(clock: () => testNow, latency: Duration.zero, bundle: _MemoryAssetBundle()),
  ),
  repositoryProvider.overrideWith(
    (ref) => MockAppRepository(
      source: ref.watch(mockRepositoryProvider),
      clock: ref.watch(clockProvider),
    ),
  ),
];

/// A container with the mock data already loaded.
Future<ProviderContainer> loadedContainer({LocalStore? store}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(overrides: testOverrides(store: store));
  addTearDown(container.dispose);
  await container.read(appDataProvider.future);
  return container;
}

/// [testNow]'s date plus [days], at [hour]:[minute].
DateTime dayAt(int days, int hour, [int minute = 0]) =>
    DateTime(testNow.year, testNow.month, testNow.day + days, hour, minute);
