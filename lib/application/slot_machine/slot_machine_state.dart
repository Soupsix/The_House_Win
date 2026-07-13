import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/slot_machine_config_model.dart';
import '../../domain/models/slot_result_model.dart';

part 'slot_machine_state.freezed.dart';

@freezed
class SlotMachineState with _$SlotMachineState {
  const factory SlotMachineState({
    SlotMachineConfigModel? config,
    @Default(false) bool isSpinning,
    SlotResultModel? lastResult,
    @Default([]) List<SlotResultModel> history,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SlotMachineState;
}
