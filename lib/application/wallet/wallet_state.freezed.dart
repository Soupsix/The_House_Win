// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WalletState {
  double get balance => throw _privateConstructorUsedError;
  double get lockedAmount => throw _privateConstructorUsedError;
  bool get isBroke => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  List<TransactionModel> get transactionHistory =>
      throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletStateCopyWith<WalletState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletStateCopyWith<$Res> {
  factory $WalletStateCopyWith(
          WalletState value, $Res Function(WalletState) then) =
      _$WalletStateCopyWithImpl<$Res, WalletState>;
  @useResult
  $Res call(
      {double balance,
      double lockedAmount,
      bool isBroke,
      bool isLoading,
      List<TransactionModel> transactionHistory,
      String? errorMessage});
}

/// @nodoc
class _$WalletStateCopyWithImpl<$Res, $Val extends WalletState>
    implements $WalletStateCopyWith<$Res> {
  _$WalletStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? lockedAmount = null,
    Object? isBroke = null,
    Object? isLoading = null,
    Object? transactionHistory = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      lockedAmount: null == lockedAmount
          ? _value.lockedAmount
          : lockedAmount // ignore: cast_nullable_to_non_nullable
              as double,
      isBroke: null == isBroke
          ? _value.isBroke
          : isBroke // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      transactionHistory: null == transactionHistory
          ? _value.transactionHistory
          : transactionHistory // ignore: cast_nullable_to_non_nullable
              as List<TransactionModel>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletStateImplCopyWith<$Res>
    implements $WalletStateCopyWith<$Res> {
  factory _$$WalletStateImplCopyWith(
          _$WalletStateImpl value, $Res Function(_$WalletStateImpl) then) =
      __$$WalletStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double balance,
      double lockedAmount,
      bool isBroke,
      bool isLoading,
      List<TransactionModel> transactionHistory,
      String? errorMessage});
}

/// @nodoc
class __$$WalletStateImplCopyWithImpl<$Res>
    extends _$WalletStateCopyWithImpl<$Res, _$WalletStateImpl>
    implements _$$WalletStateImplCopyWith<$Res> {
  __$$WalletStateImplCopyWithImpl(
      _$WalletStateImpl _value, $Res Function(_$WalletStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? lockedAmount = null,
    Object? isBroke = null,
    Object? isLoading = null,
    Object? transactionHistory = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$WalletStateImpl(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      lockedAmount: null == lockedAmount
          ? _value.lockedAmount
          : lockedAmount // ignore: cast_nullable_to_non_nullable
              as double,
      isBroke: null == isBroke
          ? _value.isBroke
          : isBroke // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      transactionHistory: null == transactionHistory
          ? _value._transactionHistory
          : transactionHistory // ignore: cast_nullable_to_non_nullable
              as List<TransactionModel>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$WalletStateImpl implements _WalletState {
  const _$WalletStateImpl(
      {this.balance = 0,
      this.lockedAmount = 0,
      this.isBroke = false,
      this.isLoading = false,
      final List<TransactionModel> transactionHistory = const [],
      this.errorMessage})
      : _transactionHistory = transactionHistory;

  @override
  @JsonKey()
  final double balance;
  @override
  @JsonKey()
  final double lockedAmount;
  @override
  @JsonKey()
  final bool isBroke;
  @override
  @JsonKey()
  final bool isLoading;
  final List<TransactionModel> _transactionHistory;
  @override
  @JsonKey()
  List<TransactionModel> get transactionHistory {
    if (_transactionHistory is EqualUnmodifiableListView)
      return _transactionHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactionHistory);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'WalletState(balance: $balance, lockedAmount: $lockedAmount, isBroke: $isBroke, isLoading: $isLoading, transactionHistory: $transactionHistory, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletStateImpl &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.lockedAmount, lockedAmount) ||
                other.lockedAmount == lockedAmount) &&
            (identical(other.isBroke, isBroke) || other.isBroke == isBroke) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality()
                .equals(other._transactionHistory, _transactionHistory) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      balance,
      lockedAmount,
      isBroke,
      isLoading,
      const DeepCollectionEquality().hash(_transactionHistory),
      errorMessage);

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletStateImplCopyWith<_$WalletStateImpl> get copyWith =>
      __$$WalletStateImplCopyWithImpl<_$WalletStateImpl>(this, _$identity);
}

abstract class _WalletState implements WalletState {
  const factory _WalletState(
      {final double balance,
      final double lockedAmount,
      final bool isBroke,
      final bool isLoading,
      final List<TransactionModel> transactionHistory,
      final String? errorMessage}) = _$WalletStateImpl;

  @override
  double get balance;
  @override
  double get lockedAmount;
  @override
  bool get isBroke;
  @override
  bool get isLoading;
  @override
  List<TransactionModel> get transactionHistory;
  @override
  String? get errorMessage;

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletStateImplCopyWith<_$WalletStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
