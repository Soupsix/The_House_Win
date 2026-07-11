import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_repository_impl.dart';
import '../auth/auth_provider.dart';
import '../wallet/wallet_provider.dart';
import 'admin_notifier.dart';
import 'admin_state.dart';

final adminRepositoryProvider = Provider<AdminRepositoryImpl>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);

  return AdminRepositoryImpl(firestoreService);
});

final adminProvider =
StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);

  final notifier = AdminNotifier(repository);

  notifier.initialize(
    adminId: currentUser?.uid,
  );

  return notifier;
});