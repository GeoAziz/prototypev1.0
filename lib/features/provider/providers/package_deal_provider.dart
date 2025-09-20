import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/package_deal.dart';
import '../repositories/package_deal_repository.dart';

final packageDealRepositoryProvider = Provider<PackageDealRepository>((ref) {
  return PackageDealRepository();
});

class PackageDealState {
  final List<PackageDeal> packages;
  final bool isLoading;
  final String? error;

  PackageDealState({
    this.packages = const [],
    this.isLoading = false,
    this.error,
  });

  PackageDealState copyWith({
    List<PackageDeal>? packages,
    bool? isLoading,
    String? error,
  }) {
    return PackageDealState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PackageDealNotifier extends StateNotifier<PackageDealState> {
  final PackageDealRepository repo;

  PackageDealNotifier(this.repo) : super(PackageDealState());

  Future<void> fetchPackageDeals(String providerId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final packages = await repo.fetchPackageDeals(providerId);
      state = state.copyWith(packages: packages, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch package deals: $e',
      );
    }
  }

  Future<void> createPackageDeal(PackageDeal packageDeal) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await repo.createPackageDeal(packageDeal);
      state = state.copyWith(
        packages: [...state.packages, packageDeal],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create package deal: $e',
      );
    }
  }

  Future<void> updatePackageDeal(PackageDeal packageDeal) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await repo.updatePackageDeal(packageDeal);
      state = state.copyWith(
        packages: state.packages
            .map((p) => p.id == packageDeal.id ? packageDeal : p)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update package deal: $e',
      );
    }
  }

  Future<void> deletePackageDeal(String packageId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await repo.deletePackageDeal(packageId);
      state = state.copyWith(
        packages: state.packages.where((p) => p.id != packageId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete package deal: $e',
      );
    }
  }
}

final packageDealProvider =
    StateNotifierProvider.family<PackageDealNotifier, PackageDealState, String>(
      (ref, providerId) {
        final repository = ref.watch(packageDealRepositoryProvider);
        return PackageDealNotifier(repository);
      },
    );
