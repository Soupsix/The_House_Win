import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    await createWalletDocument(user.uid);
  }

  Future<void> updateUserProfile(String uid, String displayName, String phoneNumber) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    });
  }

  Future<void> createWalletDocument(String uid) async {
    await _firestore.collection('wallets').doc(uid).set({
      'balance': 1000000,
      'lockedAmount': 0,
      'isBroke': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUserDocument(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;
    return data['isAdmin'] as bool? ?? false;
  }
}
