import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase/spin_wheel_service.dart';
import 'spin_wheel_state.dart';
import 'spin_wheel_notifier.dart';

final spinWheelRepositoryProvider = Provider((ref) => SpinWheelService());

final spinWheelProvider = StateNotifierProvider<SpinWheelNotifier, SpinWheelState>((ref) {
  return SpinWheelNotifier(ref.read(spinWheelRepositoryProvider));
});
