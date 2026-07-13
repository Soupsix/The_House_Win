import 'package:freezed_annotation/freezed_annotation.dart';
import 'slot_symbol_model.dart';

part 'slot_machine_config_model.freezed.dart';
part 'slot_machine_config_model.g.dart';

@freezed
class SlotMachineConfigModel with _$SlotMachineConfigModel {
  const factory SlotMachineConfigModel({
    required String id,
    required List<SlotSymbolModel> symbols,
    required int reelCount, // default 3
    required double fixedBet, // or minBet/maxBet if we allow flexible betting
    @Default(true) bool isActive,
  }) = _SlotMachineConfigModel;

  factory SlotMachineConfigModel.fromJson(Map<String, dynamic> json) =>
      _$SlotMachineConfigModelFromJson(json);
}
