import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/spin_wheel_config_model.dart';
import '../../domain/models/spin_result_model.dart';

part 'spin_wheel_state.freezed.dart';

@freezed
class SpinWheelState with _$SpinWheelState {
  const factory SpinWheelState({
    SpinWheelConfigModel? config,
    @Default(10000.0) double betAmount,
    @Default(false) bool isSpinning,
    SpinResultModel? lastResult,
    @Default([]) List<SpinResultModel> history,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SpinWheelState;
}
