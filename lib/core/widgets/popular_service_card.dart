import 'package:flutter/material.dart';
import '../models/service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: Image.network(
                service.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.body1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.rating.toStringAsFixed(1),
                          style: AppTextStyles.body2,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${service.reviewCount})',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
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
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (service.subService.isNotEmpty)
                          Text(
                            service.subService,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
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
