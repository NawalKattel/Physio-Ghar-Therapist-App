import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/repository/app_data_provider.dart';
import 'package:physio_ghar/core/repository/app_repository.dart';
import 'package:physio_ghar/features/account/view_model/therapist_view_model.dart';
import 'package:physio_ghar/features/auth/model/account.dart';

enum RegisterError { emailTaken }

final authProvider = NotifierProvider<AuthNotifier, Account?>(AuthNotifier.new);

class AuthNotifier extends Notifier<Account?> {
  @override
  Account? build() => null;

  bool get isSignedIn => state != null;

  Future<bool> login({required String email, required String password}) async {
    final repository = await ref.read(repositoryProvider.future);
    try {
      final therapist = await repository.login(
        email: email,
        password: password,
      );
      state = Account(email: therapist.email, password: '');
      return true;
    } on RepositoryException catch (error) {
      if (error.code == 'INVALID_CREDENTIALS') return false;
      rethrow;
    }
  }

  Future<RegisterError?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final repository = await ref.read(repositoryProvider.future);
    try {
      final therapist = await repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      state = Account(email: therapist.email, password: '');
      if (!repository.requiresAuth) {
        ref.read(therapistProvider.notifier).apply(therapist);
      }
      return null;
    } on RepositoryException catch (error) {
      if (error.code == 'EMAIL_TAKEN') return RegisterError.emailTaken;
      rethrow;
    }
  }

  Future<void> logout() async {
    final repository = await ref.read(repositoryProvider.future);
    await repository.logout();
    state = null;
  }
}
