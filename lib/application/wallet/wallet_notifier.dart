import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletNotifier extends StateNotifier<AsyncValue<void>> {
  WalletNotifier() : super(const AsyncValue.data(null));
}
