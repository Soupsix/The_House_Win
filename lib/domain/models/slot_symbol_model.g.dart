// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_symbol_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotSymbolModelImpl _$$SlotSymbolModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SlotSymbolModelImpl(
      id: json['id'] as String,
      iconAsset: json['iconAsset'] as String,
      weight: (json['weight'] as num).toInt(),
      payoutTable: (json['payoutTable'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$$SlotSymbolModelImplToJson(
        _$SlotSymbolModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iconAsset': instance.iconAsset,
      'weight': instance.weight,
      'payoutTable': instance.payoutTable,
    };
