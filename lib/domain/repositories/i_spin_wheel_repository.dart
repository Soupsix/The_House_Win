import '../models/spin_wheel_config_model.dart';
import '../models/spin_result_model.dart';

abstract class ISpinWheelRepository {
  Future<SpinWheelConfigModel?> getActiveConfig();
  
  Future<SpinResultModel> spin({
    required String userId,
    required double betAmount,
  });
  
  Future<List<SpinResultModel>> getUserSpinHistory(
    String userId, {
    int limit = 50,
  });
}
