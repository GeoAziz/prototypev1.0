// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderModel _$ProviderModelFromJson(Map<String, dynamic> json) =>
    ProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedProjects: (json['completedProjects'] as num?)?.toInt() ?? 0,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      serviceRates: json['serviceRates'] as Map<String, dynamic>?,
      availability: json['availability'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProviderModelToJson(ProviderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profileImage': instance.profileImage,
      'rating': instance.rating,
      'completedProjects': instance.completedProjects,
      'reviews': instance.reviews,
      'serviceRates': instance.serviceRates,
      'availability': instance.availability,
    };
