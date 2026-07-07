// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      isAdmin: json['isAdmin'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'isAdmin': instance.isAdmin,
      'createdAt': instance.createdAt.toIso8601String(),
      'phoneNumber': instance.phoneNumber,
    };
