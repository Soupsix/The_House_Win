import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_state.dart';
import 'admin_notifier.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../wallet/wallet_provider.dart'; // import firestoreServiceProvider

final adminRepositoryProvider = Provider((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return AdminRepositoryImpl(firestoreService);
});

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return AdminNotifier(repository)..initialize();
});
