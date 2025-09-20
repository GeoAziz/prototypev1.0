import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/specialization_model.dart';
import '../providers/specialization_provider.dart';

class SpecializationManagementScreen extends ConsumerWidget {
  const SpecializationManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specializations = ref.watch(specializationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Specializations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSpecializationDialog(context, ref),
          ),
        ],
      ),
      body: specializations.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No specializations found'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final specialization = data[index];
              return SpecializationCard(specialization: specialization);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _showAddSpecializationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';
    List<String> tags = [];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Specialization'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => name = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => description = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one tag';
                  }
                  return null;
                },
                onSaved: (value) => tags =
                    value?.split(',').map((e) => e.trim()).toList() ?? [],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                ref
                    .read(specializationStateProvider.notifier)
                    .addSpecialization(
                      SpecializationModel(
                        id: UniqueKey().toString(),
                        name: name,
                        description: description,
                        skills: tags,
                      ),
                    );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class SpecializationCard extends ConsumerWidget {
  final SpecializationModel specialization;

  const SpecializationCard({super.key, required this.specialization});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(specialization.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(specialization.description ?? ''),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: (specialization.skills ?? [])
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editSpecialization(context, ref),
              tooltip: 'Edit specialization',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSpecialization(context, ref),
              tooltip: 'Delete specialization',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editSpecialization(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    String name = specialization.name;
    String description = specialization.description ?? '';
    List<String> tags = List.from(specialization.skills ?? []);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Specialization'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => name = value ?? '',
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => description = value ?? '',
              ),
              TextFormField(
                initialValue: tags.join(', '),
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one tag';
                  }
                  return null;
                },
                onSaved: (value) => tags =
                    value?.split(',').map((e) => e.trim()).toList() ?? [],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                ref
                    .read(specializationStateProvider.notifier)
                    .updateSpecialization(
                      SpecializationModel(
                        id: specialization.id,
                        name: name,
                        description: description,
                        skills: tags,
                        category: specialization.category,
                        requirements: specialization.requirements,
                        certifications: specialization.certifications,
                      ),
                    );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSpecialization(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Specialization'),
        content: const Text(
          'Are you sure you want to delete this specialization? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await ref
          .read(specializationStateProvider.notifier)
          .deleteSpecialization(specialization.id);
    }
  }
}
