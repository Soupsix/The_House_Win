import 'package:freezed_annotation/freezed_annotation.dart';

part 'spin_segment_model.freezed.dart';
part 'spin_segment_model.g.dart';

@freezed
class SpinSegmentModel with _$SpinSegmentModel {
  const factory SpinSegmentModel({
    required String id,
    required double multiplier,   // 0 = mất hết, 1 = hòa, 2.5 = x2.5...
    required double probability,  // tổng tất cả segment = 1.0
    required String label,        // "x0", "x2", "JACKPOT x10"
    required String colorHex,
  }) = _SpinSegmentModel;

  factory SpinSegmentModel.fromJson(Map<String, dynamic> json) =>
      _$SpinSegmentModelFromJson(json);
}
