import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';
import '../../domain/enums/auth_status.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;
  StreamSubscription? _userSubscription;

  AuthNotifier(this._authRepository) : super(const AuthState());

  void initialize() {
    _userSubscription?.cancel();
    _userSubscription = _authRepository.userStream.listen((user) {
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isAdmin: user.isAdmin,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          isAdmin: false,
          errorMessage: null,
        );
      }
    }, onError: (error) {
      state = state.copyWith(
        errorMessage: _mapFirebaseError(error),
      );
    });
  }

  Future<void> register(String name, String email, String password, String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authRepository.register(name, email, password, phoneNumber);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isAdmin: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _mapFirebaseError(e),
        isLoading: false,
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authRepository.signIn(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isAdmin: user.isAdmin,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _mapFirebaseError(e),
        isLoading: false,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        errorMessage: _mapFirebaseError(e),
        isLoading: false,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.resetPassword(email);
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Email đã được gửi. Kiểm tra hộp thư của bạn",
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _mapFirebaseError(e),
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile({required String displayName, required String phoneNumber}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.updateProfile(displayName: displayName, phoneNumber: phoneNumber);
      final currentUser = state.user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          displayName: displayName,
          phoneNumber: phoneNumber,
        );
        state = state.copyWith(user: updatedUser, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: _mapFirebaseError(e),
        isLoading: false,
      );
      rethrow;
    }
  }

  String _mapFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Email không tồn tại';
        case 'wrong-password':
          return 'Mật khẩu không đúng';
        case 'email-already-in-use':
          return 'Email đã được sử dụng';
        case 'weak-password':
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng';
        default:
          return error.message ?? 'Đã xảy ra lỗi. Vui lòng thử lại';
      }
    }
    final errStr = error.toString();
    if (errStr.contains('user-not-found')) {
      return 'Email không tồn tại';
    } else if (errStr.contains('wrong-password')) {
      return 'Mật khẩu không đúng';
    } else if (errStr.contains('email-already-in-use')) {
      return 'Email đã được sử dụng';
    } else if (errStr.contains('weak-password')) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    } else if (errStr.contains('invalid-email')) {
      return 'Email không hợp lệ';
    } else if (errStr.contains('network-request-failed')) {
      return 'Lỗi kết nối mạng';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại';
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
