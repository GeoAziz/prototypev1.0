import 'package:flutter/material.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/utils/asset_generator.dart';
import 'package:poafix/core/utils/image_helper.dart';

class FeaturedServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const FeaturedServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 140,
                width: double.infinity,
                color: AppColors.lightGrey,
                child: ImageHelper.loadNetworkImage(
                  imageUrl: service.image,
                  fit: BoxFit.cover,
                  placeholder: const Center(child: CircularProgressIndicator()),
                  errorWidget: ServiceImagePlaceholder(
                    serviceName: service.name,
                    height: 140,
                    borderRadius: 0,
                  ),
                ),
              ),
            ),

            // Service details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${service.rating}', style: AppTextStyles.body2),
                      const SizedBox(width: 4),
                      Text(
                        '(${service.reviewCount})',
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      Text('\$${service.price}', style: AppTextStyles.price),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
