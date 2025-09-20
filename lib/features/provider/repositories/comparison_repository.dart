import 'dart:math';

import '../models/comparison_model.dart';
import '../models/provider_model.dart';

class ComparisonRepository {
  Future<ComparisonResult> compareProviders(
    List<ProviderModel> providers,
  ) async {
    if (providers.isEmpty) {
      return ComparisonResult(items: []);
    }

    final metrics = ComparisonMetric.getAllMetrics();
    final items = providers.map((provider) {
      // Calculate or fetch metrics for each provider
      final providerMetrics = _calculateMetrics(provider);
      final highlights = _generateHighlights(provider, providerMetrics);

      return ComparisonItem(
        provider: provider,
        metrics: providerMetrics,
        highlights: highlights,
      );
    }).toList();

    // Calculate overall scores
    final scores = <String, double>{};
    final highlights = <String, List<String>>{};

    for (final item in items) {
      double totalScore = 0;
      double totalWeight = 0;

      for (final metric in metrics) {
        final value = _getMetricValue(item, metric.name);
        final normalizedValue = metric.normalizeValue(value);
        totalScore += normalizedValue * metric.weight;
        totalWeight += metric.weight;
      }

      final finalScore = totalScore / totalWeight;
      scores[item.provider.id] = finalScore;
      highlights[item.provider.id] = item.highlights;
    }

    // Create ranked list
    final rankedItems = List<ComparisonItem>.from(
      items,
    )..sort((a, b) => scores[b.provider.id]!.compareTo(scores[a.provider.id]!));

    return ComparisonResult(
      items: items,
      rankedItems: rankedItems,
      scores: scores,
      highlights: highlights,
    );
  }

  Map<String, dynamic> _calculateMetrics(ProviderModel provider) {
    // In a real implementation, these would be calculated from actual data
    // For now, we'll generate some sample metrics
    final random = Random();

    return {
      'responseRate': 70.0 + random.nextDouble() * 30,
      'bookingRate': 60.0 + random.nextDouble() * 40,
      'totalReviews': provider.reviews?.length ?? random.nextInt(50),
      'averagePrice': 1000.0 + random.nextDouble() * 4000,
      'averageResponseTime': 5 + random.nextInt(55), // minutes
    };
  }

  List<String> _generateHighlights(
    ProviderModel provider,
    Map<String, dynamic> metrics,
  ) {
    final highlights = <String>[];

    // Rating highlights
    if (provider.rating >= 4.5) {
      highlights.add('Top-rated provider');
    } else if (provider.rating >= 4.0) {
      highlights.add('Highly rated provider');
    }

    // Response rate highlights
    final responseRate = metrics['responseRate'] as double;
    if (responseRate >= 90) {
      highlights.add('Excellent response rate');
    } else if (responseRate >= 80) {
      highlights.add('Good response rate');
    }

    // Booking rate highlights
    final bookingRate = metrics['bookingRate'] as double;
    if (bookingRate >= 90) {
      highlights.add('Very reliable');
    } else if (bookingRate >= 80) {
      highlights.add('Reliable provider');
    }

    // Experience highlights
    if (provider.completedProjects >= 100) {
      highlights.add('Very experienced');
    } else if (provider.completedProjects >= 50) {
      highlights.add('Experienced provider');
    }

    // Response time highlights
    final responseTime = metrics['averageResponseTime'] as int;
    if (responseTime <= 15) {
      highlights.add('Quick to respond');
    }

    return highlights;
  }

  dynamic _getMetricValue(ComparisonItem item, String metricName) {
    switch (metricName) {
      case 'rating':
        return item.rating;
      case 'completedProjects':
        return item.completedProjects;
      case 'responseRate':
        return item.responseRate;
      case 'bookingRate':
        return item.bookingRate;
      case 'totalReviews':
        return item.totalReviews;
      case 'averagePrice':
        return item.averagePrice;
      case 'averageResponseTime':
        return item.averageResponseTime.inMinutes;
      default:
        return 0;
    }
  }
}
