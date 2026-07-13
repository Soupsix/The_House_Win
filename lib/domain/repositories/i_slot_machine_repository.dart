import '../models/slot_machine_config_model.dart';
import '../models/slot_result_model.dart';

abstract class ISlotMachineRepository {
  Future<SlotMachineConfigModel?> getActiveConfig();
  
  Future<SlotResultModel> pull({
    required String userId,
    required double betAmount,
  });

  Future<List<SlotResultModel>> getUserSlotHistory(
    String userId, {
    int limit = 50,
  });
}
