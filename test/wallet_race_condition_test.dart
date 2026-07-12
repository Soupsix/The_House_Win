import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:betwise/data/firebase/firestore_service.dart';
import 'package:betwise/domain/enums/game_type.dart';

void main() {
  group('Wallet Race Condition Test', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService firestoreService;
    const String uid = 'test_uid_123';

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: fakeFirestore);

      // Khởi tạo ví 1.000.000 VNĐ
      await fakeFirestore.collection('wallets').doc(uid).set({
        'balance': 1000000.0,
        'lockedAmount': 0.0,
        'isBroke': false,
        'createdAt': DateTime.now(),
      });
    });

    test('Concurrent deduct requests should not overwrite each other', () async {
      // Giả lập 3 game trừ tiền cùng lúc (mỗi game 200,000)
      final futures = <Future<void>>[
        firestoreService.processGameTransaction(
          uid: uid,
          amount: 200000,
          type: 'BET_LOCKED',
          gameType: GameType.diceOverUnder,
          referenceId: 'bet1',
        ),
        firestoreService.processGameTransaction(
          uid: uid,
          amount: 200000,
          type: 'BET_LOCKED',
          gameType: GameType.spinWheel,
          referenceId: 'bet2',
        ),
        firestoreService.processGameTransaction(
          uid: uid,
          amount: 200000,
          type: 'BET_LOCKED',
          gameType: GameType.slotMachine,
          referenceId: 'bet3',
        ),
      ];

      await Future.wait(futures);

      // Đọc lại dữ liệu ví
      final doc = await fakeFirestore.collection('wallets').doc(uid).get();
      final data = doc.data()!;

      expect(data['balance'], 1000000.0);
      expect(data['lockedAmount'], 600000.0); // Đã khóa 600k chính xác
      
      final transactions = await fakeFirestore.collection('transactions').get();
      expect(transactions.docs.length, 3); // 3 giao dịch được lưu
    });
    
    test('Concurrent settle requests (win) should not overwrite each other', () async {
      // Khóa trước 600k cho 3 game (mỗi game 200k)
      await fakeFirestore.collection('wallets').doc(uid).update({
        'lockedAmount': 600000.0,
      });

      // Giả lập 3 game trả thưởng cùng lúc (đều thắng, nhận lại vốn 200k + lãi 100k = 300k)
      final futures = <Future<void>>[
        firestoreService.processGameTransaction(
          uid: uid,
          amount: 200000, // Tiền đã khóa
          payout: 300000, // Tiền thắng trả về
          type: 'BET_WIN',
          gameType: GameType.diceOverUnder,
          referenceId: 'bet1',
        ),
        firestoreService.processGameTransaction(
          uid: uid,
          amount: 200000,
          payout: 300000,
          type: 'BET_WIN',
          gameType: GameType.spinWheel,
          referenceId: 'bet2',
        ),
        firestoreService.processGameTransaction(
          uid: uid,
          amount: 200000,
          payout: 300000,
          type: 'BET_WIN',
          gameType: GameType.slotMachine,
          referenceId: 'bet3',
        ),
      ];

      await Future.wait(futures);

      // Đọc lại dữ liệu ví
      final doc = await fakeFirestore.collection('wallets').doc(uid).get();
      final data = doc.data()!;

      // Ban đầu 1M, mỗi lần cộng thêm payout (300k) = 1M + 900k = 1.9M
      expect(data['balance'], 1900000.0); 
      // Locked amount về 0 (600k trừ dần 3 lần 200k)
      expect(data['lockedAmount'], 0.0);
    });
  });
}
