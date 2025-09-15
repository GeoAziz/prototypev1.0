import 'package:flutter/material.dart';
import 'dart:async';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/utils/asset_generator.dart';
import 'package:poafix/core/utils/image_helper.dart';

class ServiceImageCarousel extends StatefulWidget {
  final List<String> images;

  const ServiceImageCarousel({super.key, required this.images});

  @override
  State<ServiceImageCarousel> createState() => _ServiceImageCarouselState();
}

class _ServiceImageCarouselState extends State<ServiceImageCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentIndex < widget.images.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image carousel
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: AppColors.lightGrey),
              child: widget.images.isEmpty
                  ? ServiceImagePlaceholder(
                      serviceName: 'Service',
                      height: MediaQuery.of(context).size.height,
                    )
                  : ImageHelper.loadNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.cover,
                      placeholder: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: ServiceImagePlaceholder(
                        serviceName: 'Service',
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
            );
          },
        ),

        // Carousel indicators
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),

        // Navigation buttons
        if (widget.images.length > 1)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                GestureDetector(
                  onTap: () {
                    if (_currentIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),

                // Next button
                GestureDetector(
                  onTap: () {
                    if (_currentIndex < widget.images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
