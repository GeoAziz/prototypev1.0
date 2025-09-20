import 'package:json_annotation/json_annotation.dart';

part 'specialization_model.g.dart';

@JsonSerializable()
class SpecializationModel {
  final String id;
  final String name;
  final String? description;
  final List<String>? skills;
  final String? category;
  final Map<String, dynamic>? requirements;
  final Map<String, dynamic>? certifications;

  const SpecializationModel({
    required this.id,
    required this.name,
    this.description,
    this.skills,
    this.category,
    this.requirements,
    this.certifications,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) =>
      _$SpecializationModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpecializationModelToJson(this);
}
