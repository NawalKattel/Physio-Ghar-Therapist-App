import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/repository/app_repository.dart';
import 'package:physio_ghar/core/repository/app_snapshot.dart';
import 'package:physio_ghar/core/repository/local_store.dart';
import 'package:physio_ghar/core/repository/mock_app_repository.dart';
import 'package:physio_ghar/core/repository/mock_repository.dart';

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final localStoreProvider = Provider<LocalStore>((ref) => PrefsLocalStore());

final mockRepositoryProvider = Provider<MockRepository>(
  (ref) => MockRepository(clock: ref.watch(clockProvider)),
);

final repositoryProvider = FutureProvider<AppRepository>(
  (ref) async => MockAppRepository(
    source: ref.watch(mockRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final appDataProvider = FutureProvider<AppData>((ref) async {
  final repository = await ref.watch(repositoryProvider.future);
  final bundled = await repository.loadAll();
  final saved = await AppSnapshot.load(
    ref.watch(localStoreProvider),
    accounts: bundled.accounts,
  );
  return saved ?? bundled;
});
