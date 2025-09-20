import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/package_deal_model.dart';
import '../providers/package_deal_provider.dart';

class PackageDealWidget extends ConsumerWidget {
  final String providerId;
  const PackageDealWidget({super.key, required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(packageDealProvider(providerId));
    if (deals.packages.isEmpty) {
      return const Text('No package deals available.');
    }
    return ListView.builder(
      itemCount: deals.packages.length,
      itemBuilder: (context, index) {
        final deal = deals.packages[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(deal.name),
            subtitle: Text(deal.description),
            trailing: Text('KES ${deal.price.toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }
}
