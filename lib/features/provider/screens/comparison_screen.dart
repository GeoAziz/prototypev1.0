import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_model.dart';
import '../providers/comparison_provider.dart';
import '../utils/comparison_share.dart';
import '../widgets/comparison_view.dart';

class ComparisonScreen extends ConsumerWidget {
  final List<ProviderModel> providers;
  final GlobalKey _screenshotKey = GlobalKey();

  ComparisonScreen({super.key, required this.providers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparison = ref.watch(comparisonStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Providers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: comparison == null
                ? null
                : () => ComparisonShare.shareComparison(
                    context,
                    _screenshotKey,
                    comparison,
                  ),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _screenshotKey,
        child: ComparisonView(providers: providers),
      ),
    );
  }
}
