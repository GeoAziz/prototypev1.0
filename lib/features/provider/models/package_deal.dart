import 'package:json_annotation/json_annotation.dart';

part 'package_deal.g.dart';

@JsonSerializable()
class PackageDeal {
  final String id;
  final String providerId;
  final String name;
  final String description;
  final List<String> serviceIds;
  final double price;
  final double discount;
  final DateTime validUntil;
  final Map<String, dynamic>? metadata;

  PackageDeal({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.serviceIds,
    required this.price,
    required this.discount,
    required this.validUntil,
    this.metadata,
  });

  factory PackageDeal.fromJson(Map<String, dynamic> json) =>
      _$PackageDealFromJson(json);

  Map<String, dynamic> toJson() => _$PackageDealToJson(this);
}
