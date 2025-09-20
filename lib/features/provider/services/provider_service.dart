import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/provider.dart' as provider_model;
import '../repositories/provider_repository.dart';

class ProviderService {
  final ProviderRepository _repository;

  ProviderService({ProviderRepository? repository})
    : _repository = repository ?? ProviderRepository();

  Stream<List<provider_model.Provider>> getNearbyProviders({
    required GeoPoint center,
    required double radius,
    String? searchQuery,
    List<String>? categories,
  }) {
    return _repository.getNearbyProviders(
      center: center,
      radius: radius,
      searchQuery: searchQuery,
    );
  }

  Future<provider_model.Provider?> getProviderById(String id) {
    return _repository.getProviderById(id);
  }

  Future<void> updateProviderLocation(String providerId, GeoPoint location) {
    return _repository.updateProviderLocation(providerId, location);
  }

  Future<void> updateProviderStatus(String providerId, bool isActive) {
    return _repository.updateProviderStatus(providerId, isActive);
  }

  Future<void> updateProviderRating(String providerId, double rating) {
    return _repository.updateProviderRating(providerId, rating);
  }

  Stream<List<provider_model.Provider>> searchProviders(String query) {
    // You can implement more complex search logic here
    return _repository.getNearbyProviders(
      center: const GeoPoint(0, 0), // Default center
      radius: double.infinity, // No radius limit for search
      searchQuery: query,
    );
  }

  Future<List<provider_model.Provider>> getTopRatedProviders({int limit = 10}) {
    return _repository.getTopRatedProviders(limit: limit);
  }
}
