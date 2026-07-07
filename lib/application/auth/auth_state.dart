import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/user_model.dart';
import '../../domain/enums/auth_status.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.unknown) AuthStatus status,
    UserModel? user,
    @Default(false) bool isLoading,
    @Default(false) bool isAdmin,
    String? errorMessage,
  }) = _AuthState;
}
