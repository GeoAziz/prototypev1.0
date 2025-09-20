import 'package:flutter/material.dart';
import '../../../core/models/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProviderMapCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback onClose;

  const ProviderMapCard({
    Key? key,
    required this.provider,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: provider.profileImageUrl != null
                      ? NetworkImage(provider.profileImageUrl!)
                      : null,
                  child: provider.profileImageUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(provider.name, style: AppTextStyles.headline3),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.businessDescription,
                      style: AppTextStyles.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.rating} (${provider.totalRatings} reviews)',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.message,
                  label: 'Message',
                  onPressed: () {
                    // TODO: Implement messaging
                  },
                ),
                _ActionButton(
                  icon: Icons.calendar_today,
                  label: 'Book',
                  onPressed: () {
                    // TODO: Implement booking
                  },
                ),
                _ActionButton(
                  icon: Icons.info_outline,
                  label: 'Details',
                  onPressed: () {
                    // TODO: Navigate to provider details
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.primary),
      label: Text(label, style: TextStyle(color: AppColors.primary)),
    );
  }
}
