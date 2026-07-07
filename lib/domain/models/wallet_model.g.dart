// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletModelImpl _$$WalletModelImplFromJson(Map<String, dynamic> json) =>
    _$WalletModelImpl(
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toDouble(),
      lockedAmount: (json['lockedAmount'] as num).toDouble(),
      isBroke: json['isBroke'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$WalletModelImplToJson(_$WalletModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'balance': instance.balance,
      'lockedAmount': instance.lockedAmount,
      'isBroke': instance.isBroke,
      'createdAt': instance.createdAt.toIso8601String(),
    };
