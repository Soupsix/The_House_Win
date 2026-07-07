import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> register(String name, String email, String password, String phoneNumber);
  Future<UserModel> signIn(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updateProfile({required String displayName, required String phoneNumber});
  Stream<UserModel?> get userStream;
}
