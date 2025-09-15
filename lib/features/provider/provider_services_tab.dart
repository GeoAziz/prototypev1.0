import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/widgets/app_button.dart';

class ProviderServicesTab extends StatelessWidget {
  final String providerId;
  const ProviderServicesTab({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('services')
          .where('providerId', isEqualTo: providerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final services = snapshot.data?.docs ?? [];
        if (services.isEmpty) {
          return const Center(
            child: Text('No services found for this provider.'),
          );
        }
        return ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service['name'] ?? '', style: AppTextStyles.headline3),
                    const SizedBox(height: 8),
                    Text(
                      service['description'] ?? '',
                      style: AppTextStyles.body1,
                    ),
                    const SizedBox(height: 8),
                    if (service['images'] != null &&
                        service['images'] is List &&
                        service['images'].isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.generate(
                            (service['images'] as List).length,
                            (imgIdx) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.network(
                                service['images'][imgIdx],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: \$${service['price']}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Book Now',
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/booking/${service['id']}');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
