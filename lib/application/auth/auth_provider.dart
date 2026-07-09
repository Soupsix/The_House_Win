import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';
import 'auth_notifier.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider((ref) => AuthRepositoryImpl());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider))..initialize(),
);

// Convenience providers for other modules to use
final currentUserProvider = Provider((ref) => ref.watch(authProvider).user);
final isAdminProvider = Provider((ref) => ref.watch(authProvider).isAdmin);
final authStatusProvider = Provider((ref) => ref.watch(authProvider).status);
