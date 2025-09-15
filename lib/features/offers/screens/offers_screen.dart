import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';
import 'package:poafix/core/services/offer_service.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  final TextEditingController _promoController = TextEditingController();
  final OfferService _offerService = OfferService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _redeemPromo(String code) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Promo code "$code" redeemed!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Special Offers')),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _offerService.streamOffers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: const CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading offers',
                  style: AppTextStyles.body2.copyWith(color: AppColors.error),
                ),
              );
            }
            final offers = snapshot.data ?? [];
            if (offers.isEmpty) {
              return Center(
                child: Text(
                  'No offers available',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }
            final categories = offers
                .map((o) => o['category'] as String)
                .toSet()
                .toList();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Promo code input
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            decoration: const InputDecoration(
                              labelText: 'Enter promo code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_promoController.text.isNotEmpty) {
                              _redeemPromo(_promoController.text);
                            }
                          },
                          child: const Text('Redeem'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Offer categories
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Wrap(
                    key: ValueKey(categories.length),
                    spacing: 8,
                    children: [
                      ...categories.map(
                        (cat) => Chip(
                          label: Text(cat),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Offers list
                ...offers.map(
                  (offer) => AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Icon(Icons.local_offer, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              offer['title'] ?? '',
                              style: AppTextStyles.headline3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              offer['discount'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer['valid'] ?? '',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Terms: ${offer['terms'] ?? ''}',
                                style: AppTextStyles.body2,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Applicable Services: ${(offer['services'] as List<dynamic>?)?.join(", ") ?? ''}',
                                style: AppTextStyles.body2,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Promo Code: ',
                                    style: AppTextStyles.body2.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SelectableText(
                                    offer['code'] ?? '',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18),
                                    tooltip: 'Copy code',
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: offer['code'] ?? '',
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Copied promo code!'),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share, size: 18),
                                    tooltip: 'Share offer',
                                    onPressed: () {
                                      final code = offer['code'] ?? '';
                                      final title = offer['title'] ?? '';
                                      final text =
                                          'Check out this offer: $title\nPromo Code: $code';
                                      Clipboard.setData(
                                        ClipboardData(text: text),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Offer details copied!',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
