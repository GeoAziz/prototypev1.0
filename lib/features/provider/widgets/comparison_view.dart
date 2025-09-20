import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comparison_model.dart';
import '../models/provider_model.dart';
import '../providers/comparison_provider.dart';

class ComparisonView extends ConsumerWidget {
  final List<ProviderModel> providers;

  const ComparisonView({super.key, required this.providers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(comparisonStateProvider);

    return comparisonAsync.when(
      data: (comparison) {
        if (comparison == null) {
          // Initialize comparison
          ref
              .read(comparisonStateProvider.notifier)
              .compareProviders(providers);
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              // Header with overall scores
              _buildHeader(context, comparison),

              // Side-by-side comparison
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildComparisonTable(context, comparison),
              ),

              // Highlights section
              _buildHighlights(context, comparison),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildHeader(BuildContext context, ComparisonResult comparison) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Service Comparison',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: comparison.rankedItems.map((item) {
              final score = comparison.scores[item.provider.id] ?? 0.0;
              return Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: item.provider.profileImage != null
                              ? NetworkImage(item.provider.profileImage!)
                              : null,
                          radius: 30,
                          child: item.provider.profileImage == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.provider.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Score: ${(score * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(
    BuildContext context,
    ComparisonResult comparison,
  ) {
    final metrics = ComparisonMetric.getAllMetrics();

    return Table(
      border: TableBorder.all(
        color: Theme.of(context).dividerColor,
        width: 0.5,
      ),
      columnWidths: {
        0: const FlexColumnWidth(2),
        for (var i = 1; i <= comparison.items.length; i++)
          i: const FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
          ),
          children: [
            const TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Metric'),
              ),
            ),
            ...comparison.items.map(
              (item) => TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item.provider.name),
                ),
              ),
            ),
          ],
        ),
        ...metrics.map(
          (metric) => TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(metric.name),
                ),
              ),
              ...comparison.items.map((item) {
                final value = _getMetricValue(item, metric.name);
                final formattedValue = value is double
                    ? value.toStringAsFixed(2)
                    : value.toString();
                return TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(formattedValue),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlights(BuildContext context, ComparisonResult comparison) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Provider Highlights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...comparison.rankedItems.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.provider.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (comparison.highlights[item.provider.id] ?? [])
                          .map(
                            (highlight) => Chip(
                              label: Text(highlight),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        return item.averageResponseTime;
      default:
        return 0;
    }
  }
}
