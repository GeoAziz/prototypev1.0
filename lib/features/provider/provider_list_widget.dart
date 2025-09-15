import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poafix/core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderListWidget extends StatelessWidget {
  final String categoryId;
  const ProviderListWidget({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    debugPrint(
      '[ProviderListWidget] Querying providers for categoryId: $categoryId',
    );
    return FutureBuilder<List<DocumentSnapshot>>(
      future: firebaseService.getProvidersByCategory(categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('[ProviderListWidget] Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final providers = snapshot.data ?? [];
        debugPrint('[ProviderListWidget] Providers found: ${providers.length}');
        for (final doc in providers) {
          final data = doc.data() as Map<String, dynamic>?;
          debugPrint(
            '[ProviderListWidget] Provider doc: ${doc.id}, data: $data',
          );
        }
        if (providers.isEmpty) {
          debugPrint(
            '[ProviderListWidget] No providers found for categoryId: $categoryId',
          );
          return const Center(child: Text('No providers found.'));
        }
        return ListView.builder(
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index].data() as Map<String, dynamic>?;
            if (provider == null) return const SizedBox.shrink();
            return ListTile(
              title: Text(provider['name'] ?? 'Unknown'),
              subtitle: Text('Rating: ${provider['rating'] ?? 'N/A'}'),
            );
          },
        );
      },
    );
  }
}
