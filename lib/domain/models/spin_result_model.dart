import 'package:freezed_annotation/freezed_annotation.dart';

part 'spin_result_model.freezed.dart';
part 'spin_result_model.g.dart';

@freezed
class SpinResultModel with _$SpinResultModel {
  const factory SpinResultModel({
    required String id,
    required String userId,
    required double betAmount,
    required String segmentId,      // segment nào trúng
    required double multiplier,
    required double payout,
    required DateTime createdAt,
    String? transactionId,
  }) = _SpinResultModel;

  factory SpinResultModel.fromJson(Map<String, dynamic> json) =>
      _$SpinResultModelFromJson(json);
}
