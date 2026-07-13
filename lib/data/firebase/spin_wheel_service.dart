import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/spin_segment_model.dart';
import '../../domain/models/spin_wheel_config_model.dart';
import '../../domain/models/spin_result_model.dart';
import '../../domain/repositories/i_spin_wheel_repository.dart';
import '../../domain/enums/game_type.dart';

class SpinWheelService implements ISpinWheelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<SpinWheelConfigModel?> getActiveConfig() async {
    final snap = await _firestore
        .collection('spin_wheel_configs')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      // Tự động seed dữ liệu mẫu nếu chưa có
      try {
        final defaultConfig = SpinWheelConfigModel(
          id: 'default_config',
          isActive: true,
          minBet: 10000,
          maxBet: 500000,
          segments: [
            SpinSegmentModel(id: 's1', label: 'x0.5', multiplier: 0.5, probability: 0.40, colorHex: '#FF5252'),
            SpinSegmentModel(id: 's2', label: 'x1.2', multiplier: 1.2, probability: 0.35, colorHex: '#4CAF50'),
            SpinSegmentModel(id: 's3', label: 'x2', multiplier: 2.0, probability: 0.15, colorHex: '#2196F3'),
            SpinSegmentModel(id: 's4', label: 'x5', multiplier: 5.0, probability: 0.08, colorHex: '#9C27B0'),
            SpinSegmentModel(id: 's5', label: 'x10', multiplier: 10.0, probability: 0.015, colorHex: '#FF9800'),
            SpinSegmentModel(id: 's6', label: 'x50', multiplier: 50.0, probability: 0.005, colorHex: '#FFEB3B'),
          ],
        );
        final json = defaultConfig.toJson();
        json['segments'] = defaultConfig.segments.map((e) => e.toJson()).toList();
        await _firestore.collection('spin_wheel_configs').doc('default_config').set(json);
        return defaultConfig;
      } catch (e) {
        print("Không thể lưu cấu hình vòng quay lên Firebase (thiếu quyền Admin), đang sử dụng cấu hình local: $e");
        // Vẫn trả về defaultConfig để app có thể chạy được (dùng bộ nhớ tạm)
        final fallbackConfig = SpinWheelConfigModel(
          id: 'default_config',
          isActive: true,
          minBet: 10000,
          maxBet: 500000,
          segments: [
            SpinSegmentModel(id: 's1', label: 'x0.5', multiplier: 0.5, probability: 0.40, colorHex: '#FF5252'),
            SpinSegmentModel(id: 's2', label: 'x1.2', multiplier: 1.2, probability: 0.35, colorHex: '#4CAF50'),
            SpinSegmentModel(id: 's3', label: 'x2', multiplier: 2.0, probability: 0.15, colorHex: '#2196F3'),
            SpinSegmentModel(id: 's4', label: 'x5', multiplier: 5.0, probability: 0.08, colorHex: '#9C27B0'),
            SpinSegmentModel(id: 's5', label: 'x10', multiplier: 10.0, probability: 0.015, colorHex: '#FF9800'),
            SpinSegmentModel(id: 's6', label: 'x50', multiplier: 50.0, probability: 0.005, colorHex: '#FFEB3B'),
          ],
        );
        return fallbackConfig;
      }
    }
    return SpinWheelConfigModel.fromJson(
        {'id': snap.docs.first.id, ...snap.docs.first.data()});
  }

  @override
  Future<SpinResultModel> spin({
    required String userId,
    required double betAmount,
  }) async {
    final activeConfig = await getActiveConfig();
    if (activeConfig == null) {
      throw Exception('Không tìm thấy cấu hình vòng quay hợp lệ.');
    }

    if (betAmount < activeConfig.minBet || betAmount > activeConfig.maxBet) {
      throw Exception(
          'Số tiền cược phải từ ${activeConfig.minBet} đến ${activeConfig.maxBet}');
    }

    // Thực hiện toàn bộ logic trong 1 Transaction để đảm bảo tính toàn vẹn (Atomicity)
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
        throw Exception("Số dư khả dụng không đủ để thực hiện quay.");
      }

      // 1. Random segment (Client-side nhưng nằm trong transaction)
      final segment = _getRandomSegment(activeConfig.segments);

      // 2. Tính payout
      final payout = betAmount * segment.multiplier;

      // 3. Tính balance mới ngay lập tức (instant bet)
      final newBalance = balance - betAmount + payout;

      // Cập nhật ví
      transaction.update(walletRef, {
        'balance': newBalance,
      });

      // 4. Lưu Transaction History cho Bet (Trừ tiền cược)
      final betTxRef = _firestore.collection('transactions').doc();
      transaction.set(betTxRef, {
        'userId': userId,
        'type': 'BET_PLACED', // Ghi nhận cược instant
        'amount': betAmount,
        'referenceId': betTxRef.id,
        'gameType': GameType.spinWheel.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5. Lưu Transaction History cho Payout (Nếu có thưởng)
      String? payoutTxId;
      if (payout > 0) {
        final payoutTxRef = _firestore.collection('transactions').doc();
        payoutTxId = payoutTxRef.id;
        transaction.set(payoutTxRef, {
          'userId': userId,
          'type': 'BET_PAYOUT', // Ghi nhận trả thưởng instant
          'amount': payout,
          'referenceId': payoutTxRef.id,
          'gameType': GameType.spinWheel.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 6. Lưu SpinResult
      final resultRef = _firestore.collection('spin_results').doc();
      final spinResult = SpinResultModel(
        id: resultRef.id,
        userId: userId,
        betAmount: betAmount,
        segmentId: segment.id,
        multiplier: segment.multiplier,
        payout: payout,
        createdAt: DateTime.now(), // ServerTimestamp khó dùng khi return model, nên dùng tạm DateTime.now() cho model, lưu serverTimestamp vào DB
        transactionId: payoutTxId ?? betTxRef.id,
      );

      transaction.set(resultRef, {
        ...spinResult.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return spinResult;
    });
  }

  @override
  Future<List<SpinResultModel>> getUserSpinHistory(
    String userId, {
    int limit = 50,
  }) async {
    // Không dùng orderBy('createdAt') trên query để tránh lỗi thiếu Composite Index trên Firebase
    final snap = await _firestore
        .collection('spin_results')
        .where('userId', isEqualTo: userId)
        .get();

    var results = snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      // Convert Timestamp to iso string
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      return SpinResultModel.fromJson(data);
    }).toList();

    // Sort local (descending)
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Take limit
    if (results.length > limit) {
      results = results.sublist(0, limit);
    }

    return results;
  }

  SpinSegmentModel _getRandomSegment(List<SpinSegmentModel> segments) {
    // Dùng Random.secure() để an toàn hơn
    final random = Random.secure();
    final double randVal = random.nextDouble(); // 0.0 -> 1.0

    double cumulative = 0.0;
    for (final segment in segments) {
      cumulative += segment.probability;
      if (randVal <= cumulative) {
        return segment;
      }
    }
    // Fallback nếu có sai số nhỏ
    return segments.last;
  }
}
