import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage.instance);

final apiClientProvider = Provider((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthRepository _repository;

  bool get isAuthenticated => state.asData?.value != null;
  UserModel? get user => state.asData?.value;

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.me();
      state = AsyncValue.data(user);
    } catch (e) {
      // No valid token or network error — treat as unauthenticated.
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final auth = await _repository.login(email: email, password: password);
      state = AsyncValue.data(auth.user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Register with { name, email, password, teamId }.
  /// Role is hardcoded to 'coach' server-side — not sent from the client.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int teamId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final auth = await _repository.register(
        name: name,
        email: email,
        password: password,
        teamId: teamId,
      );
      state = AsyncValue.data(auth.user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore errors on logout — always clear local state.
    }
    state = const AsyncValue.data(null);
  }

  void setError(Exception exception) {
    state = AsyncValue.error(exception, StackTrace.current);
  }
}
