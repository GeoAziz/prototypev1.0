import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_model.dart';

class ImagePrefetchService {
  static final Set<String> _prefetchedImages = {};

  static Future<void> prefetchImages(List<ProviderModel> providers) async {
    for (final provider in providers) {
      if (provider.profileImage != null &&
          !_prefetchedImages.contains(provider.profileImage)) {
        try {
          await CachedNetworkImage.evictFromCache(provider.profileImage!);
          await precacheImage(
            CachedNetworkImageProvider(provider.profileImage!),
            NavigationService.navigatorKey.currentContext!,
          );
          _prefetchedImages.add(provider.profileImage!);
        } catch (e) {
          debugPrint('Failed to prefetch image: ${provider.profileImage} - $e');
        }
      }
    }
  }

  static void clearPrefetchCache() {
    _prefetchedImages.clear();
  }
}

// Navigation service to access BuildContext from anywhere
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

// Optimized image widget with loading and error states
class OptimizedProviderImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedProviderImage({
    super.key,
    this.imageUrl,
    this.radius = 30,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return CircleAvatar(
        radius: radius,
        child: errorWidget ?? const Icon(Icons.person),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            placeholder ?? const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            errorWidget ?? const Center(child: Icon(Icons.error)),
        // Use memory cache first
        useOldImageOnUrlChange: true,
        // Fade duration for smooth loading
        fadeInDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// Provider for the image prefetch service
final imagePrefetchProvider = Provider<ImagePrefetchService>((ref) {
  return ImagePrefetchService();
});
