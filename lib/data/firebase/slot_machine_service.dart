import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/slot_symbol_model.dart';
import '../../domain/models/slot_machine_config_model.dart';
import '../../domain/models/slot_result_model.dart';
import '../../domain/repositories/i_slot_machine_repository.dart';
import '../../domain/enums/game_type.dart';

class SlotMachineService implements ISlotMachineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<SlotMachineConfigModel?> getActiveConfig() async {
    final snap = await _firestore
        .collection('slot_machine_configs')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      // Tự động seed dữ liệu mẫu nếu chưa có
      try {
        final defaultConfig = SlotMachineConfigModel(
          id: 'default_config',
          isActive: true,
          reelCount: 3,
          fixedBet: 10000,
          symbols: [
            const SlotSymbolModel(
              id: 'cherry',
              iconAsset: 'assets/images/slot_cherry.png',
              weight: 40,
              payoutTable: {'2': 0.5, '3': 3.5},
            ),
            const SlotSymbolModel(
              id: 'lemon',
              iconAsset: 'assets/images/slot_lemon.png',
              weight: 30,
              payoutTable: {'2': 1.0, '3': 5.0},
            ),
            const SlotSymbolModel(
              id: 'orange',
              iconAsset: 'assets/images/slot_orange.png',
              weight: 20,
              payoutTable: {'2': 1.5, '3': 10.0},
            ),
            const SlotSymbolModel(
              id: 'bell',
              iconAsset: 'assets/images/slot_bell.png',
              weight: 7,
              payoutTable: {'3': 50.0},
            ),
            const SlotSymbolModel(
              id: 'star',
              iconAsset: 'assets/images/slot_star.png',
              weight: 2,
              payoutTable: {'3': 500.0},
            ),
            const SlotSymbolModel(
              id: 'jackpot',
              iconAsset: 'assets/images/slot_jackpot.png',
              weight: 1,
              payoutTable: {'3': 5000.0},
            ),
          ],
        );
        final json = defaultConfig.toJson();
        json['symbols'] = defaultConfig.symbols.map((e) => e.toJson()).toList();
        await _firestore.collection('slot_machine_configs').doc('default_config').set(json);
        return defaultConfig;
      } catch (e) {
        // Fallback for non-admin rules
        return SlotMachineConfigModel(
          id: 'default_config',
          isActive: true,
          reelCount: 3,
          fixedBet: 10000,
          symbols: [
            const SlotSymbolModel(
              id: 'cherry',
              iconAsset: 'assets/images/slot_cherry.png',
              weight: 40,
              payoutTable: {'2': 0.5, '3': 3.5},
            ),
            const SlotSymbolModel(
              id: 'lemon',
              iconAsset: 'assets/images/slot_lemon.png',
              weight: 30,
              payoutTable: {'2': 1.0, '3': 5.0},
            ),
            const SlotSymbolModel(
              id: 'orange',
              iconAsset: 'assets/images/slot_orange.png',
              weight: 20,
              payoutTable: {'2': 1.5, '3': 10.0},
            ),
            const SlotSymbolModel(
              id: 'bell',
              iconAsset: 'assets/images/slot_bell.png',
              weight: 7,
              payoutTable: {'3': 50.0},
            ),
            const SlotSymbolModel(
              id: 'star',
              iconAsset: 'assets/images/slot_star.png',
              weight: 2,
              payoutTable: {'3': 500.0},
            ),
            const SlotSymbolModel(
              id: 'jackpot',
              iconAsset: 'assets/images/slot_jackpot.png',
              weight: 1,
              payoutTable: {'3': 5000.0},
            ),
          ],
        );
      }
    }
    return SlotMachineConfigModel.fromJson(
        {'id': snap.docs.first.id, ...snap.docs.first.data()});
  }

  @override
  Future<SlotResultModel> pull({
    required String userId,
    required double betAmount,
  }) async {
    final activeConfig = await getActiveConfig();
    if (activeConfig == null) {
      throw Exception('Không tìm thấy cấu hình Slot Machine.');
    }

    final allowedBets = [1000.0, 2000.0, 5000.0, 10000.0, 20000.0, 50000.0];
    if (!allowedBets.contains(betAmount)) {
      throw Exception('Mức cược không hợp lệ.');
    }

    return await _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('wallets').doc(userId);
      final walletDoc = await transaction.get(walletRef);

      if (!walletDoc.exists) {
        throw Exception("Ví ảo không tồn tại.");
      }

      final data = walletDoc.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      final lockedAmount = (data['lockedAmount'] as num?)?.toDouble() ?? 0.0;
      final availableBalance = balance - lockedAmount;

      if (availableBalance < betAmount) {
        throw Exception("Số dư khả dụng không đủ để cược.");
      }

      // 1. Random từng cuộn độc lập
      final List<String> resultSymbols = [];
      for (int i = 0; i < activeConfig.reelCount; i++) {
        resultSymbols.add(_pickWeightedSymbol(activeConfig.symbols));
      }

      // 2. Tính số lượng lặp lại nhiều nhất
      final counts = <String, int>{};
      for (var s in resultSymbols) {
        counts[s] = (counts[s] ?? 0) + 1;
      }

      String maxSymbolId = resultSymbols.first;
      int maxCount = 0;
      counts.forEach((key, value) {
        if (value > maxCount) {
          maxCount = value;
          maxSymbolId = key;
        }
      });

      // 3. Tra bảng payout của symbol lặp nhiều nhất
      final winningSymbol = activeConfig.symbols.firstWhere((s) => s.id == maxSymbolId);
      final multiplier = winningSymbol.payoutTable[maxCount.toString()] ?? 0.0;
      final payout = betAmount * multiplier;

      // 4. Update wallet
      final newBalance = balance - betAmount + payout;
      transaction.update(walletRef, {'balance': newBalance});

      // 5. Ghi nhận giao dịch
      final betTxRef = _firestore.collection('transactions').doc();
      transaction.set(betTxRef, {
        'userId': userId,
        'type': 'BET_PLACED',
        'amount': betAmount,
        'referenceId': betTxRef.id,
        'gameType': GameType.slotMachine.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      String? payoutTxId;
      if (payout > 0) {
        final payoutTxRef = _firestore.collection('transactions').doc();
        payoutTxId = payoutTxRef.id;
        transaction.set(payoutTxRef, {
          'userId': userId,
          'type': 'BET_PAYOUT',
          'amount': payout,
          'referenceId': payoutTxRef.id,
          'gameType': GameType.slotMachine.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 6. Ghi kết quả
      final resultRef = _firestore.collection('slot_results').doc();
      final resultModel = SlotResultModel(
        id: resultRef.id,
        userId: userId,
        betAmount: betAmount,
        reelSymbolIds: resultSymbols,
        multiplier: multiplier,
        payout: payout,
        createdAt: DateTime.now(), // Local time for model
        transactionId: payoutTxId ?? betTxRef.id,
      );

      transaction.set(resultRef, {
        ...resultModel.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return resultModel;
    });
  }

  @override
  Future<List<SlotResultModel>> getUserSlotHistory(
    String userId, {
    int limit = 50,
  }) async {
    final snap = await _firestore
        .collection('slot_results')
        .where('userId', isEqualTo: userId)
        .get();

    var results = snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      return SlotResultModel.fromJson(data);
    }).toList();

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results;
  }

  String _pickWeightedSymbol(List<SlotSymbolModel> symbols) {
    final totalWeight = symbols.fold(0, (sum, s) => sum + s.weight);
    final roll = Random.secure().nextInt(totalWeight);
    int cumulative = 0;
    for (final symbol in symbols) {
      cumulative += symbol.weight;
      if (roll < cumulative) return symbol.id;
    }
    return symbols.last.id;
  }
}
