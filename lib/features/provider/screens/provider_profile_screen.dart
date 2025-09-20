import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/specialization_provider.dart';
import '../widgets/specialization_selector.dart';

class ProviderProfileScreen extends ConsumerWidget {
  final String providerId;

  const ProviderProfileScreen({Key? key, required this.providerId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      specializationStateProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      'assets/images/provider_avatar.png',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Jane Provider',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text('Experience: 5 years'),
                  const Text('Completed Projects: 120'),
                  const Text('Rating: 4.8'),
                  const SizedBox(height: 16),
                  const Text('Service Areas: Nairobi, Mombasa'),
                  const SizedBox(height: 24),
                  // Specializations section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Specializations',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SpecializationsList(providerId: providerId),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAddSpecializationDialog(context, ref);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Specialization'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Verification documents section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verification Documents',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          VerificationDocumentsList(providerId: providerId),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showAddSpecializationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    List<String> selectedIds = [];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Specializations'),
        content: SizedBox(
          width: double.maxFinite,
          child: SpecializationSelector(
            selectedSpecializationIds: selectedIds,
            onSpecializationsChanged: (ids) {
              selectedIds = ids;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final notifier = ref.read(specializationStateProvider.notifier);
              for (final id in selectedIds) {
                await notifier.addSpecializationToProvider(providerId, id);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class SpecializationsList extends ConsumerWidget {
  final String providerId;

  const SpecializationsList({Key? key, required this.providerId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement provider-specific specializations logic using specializationStateProvider
    final specializationsAsync = ref.watch(specializationStateProvider);

    return specializationsAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return const Text('No specializations added yet');
        }
        return Column(
          children: data
              .map(
                (spec) => ListTile(
                  title: Text(spec.name),
                  subtitle: Text(spec.description ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      // Implement removal logic if needed
                    },
                    tooltip: 'Remove specialization',
                  ),
                ),
              )
              .toList(),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

class VerificationDocumentsList extends ConsumerWidget {
  final String providerId;

  const VerificationDocumentsList({Key? key, required this.providerId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement verification documents list
    return const Center(
      child: Text('Verification documents feature coming soon'),
    );
  }
}
