import 'package:flutter/material.dart';
import 'provider_list_widget.dart';

class ProviderScreen extends StatelessWidget {
  final String categoryId;
  const ProviderScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Providers')),
      body: ProviderListWidget(categoryId: categoryId),
    );
  }
}
