import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poafix/core/theme/app_colors.dart';

/// A helper class to handle image loading across different platforms
/// and provide consistent error handling and loading placeholders
class ImageHelper {
  /// Loads a network image with proper caching and error handling
  static Widget loadNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    // Create default placeholder and error widgets if not provided
    final defaultPlaceholder = Container(
      width: width,
      height: height,
      color: AppColors.lightGrey,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );

    final defaultErrorWidget = Container(
      width: width,
      height: height,
      color: AppColors.lightGrey,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey,
      ),
    );

    // Use Image.network directly for web to avoid plugin issues
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? defaultPlaceholder;
          },
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? defaultErrorWidget;
          },
        ),
      );
    }

    // Use CachedNetworkImage for mobile platforms for better performance
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? defaultPlaceholder,
        errorWidget: (context, url, error) => errorWidget ?? defaultErrorWidget,
      ),
    );
  }
}
