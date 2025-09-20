// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComparisonResult _$ComparisonResultFromJson(Map<String, dynamic> json) =>
    ComparisonResult(
      items: (json['items'] as List<dynamic>)
          .map((e) => ComparisonItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      rankedItems:
          (json['rankedItems'] as List<dynamic>?)
              ?.map((e) => ComparisonItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      scores:
          (json['scores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      highlights:
          (json['highlights'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          const {},
    );

Map<String, dynamic> _$ComparisonResultToJson(ComparisonResult instance) =>
    <String, dynamic>{
      'items': instance.items,
      'rankedItems': instance.rankedItems,
      'scores': instance.scores,
      'highlights': instance.highlights,
    };

ComparisonItem _$ComparisonItemFromJson(Map<String, dynamic> json) =>
    ComparisonItem(
      provider: ProviderModel.fromJson(
        json['provider'] as Map<String, dynamic>,
      ),
      metrics: json['metrics'] as Map<String, dynamic>,
      highlights: (json['highlights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ComparisonItemToJson(ComparisonItem instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'metrics': instance.metrics,
      'highlights': instance.highlights,
    };
