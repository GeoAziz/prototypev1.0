import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_model.dart';
// import '../providers/provider_list_provider.dart'; // Removed because file does not exist

class OptimizedProviderList extends ConsumerStatefulWidget {
  final List<ProviderModel> providers;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final bool showLoadMore;
  final VoidCallback? onLoadMore;

  const OptimizedProviderList({
    Key? key,
    required this.providers,
    this.scrollController,
    this.padding,
    this.showLoadMore = false,
    this.onLoadMore,
  }) : super(key: key);

  @override
  ConsumerState<OptimizedProviderList> createState() =>
      _OptimizedProviderListState();
}

class _OptimizedProviderListState extends ConsumerState<OptimizedProviderList> {
  static const _loadMoreThreshold = 200.0;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.showLoadMore && widget.scrollController != null) {
      widget.scrollController!.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (widget.showLoadMore && widget.scrollController != null) {
      widget.scrollController!.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.showLoadMore || _isLoadingMore || widget.onLoadMore == null) {
      return;
    }

    final maxScroll = widget.scrollController!.position.maxScrollExtent;
    final currentScroll = widget.scrollController!.position.pixels;
    if (maxScroll - currentScroll <= _loadMoreThreshold) {
      _isLoadingMore = true;
      widget.onLoadMore!();
      _isLoadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: widget.padding,
      // Enable caching of items that are off-screen
      cacheExtent: MediaQuery.of(context).size.height,
      // Add keep alive hints to prevent rebuilding off-screen items
      addAutomaticKeepAlives: true,
      // Avoid rebuilding items when the list size changes
      addRepaintBoundaries: true,
      itemCount: widget.providers.length + (widget.showLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.providers.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return KeepAliveProviderCard(
          key: ValueKey(widget.providers[index].id),
          provider: widget.providers[index],
        );
      },
    );
  }
}

class KeepAliveProviderCard extends ConsumerStatefulWidget {
  final ProviderModel provider;

  const KeepAliveProviderCard({Key? key, required this.provider})
    : super(key: key);

  @override
  ConsumerState<KeepAliveProviderCard> createState() =>
      _KeepAliveProviderCardState();
}

class _KeepAliveProviderCardState extends ConsumerState<KeepAliveProviderCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Navigate to provider details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Provider avatar with cached network image
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.provider.profileImage != null
                        ? NetworkImage(widget.provider.profileImage!)
                        : null,
                    child: widget.provider.profileImage == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        // Specializations not available in ProviderModel
                        // Text(
                        //   widget.provider.specializations.join(', '),
                        //   style: Theme.of(context).textTheme.bodyMedium,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Provider info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Years of experience not available in ProviderModel
                      // Text(
                      //   'Experience: ${widget.provider.yearsOfExperience} years',
                      //   style: Theme.of(context).textTheme.bodyMedium,
                      // ),
                      Text(
                        'Projects: ${widget.provider.completedProjects}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            widget.provider.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      Text(
                        '${widget.provider.reviews?.length ?? 0} reviews',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
