import 'package:json_annotation/json_annotation.dart';

part 'provider_model.g.dart';

@JsonSerializable()
class ProviderModel {
  final String id;
  final String name;
  final String? profileImage;
  final double rating;
  final int completedProjects;
  final List<String>? reviews;
  final Map<String, dynamic>? serviceRates;
  final Map<String, dynamic>? availability;

  const ProviderModel({
    required this.id,
    required this.name,
    this.profileImage,
    this.rating = 0.0,
    this.completedProjects = 0,
    this.reviews,
    this.serviceRates,
    this.availability,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderModelToJson(this);
}
