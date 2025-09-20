import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/specialization_model.dart';
import '../repositories/specialization_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'specialization_provider.g.dart';

@riverpod
class SpecializationState
    extends AutoDisposeAsyncNotifier<List<SpecializationModel>> {
  Future<void> addSpecializationToProvider(
    String providerId,
    String specializationId,
  ) async {
    // Example Firestore structure: provider_specializations/{providerId}_{specializationId}
    final docId = '${providerId}_$specializationId';
    final docRef = FirebaseFirestore.instance
        .collection('provider_specializations')
        .doc(docId);
    await docRef.set({
      'providerId': providerId,
      'specializationId': specializationId,
      'addedAt': DateTime.now().toIso8601String(),
    });
    // Optionally refresh state or handle UI update
  }

  late final SpecializationRepository _repository;

  @override
  FutureOr<List<SpecializationModel>> build() {
    _repository = SpecializationRepository();
    return _fetchSpecializations();
  }

  Future<List<SpecializationModel>> _fetchSpecializations() async {
    try {
      return await _repository.getAllSpecializations();
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> addSpecialization(SpecializationModel specialization) async {
    try {
      await _repository.addSpecialization(specialization);
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _fetchSpecializations());
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> updateSpecialization(SpecializationModel specialization) async {
    try {
      await _repository.updateSpecialization(specialization);
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _fetchSpecializations());
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> deleteSpecialization(String id) async {
    try {
      await _repository.deleteSpecialization(id);
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _fetchSpecializations());
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<List<SpecializationModel>> getSpecializationsByCategory(
    String category,
  ) async {
    try {
      return await _repository.getSpecializationsByCategory(category);
    } catch (error) {
      throw Exception('Failed to fetch specializations by category: $error');
    }
  }

  Future<SpecializationModel?> getSpecialization(String id) async {
    try {
      return await _repository.getSpecialization(id);
    } catch (error) {
      throw Exception('Failed to fetch specialization: $error');
    }
  }
}

@riverpod
class SpecializationFilter extends AutoDisposeNotifier<String?> {
  @override
  String? build() => null;

  void setCategory(String? category) => state = category;

  void clearFilter() => state = null;
}

@riverpod
Future<List<SpecializationModel>> filteredSpecializations(
  FilteredSpecializationsRef ref,
) async {
  final selectedCategory = ref.watch(specializationFilterProvider);
  final specializations = await ref.watch(specializationStateProvider.future);

  if (selectedCategory == null) return specializations;

  return specializations
      .where((spec) => spec.category == selectedCategory)
      .toList();
}
