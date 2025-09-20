import 'package:flutter/material.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/utils/asset_generator.dart';
import 'package:poafix/core/utils/image_helper.dart';

class PopularServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const PopularServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Service image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: Container(
                width: 100,
                height: 100,
                color: AppColors.lightGrey,
                child: ImageHelper.loadNetworkImage(
                  imageUrl: service.image,
                  fit: BoxFit.cover,
                  placeholder: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: ServiceImagePlaceholder(
                    serviceName: service.name,
                    width: 100,
                    height: 100,
                    borderRadius: 0,
                  ),
                ),
              ),
            ),

            // Service details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.bookingCount}+ Bookings',
                          style: AppTextStyles.caption,
                        ),
                        const Spacer(),
                        Text(
                          service.priceMax != null
                              ? 'KES ${service.price.toStringAsFixed(0)} - ${service.priceMax!.toStringAsFixed(0)}${service.pricingType == 'hourly'
                                    ? "/hr"
                                    : service.pricingType == 'per_unit'
                                    ? "/unit"
                                    : ''}'
                              : 'KES ${service.price.toStringAsFixed(0)}${service.pricingType == 'hourly'
                                    ? "/hr"
                                    : service.pricingType == 'per_unit'
                                    ? "/unit"
                                    : ''}',
                          style: AppTextStyles.price,
                        ),
                        if (service.categoryName.isNotEmpty)
                          Text(
                            service.categoryName,
                            style: AppTextStyles.caption,
                          ),
                        if (service.subService.isNotEmpty)
                          Text(
                            service.subService,
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
