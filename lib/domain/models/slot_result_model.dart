import 'package:freezed_annotation/freezed_annotation.dart';

part 'slot_result_model.freezed.dart';
part 'slot_result_model.g.dart';

@freezed
class SlotResultModel with _$SlotResultModel {
  const factory SlotResultModel({
    required String id,
    required String userId,
    required double betAmount,
    required List<String> reelSymbolIds, // e.g. ["cherry", "cherry", "lemon"]
    required double multiplier, // 0 if no win
    required double payout, // betAmount * multiplier
    required DateTime createdAt,
    String? transactionId,
  }) = _SlotResultModel;

  factory SlotResultModel.fromJson(Map<String, dynamic> json) =>
      _$SlotResultModelFromJson(json);
}
