import 'package:flutter/material.dart';
import '../../../core/models/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProviderDetailsSheet extends StatefulWidget {
  final Provider provider;
  final VoidCallback onClose;
  final AnimationController controller;

  const ProviderDetailsSheet({
    Key? key,
    required this.provider,
    required this.onClose,
    required this.controller,
  }) : super(key: key);

  @override
  State<ProviderDetailsSheet> createState() => _ProviderDetailsSheetState();
}

class _ProviderDetailsSheetState extends State<ProviderDetailsSheet> {
  late Animation<double> _heightFactor;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _heightFactor = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeOut),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          heightFactor: _heightFactor.value,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              widget.controller.value -= details.primaryDelta! / 200;
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 500) {
                // Swipe down
                widget.onClose();
              } else if (widget.controller.value < 0.5) {
                widget.onClose();
              } else {
                widget.controller.forward();
              }
            },
            child: Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Card(
                  margin: const EdgeInsets.all(16.0),
                  elevation: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Provider details
                      ListTile(
                        leading: Hero(
                          tag: 'provider_${widget.provider.id}',
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                widget.provider.profileImageUrl != null
                                ? NetworkImage(widget.provider.profileImageUrl!)
                                : null,
                            child: widget.provider.profileImageUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        ),
                        title: Text(
                          widget.provider.name,
                          style: AppTextStyles.headline3,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                        ),
                      ),
                      // Provider info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.provider.businessDescription,
                              style: AppTextStyles.body2,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.provider.rating}',
                                  style: AppTextStyles.body1,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${widget.provider.totalRatings} reviews)',
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Action buttons
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
                                // TODO: Navigate to booking screen
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
                ),
              ),
            ),
          ),
        );
      },
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
