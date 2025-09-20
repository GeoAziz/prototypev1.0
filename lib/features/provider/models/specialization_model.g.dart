// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecializationModel _$SpecializationModelFromJson(Map<String, dynamic> json) =>
    SpecializationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      category: json['category'] as String?,
      requirements: json['requirements'] as Map<String, dynamic>?,
      certifications: json['certifications'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SpecializationModelToJson(
  SpecializationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'skills': instance.skills,
  'category': instance.category,
  'requirements': instance.requirements,
  'certifications': instance.certifications,
};
