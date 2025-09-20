import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider_model.dart';

class CacheService {
  static const String _providersKey = 'cached_providers';
  static const Duration _cacheExpiry = Duration(hours: 24);
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<void> cacheProviders(List<ProviderModel> providers) async {
    final timestamp = DateTime.now().toIso8601String();
    final data = {
      'timestamp': timestamp,
      'providers': providers.map((p) => p.toJson()).toList(),
    };
    await _prefs.setString(_providersKey, jsonEncode(data));
  }

  Future<List<ProviderModel>?> getCachedProviders() async {
    final cachedData = _prefs.getString(_providersKey);
    if (cachedData == null) return null;

    final data = jsonDecode(cachedData) as Map<String, dynamic>;
    final timestamp = DateTime.parse(data['timestamp'] as String);
    final now = DateTime.now();

    // Return null if cache has expired
    if (now.difference(timestamp) > _cacheExpiry) {
      await _prefs.remove(_providersKey);
      return null;
    }

    final providersJson = data['providers'] as List;
    return providersJson
        .map((json) => ProviderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearCache() async {
    await _prefs.remove(_providersKey);
  }
}

final cacheServiceProvider = Provider<CacheService>((ref) {
  throw UnimplementedError(
    'Initialize this provider with an instance of SharedPreferences',
  );
});

// Updated provider repository with caching
class CachedProviderRepository {
  final CacheService _cacheService;

  CachedProviderRepository(this._cacheService);

  Future<List<ProviderModel>> getProviders({
    Map<String, dynamic>? options,
  }) async {
    try {
      // TODO: Replace with actual repository logic, e.g. fetch from Firestore
      final providers = <ProviderModel>[];
      await _cacheService.cacheProviders(providers);
      return providers;
    } catch (e) {
      final cachedProviders = await _cacheService.getCachedProviders();
      if (cachedProviders != null) {
        return cachedProviders;
      }
      rethrow;
    }
  }
}

// Optimized provider state with caching
class OptimizedProviderState {
  final List<ProviderModel> providers;
  final bool isLoading;
  final String? error;
  final bool isCached;
  final DateTime? lastUpdated;

  OptimizedProviderState({
    this.providers = const [],
    this.isLoading = false,
    this.error,
    this.isCached = false,
    this.lastUpdated,
  });

  OptimizedProviderState copyWith({
    List<ProviderModel>? providers,
    bool? isLoading,
    String? error,
    bool? isCached,
    DateTime? lastUpdated,
  }) {
    return OptimizedProviderState(
      providers: providers ?? this.providers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isCached: isCached ?? this.isCached,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class OptimizedProviderNotifier extends StateNotifier<OptimizedProviderState> {
  final CachedProviderRepository _repository;
  static const _prefetchThreshold = 10;

  OptimizedProviderNotifier(this._repository)
    : super(OptimizedProviderState()) {
    _initializeWithCache();
  }

  Future<void> _initializeWithCache() async {
    final cachedProviders = await _repository._cacheService
        .getCachedProviders();
    if (cachedProviders != null) {
      state = OptimizedProviderState(
        providers: cachedProviders,
        isCached: true,
        lastUpdated: DateTime.now(),
      );
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    try {
      final providers = await _repository.getProviders();
      state = state.copyWith(
        providers: providers,
        isCached: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to refresh data: $e');
    }
  }

  Future<void> prefetchNextBatch() async {
    if (state.isLoading) return;
    final currentCount = state.providers.length;
    try {
      final nextBatch = await _repository.getProviders(
        options: {'offset': currentCount, 'limit': 20},
      );
      if (nextBatch.isNotEmpty) {
        state = state.copyWith(
          providers: [...state.providers, ...nextBatch],
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load more providers: $e');
    }
  }

  void checkPrefetch(int currentIndex) {
    if (currentIndex >= state.providers.length - _prefetchThreshold) {
      prefetchNextBatch();
    }
  }
}
