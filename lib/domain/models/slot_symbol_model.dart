import 'package:freezed_annotation/freezed_annotation.dart';

part 'slot_symbol_model.freezed.dart';
part 'slot_symbol_model.g.dart';

@freezed
class SlotSymbolModel with _$SlotSymbolModel {
  const factory SlotSymbolModel({
    required String id,
    required String iconAsset,
    required int weight,
    // key: number of matching symbols (e.g. "2" or "3")
    // value: multiplier
    required Map<String, double> payoutTable,
  }) = _SlotSymbolModel;

  factory SlotSymbolModel.fromJson(Map<String, dynamic> json) =>
      _$SlotSymbolModelFromJson(json);
}
