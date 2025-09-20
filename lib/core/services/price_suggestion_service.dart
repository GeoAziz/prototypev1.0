import '../../core/enums/service_category.dart';
import '../../core/data/service_definitions.dart';

class PriceSuggestion {
  final double minPrice;
  final double maxPrice;
  final String pricingType;
  final bool isWithinRange;
  final String message;

  PriceSuggestion({
    required this.minPrice,
    required this.maxPrice,
    required this.pricingType,
    required this.isWithinRange,
    required this.message,
  });
}

class PriceSuggestionService {
  // Get price suggestion for a main service
  PriceSuggestion getSuggestion({
    required ServiceCategory category,
    required double proposedPrice,
    String? subServiceName,
  }) {
    final serviceDefinition = serviceDefinitions[category];
    if (serviceDefinition == null) {
      return PriceSuggestion(
        minPrice: 0,
        maxPrice: 0,
        pricingType: 'flat',
        isWithinRange: false,
        message: 'Service category not found',
      );
    }

    // If subservice is specified, get its price range
    if (subServiceName != null) {
      final subService = serviceDefinition.subServices
          .where((sub) => sub.name == subServiceName)
          .firstOrNull;

      if (subService != null) {
        final isWithin =
            proposedPrice >= subService.basePrice &&
            proposedPrice <= subService.maxPrice;

        return PriceSuggestion(
          minPrice: subService.basePrice,
          maxPrice: subService.maxPrice,
          pricingType: subService.pricingType,
          isWithinRange: isWithin,
          message: _getSuggestionMessage(
            isWithin,
            subService.basePrice,
            subService.maxPrice,
            subService.pricingType,
          ),
        );
      }
    }

    // Default to main service price range
    final isWithin =
        proposedPrice >= serviceDefinition.basePrice &&
        proposedPrice <= serviceDefinition.maxPrice;

    return PriceSuggestion(
      minPrice: serviceDefinition.basePrice,
      maxPrice: serviceDefinition.maxPrice,
      pricingType: serviceDefinition.pricingType,
      isWithinRange: isWithin,
      message: _getSuggestionMessage(
        isWithin,
        serviceDefinition.basePrice,
        serviceDefinition.maxPrice,
        serviceDefinition.pricingType,
      ),
    );
  }

  String _getSuggestionMessage(
    bool isWithin,
    double minPrice,
    double maxPrice,
    String pricingType,
  ) {
    final priceRange =
        'KES ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)}';
    final pricingNote = pricingType == 'flat'
        ? ''
        : pricingType == 'hourly'
        ? ' per hour'
        : pricingType == 'per_unit'
        ? ' per unit'
        : ' callout fee';

    if (isWithin) {
      return 'Your price is within the recommended range: $priceRange$pricingNote';
    } else {
      return 'Consider adjusting your price to the recommended range: $priceRange$pricingNote';
    }
  }

  // Get all subservices for a category
  List<SubService> getSubServices(ServiceCategory category) {
    return serviceDefinitions[category]?.subServices ?? [];
  }

  // Get service definition for a category
  ServiceDefinition? getServiceDefinition(ServiceCategory category) {
    return serviceDefinitions[category];
  }
}
