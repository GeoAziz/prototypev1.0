import 'package:poafix/core/enums/service_category.dart';

class ServiceDefinition {
  final String name;
  final String description;
  final List<String> features;
  final double basePrice;
  final double maxPrice;
  final String pricingType;
  final List<SubService> subServices;

  ServiceDefinition({
    required this.name,
    required this.description,
    required this.features,
    required this.basePrice,
    required this.maxPrice,
    required this.pricingType,
    required this.subServices,
  });
}

class SubService {
  final String name;
  final String description;
  final double basePrice;
  final double maxPrice;
  final String pricingType;
  final List<String> features;

  SubService({
    required this.name,
    required this.description,
    required this.basePrice,
    required this.maxPrice,
    required this.pricingType,
    required this.features,
  });
}

// Service definitions based on market research
final Map<ServiceCategory, ServiceDefinition> serviceDefinitions = {
  ServiceCategory.cleaning: ServiceDefinition(
    name: 'Home Cleaning',
    description: 'Professional cleaning services for homes and offices',
    basePrice: 1500,
    maxPrice: 3500,
    pricingType: 'flat',
    features: [
      'Eco-friendly cleaning products',
      'Trained professional cleaners',
      'Flexible scheduling',
      'Quality guarantee',
    ],
    subServices: [
      SubService(
        name: 'Standard Cleaning',
        description: 'Basic home cleaning including sweep, mop, and dust',
        basePrice: 1500,
        maxPrice: 2000,
        pricingType: 'flat',
        features: [
          'Sweep and mop floors',
          'Dust furniture and surfaces',
          'Clean bathrooms',
          'Clean kitchen surfaces',
          'Waste removal',
        ],
      ),
      SubService(
        name: 'Deep Cleaning',
        description: 'Thorough cleaning including walls and behind furniture',
        basePrice: 3500,
        maxPrice: 5000,
        pricingType: 'flat',
        features: [
          'All standard cleaning tasks',
          'Wall cleaning',
          'Behind furniture cleaning',
          'Window cleaning',
          'Cabinet interior cleaning',
        ],
      ),
      SubService(
        name: 'Post-Construction Cleaning',
        description: 'Clean-up after construction or renovation',
        basePrice: 4000,
        maxPrice: 6000,
        pricingType: 'flat',
        features: [
          'Debris removal',
          'Dust removal',
          'Surface cleaning',
          'Floor cleaning',
          'Window cleaning',
        ],
      ),
    ],
  ),

  ServiceCategory.plumbing: ServiceDefinition(
    name: 'Plumbing Services',
    description: 'Professional plumbing repairs and installations',
    basePrice: 800,
    maxPrice: 2000,
    pricingType: 'callout_fee',
    features: [
      'Licensed plumbers',
      'Emergency services',
      'Quality parts',
      'Warranty on work',
    ],
    subServices: [
      SubService(
        name: 'Emergency Repairs',
        description: 'Urgent plumbing repairs',
        basePrice: 1200,
        maxPrice: 2500,
        pricingType: 'callout_fee',
        features: [
          'Available 24/7',
          'Quick response',
          'Emergency fixes',
          'Water damage prevention',
        ],
      ),
      SubService(
        name: 'Installation Services',
        description: 'Installation of plumbing fixtures',
        basePrice: 1500,
        maxPrice: 3000,
        pricingType: 'flat',
        features: [
          'Fixture installation',
          'Quality parts',
          'Professional installation',
          'Testing included',
        ],
      ),
    ],
  ),

  ServiceCategory.electrical: ServiceDefinition(
    name: 'Electrical Services',
    description: 'Professional electrical repairs and installations',
    basePrice: 1200,
    maxPrice: 2500,
    pricingType: 'hourly',
    features: [
      'Licensed electricians',
      'Safety certified',
      'Emergency services',
      'Quality materials',
    ],
    subServices: [
      SubService(
        name: 'Wiring Installation',
        description: 'New wiring installation or rewiring',
        basePrice: 1500,
        maxPrice: 3000,
        pricingType: 'flat',
        features: [
          'Professional installation',
          'Code compliance',
          'Safety testing',
          'Quality materials',
        ],
      ),
      SubService(
        name: 'Emergency Repairs',
        description: 'Urgent electrical repairs',
        basePrice: 1200,
        maxPrice: 2500,
        pricingType: 'callout_fee',
        features: [
          '24/7 availability',
          'Quick response',
          'Safety first',
          'Emergency fixes',
        ],
      ),
    ],
  ),

  ServiceCategory.painting: ServiceDefinition(
    name: 'Painting Services',
    description: 'Professional painting services for homes and offices',
    basePrice: 320,
    maxPrice: 500,
    pricingType: 'per_unit',
    features: [
      'Quality paints',
      'Professional painters',
      'Clean work',
      'Color consultation',
    ],
    subServices: [
      SubService(
        name: 'Interior Painting',
        description: 'Indoor wall and ceiling painting',
        basePrice: 320,
        maxPrice: 450,
        pricingType: 'per_unit',
        features: [
          'Wall preparation',
          'Quality paints',
          'Even finish',
          'Clean work area',
        ],
      ),
      SubService(
        name: 'Exterior Painting',
        description: 'Outdoor painting services',
        basePrice: 400,
        maxPrice: 600,
        pricingType: 'per_unit',
        features: [
          'Weather-resistant paint',
          'Surface preparation',
          'Quality finish',
          'Professional team',
        ],
      ),
    ],
  ),

  ServiceCategory.carpentry: ServiceDefinition(
    name: 'Carpentry Services',
    description: 'Professional carpentry and woodwork services',
    basePrice: 1200,
    maxPrice: 2500,
    pricingType: 'hourly',
    features: [
      'Skilled carpenters',
      'Quality materials',
      'Custom solutions',
      'Professional tools',
    ],
    subServices: [
      SubService(
        name: 'Furniture Repair',
        description: 'Repair and restore furniture',
        basePrice: 1000,
        maxPrice: 2000,
        pricingType: 'flat',
        features: [
          'Expert repair',
          'Quality materials',
          'Restoration options',
          'Quick service',
        ],
      ),
      SubService(
        name: 'Custom Carpentry',
        description: 'Custom woodwork and installations',
        basePrice: 1500,
        maxPrice: 3000,
        pricingType: 'hourly',
        features: [
          'Custom designs',
          'Quality wood',
          'Professional finish',
          'Installation included',
        ],
      ),
    ],
  ),

  ServiceCategory.gardening: ServiceDefinition(
    name: 'Gardening Services',
    description: 'Professional garden maintenance and landscaping',
    basePrice: 1000,
    maxPrice: 2000,
    pricingType: 'flat',
    features: [
      'Professional gardeners',
      'Quality tools',
      'Plant care expertise',
      'Regular maintenance',
    ],
    subServices: [
      SubService(
        name: 'Garden Maintenance',
        description: 'Regular garden upkeep',
        basePrice: 1000,
        maxPrice: 1500,
        pricingType: 'flat',
        features: [
          'Lawn mowing',
          'Plant care',
          'Weeding',
          'General maintenance',
        ],
      ),
      SubService(
        name: 'Landscaping',
        description: 'Garden design and landscaping',
        basePrice: 2000,
        maxPrice: 5000,
        pricingType: 'flat',
        features: [
          'Custom design',
          'Plant selection',
          'Installation',
          'Maintenance plan',
        ],
      ),
    ],
  ),

  ServiceCategory.moving: ServiceDefinition(
    name: 'Moving Services',
    description: 'Professional moving and relocation services',
    basePrice: 2500,
    maxPrice: 5000,
    pricingType: 'flat',
    features: [
      'Professional movers',
      'Careful handling',
      'Transport vehicles',
      'Insurance coverage',
    ],
    subServices: [
      SubService(
        name: 'Local Moving',
        description: 'Moving within the city',
        basePrice: 2500,
        maxPrice: 4000,
        pricingType: 'flat',
        features: [
          'Loading/unloading',
          'Transport',
          'Basic packing',
          'Furniture assembly',
        ],
      ),
      SubService(
        name: 'Office Relocation',
        description: 'Commercial moving services',
        basePrice: 4000,
        maxPrice: 8000,
        pricingType: 'flat',
        features: [
          'Business hour moves',
          'Equipment handling',
          'Minimal disruption',
          'Insurance coverage',
        ],
      ),
    ],
  ),

  ServiceCategory.appliances: ServiceDefinition(
    name: 'Appliance Repair',
    description: 'Professional appliance repair services',
    basePrice: 800,
    maxPrice: 2000,
    pricingType: 'callout_fee',
    features: [
      'Expert technicians',
      'Multiple brands',
      'Quality parts',
      'Service warranty',
    ],
    subServices: [
      SubService(
        name: 'Major Appliance Repair',
        description: 'Repair for large household appliances',
        basePrice: 1000,
        maxPrice: 2500,
        pricingType: 'flat',
        features: [
          'Refrigerator repair',
          'Washing machine repair',
          'Dryer repair',
          'Dishwasher repair',
        ],
      ),
      SubService(
        name: 'Small Appliance Repair',
        description: 'Repair for small household appliances',
        basePrice: 500,
        maxPrice: 1000,
        pricingType: 'flat',
        features: [
          'Microwave repair',
          'Toaster repair',
          'Blender repair',
          'Coffee maker repair',
        ],
      ),
    ],
  ),
};
