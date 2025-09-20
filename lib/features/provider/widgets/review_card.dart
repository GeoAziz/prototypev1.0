import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/review_model.dart';
import '../providers/review_provider.dart';
import '../services/image_prefetch_service.dart';

class ReviewCard extends ConsumerWidget {
  final Review review;
  final bool showProviderResponse;
  final bool isProvider;
  final String currentUserId;

  const ReviewCard({
    Key? key,
    required this.review,
    this.showProviderResponse = true,
    this.isProvider = false,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: OptimizedProviderImage(
              imageUrl: review.userAvatar,
              radius: 20,
            ),
            title: Row(
              children: [
                Text(review.userName),
                if (review.isVerifiedBooking)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.verified_user,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RatingStars(rating: review.rating),
                    const SizedBox(width: 8),
                    Text(timeago.format(review.createdAt)),
                  ],
                ),
              ],
            ),
            trailing: _buildMenuButton(context, ref),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(review.comment),
          ),
          if (review.media != null && review.media!.isNotEmpty)
            ReviewMediaGallery(media: review.media!),
          _buildHelpfulButton(context, ref),
          if (showProviderResponse && review.hasResponse)
            ProviderResponse(response: review.response!),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'flag':
            _showFlagDialog(context, ref);
            break;
          case 'delete':
            _showDeleteDialog(context, ref);
            break;
          case 'respond':
            _showResponseDialog(context, ref);
            break;
        }
      },
      itemBuilder: (context) => [
        if (!isProvider)
          const PopupMenuItem(
            value: 'flag',
            child: ListTile(
              leading: Icon(Icons.flag),
              title: Text('Flag Review'),
            ),
          ),
        if (isProvider || review.userId == currentUserId)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Review'),
            ),
          ),
        if (isProvider && !review.hasResponse)
          const PopupMenuItem(
            value: 'respond',
            child: ListTile(leading: Icon(Icons.reply), title: Text('Respond')),
          ),
      ],
    );
  }

  Widget _buildHelpfulButton(BuildContext context, WidgetRef ref) {
    final isHelpful = review.isHelpfulToUser(currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: isHelpful ? Theme.of(context).primaryColor : null,
            ),
            onPressed: () {
              ref
                  .read(reviewProvider.notifier)
                  .toggleHelpful(review.id, currentUserId);
            },
          ),
          Text('${review.helpfulCount} found this helpful'),
        ],
      ),
    );
  }

  Future<void> _showFlagDialog(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flag Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you flagging this review?'),
            const SizedBox(height: 16),
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('Inappropriate Content'),
                  onTap: () => Navigator.pop(context, 'inappropriate'),
                ),
                ListTile(
                  title: const Text('Spam'),
                  onTap: () => Navigator.pop(context, 'spam'),
                ),
                ListTile(
                  title: const Text('Fake Review'),
                  onTap: () => Navigator.pop(context, 'fake'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (reason != null) {
      await ref.read(reviewProvider.notifier).flagReview(review.id, reason);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(reviewProvider.notifier).deleteReview(review.id);
    }
  }

  Future<void> _showResponseDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    final response = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Review'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write your response...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Respond'),
          ),
        ],
      ),
    );

    if (response != null && response.isNotEmpty) {
      await ref.read(reviewProvider.notifier).addResponse(review.id, {
        'text': response,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 16,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        return Icon(
          value <= rating
              ? Icons.star
              : value - 0.5 <= rating
              ? Icons.star_half
              : Icons.star_border,
          size: size,
          color: color ?? Colors.amber,
        );
      }),
    );
  }
}

class ReviewMediaGallery extends StatelessWidget {
  final Map<String, dynamic> media;

  const ReviewMediaGallery({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final urls = (media['urls'] as List?)?.cast<String>();
    if (urls == null || urls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: urls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _showFullScreenImage(context, urls[index]),
              child: OptimizedProviderImage(imageUrl: urls[index], radius: 8),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(child: InteractiveViewer(child: Image.network(url))),
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderResponse extends StatelessWidget {
  final Map<String, dynamic> response;

  const ProviderResponse({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.business, size: 16),
              SizedBox(width: 8),
              Text(
                'Provider Response',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(response['text'] as String),
          const SizedBox(height: 4),
          Text(
            timeago.format(DateTime.parse(response['timestamp'] as String)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
