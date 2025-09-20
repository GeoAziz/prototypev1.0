import 'package:json_annotation/json_annotation.dart';
import 'provider_model.dart';

part 'comparison_model.g.dart';

@JsonSerializable()
class ComparisonResult {
  final List<ComparisonItem> items;
  final List<ComparisonItem> rankedItems;
  final Map<String, double> scores;
  final Map<String, List<String>> highlights;

  ComparisonResult({
    required this.items,
    this.rankedItems = const [],
    this.scores = const {},
    this.highlights = const {},
  });

  factory ComparisonResult.fromJson(Map<String, dynamic> json) =>
      _$ComparisonResultFromJson(json);

  Map<String, dynamic> toJson() => _$ComparisonResultToJson(this);
}

@JsonSerializable()
class ComparisonItem {
  final ProviderModel provider;
  final Map<String, dynamic> metrics;
  final List<String> highlights;

  double get rating => provider.rating;
  int get completedProjects => provider.completedProjects;
  double get responseRate => metrics['responseRate'] as double? ?? 0.0;
  double get bookingRate => metrics['bookingRate'] as double? ?? 0.0;
  int get totalReviews => metrics['totalReviews'] as int? ?? 0;
  double get averagePrice => metrics['averagePrice'] as double? ?? 0.0;
  Duration get averageResponseTime =>
      Duration(minutes: metrics['averageResponseTime'] as int? ?? 0);

  ComparisonItem({
    required this.provider,
    required this.metrics,
    required this.highlights,
  });

  factory ComparisonItem.fromJson(Map<String, dynamic> json) =>
      _$ComparisonItemFromJson(json);

  Map<String, dynamic> toJson() => _$ComparisonItemToJson(this);
}

class ComparisonMetric {
  final String name;
  final double weight;
  final double Function(dynamic) normalizeValue;

  const ComparisonMetric({
    required this.name,
    required this.weight,
    required this.normalizeValue,
  });

  static List<ComparisonMetric> getAllMetrics() {
    return [
      ComparisonMetric(
        name: 'rating',
        weight: 0.3,
        normalizeValue: (value) => (value as double) / 5.0,
      ),
      ComparisonMetric(
        name: 'responseRate',
        weight: 0.2,
        normalizeValue: (value) => (value as double) / 100.0,
      ),
      ComparisonMetric(
        name: 'bookingRate',
        weight: 0.2,
        normalizeValue: (value) => (value as double) / 100.0,
      ),
      ComparisonMetric(
        name: 'completedProjects',
        weight: 0.15,
        normalizeValue: (value) =>
            (value as int) > 100 ? 1.0 : (value as int) / 100.0,
      ),
      ComparisonMetric(
        name: 'averageResponseTime',
        weight: 0.15,
        normalizeValue: (value) =>
            1.0 - ((value as int) / 60.0).clamp(0.0, 1.0),
      ),
    ];
  }
}
