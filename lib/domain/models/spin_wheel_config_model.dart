import 'package:freezed_annotation/freezed_annotation.dart';
import 'spin_segment_model.dart';

part 'spin_wheel_config_model.freezed.dart';
part 'spin_wheel_config_model.g.dart';

@freezed
class SpinWheelConfigModel with _$SpinWheelConfigModel {
  const factory SpinWheelConfigModel({
    required String id,
    required List<SpinSegmentModel> segments,
    required double minBet,
    required double maxBet,
    @Default(true) bool isActive,
  }) = _SpinWheelConfigModel;

  factory SpinWheelConfigModel.fromJson(Map<String, dynamic> json) =>
      _$SpinWheelConfigModelFromJson(json);
}
