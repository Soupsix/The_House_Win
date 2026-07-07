import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/models/user_model.dart';
import '../firebase/auth_firebase_service.dart';
import '../firebase/firestore_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthFirebaseService _authFirebaseService = AuthFirebaseService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Future<UserModel> register(String name, String email, String password, String phoneNumber) async {
    final userCredential = await _authFirebaseService.registerWithEmail(email, password);
    final user = userCredential.user;
    if (user == null) {
      throw Exception("User registration failed");
    }

    await user.updateDisplayName(name);

    final userModel = UserModel(
      uid: user.uid,
      email: email,
      displayName: name,
      isAdmin: false,
      createdAt: DateTime.now(),
      phoneNumber: phoneNumber,
    );

    await _firestoreService.createUserDocument(userModel);

    return userModel;
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    final userCredential = await _authFirebaseService.signInWithEmail(email, password);
    final user = userCredential.user;
    if (user == null) {
      throw Exception("User sign in failed");
    }

    final userModel = await _firestoreService.getUserDocument(user.uid);
    if (userModel == null) {
      throw Exception("User document not found in Firestore");
    }

    return userModel;
  }

  @override
  Future<void> signOut() async {
    await _authFirebaseService.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _authFirebaseService.sendPasswordResetEmail(email);
  }

  @override
  Future<void> updateProfile({required String displayName, required String phoneNumber}) async {
    final user = _authFirebaseService.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    await user.updateDisplayName(displayName);
    await _firestoreService.updateUserProfile(user.uid, displayName, phoneNumber);
  }

  @override
  Stream<UserModel?> get userStream {
    return _authFirebaseService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      return await _firestoreService.getUserDocument(user.uid);
    });
  }
}
