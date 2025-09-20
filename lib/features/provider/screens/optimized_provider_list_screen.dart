import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/optimized_provider_list_provider.dart';
import '../models/provider_model.dart';
// import '../services/cache_service.dart';
import '../services/image_prefetch_service.dart';
import '../widgets/optimized_provider_list.dart';

class OptimizedProviderListScreen extends ConsumerStatefulWidget {
  const OptimizedProviderListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedProviderListScreen> createState() =>
      _OptimizedProviderListScreenState();
}

class _OptimizedProviderListScreenState
    extends ConsumerState<OptimizedProviderListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize with cached data
    ref.read(optimizedProviderListProvider.notifier).initializeWithCache();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerState = ref.watch(optimizedProviderListProvider);

    // Show loading state if no cached data available
    if (providerState.isLoading && !providerState.isCached) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Providers'),
        actions: [
          if (providerState.isCached)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.cloud_off),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(optimizedProviderListProvider.notifier).refreshData();
        },
        child: Column(
          children: [
            if (providerState.error != null)
              Material(
                color: Theme.of(context).colorScheme.error,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    providerState.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: OptimizedProviderList(
                providers: providerState.providers,
                scrollController: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                showLoadMore: true,
                onLoadMore: () {
                  ref
                      .read(optimizedProviderListProvider.notifier)
                      .prefetchNextBatch();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension methods for the provider list screen
extension ProviderListOptimizations on OptimizedProviderListScreen {
  // Method to prefetch images for visible and soon-to-be-visible items
  static void prefetchImagesForVisibleItems(
    List<ProviderModel> providers,
    int startIndex,
    int endIndex,
  ) {
    // Calculate the range of items to prefetch (current visible + next page)
    final itemCount = providers.length;
    final endPrefetchIndex = (endIndex + 20).clamp(0, itemCount);
    final prefetchList = providers.sublist(startIndex, endPrefetchIndex);

    // Trigger image prefetching in the background
    ImagePrefetchService.prefetchImages(prefetchList);
  }

  // Method to clear image cache when needed
  static void clearImageCache() {
    ImagePrefetchService.clearPrefetchCache();
  }
}
