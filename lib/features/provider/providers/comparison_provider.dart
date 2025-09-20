import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/comparison_model.dart';
import '../models/provider_model.dart';
import '../repositories/comparison_repository.dart';

part 'comparison_provider.g.dart';

@riverpod
class ComparisonState extends AutoDisposeAsyncNotifier<ComparisonResult?> {
  late final ComparisonRepository _repository;

  @override
  FutureOr<ComparisonResult?> build() {
    _repository = ComparisonRepository();
    return null;
  }

  Future<void> compareProviders(List<ProviderModel> providers) async {
    if (providers.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _repository.compareProviders(providers);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearComparison() {
    state = const AsyncValue.data(null);
  }

  bool isProviderSelected(String providerId) {
    return state.value?.items.any((item) => item.provider.id == providerId) ??
        false;
  }

  List<ComparisonItem> getRankedProviders() {
    return state.value?.rankedItems ?? [];
  }

  double? getProviderScore(String providerId) {
    return state.value?.scores[providerId];
  }

  List<String>? getProviderHighlights(String providerId) {
    return state.value?.highlights[providerId];
  }

  Map<String, double> get scores {
    return state.value?.scores ?? {};
  }

  Map<String, List<String>> get highlights {
    return state.value?.highlights ?? {};
  }
}
