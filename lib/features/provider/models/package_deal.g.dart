// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageDeal _$PackageDealFromJson(Map<String, dynamic> json) => PackageDeal(
  id: json['id'] as String,
  providerId: json['providerId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  serviceIds: (json['serviceIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  price: (json['price'] as num).toDouble(),
  discount: (json['discount'] as num).toDouble(),
  validUntil: DateTime.parse(json['validUntil'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PackageDealToJson(PackageDeal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'providerId': instance.providerId,
      'name': instance.name,
      'description': instance.description,
      'serviceIds': instance.serviceIds,
      'price': instance.price,
      'discount': instance.discount,
      'validUntil': instance.validUntil.toIso8601String(),
      'metadata': instance.metadata,
    };
