import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String image;
  final double rating;
  final int reviewCount;
  final int bookingCount;
  final List<String> images;
  final List<String> features;
  final bool isFeatured;
  final bool isPopular;
  final GeoPoint? location;
  final String providerId;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.bookingCount,
    required this.images,
    required this.features,
    required this.providerId,
    this.isFeatured = false,
    this.isPopular = false,
    this.location,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] as String? ?? '',
      image: json['image'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      bookingCount: json['bookingCount'] as int? ?? 0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      providerId: json['providerId'] as String? ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      location: json['location'] is GeoPoint
          ? json['location'] as GeoPoint
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'bookingCount': bookingCount,
      'images': images,
      'features': features,
      'providerId': providerId,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'location': location,
    };
  }
}

// Example services for demo
List<Service> demoServices = [
  Service(
    id: '1',
    name: 'Standard Home Cleaning',
    description:
        'Professional cleaning service to make your home spotless and fresh. Our team uses eco-friendly products and advanced cleaning techniques.',
    price: 120,
    categoryId: '1',
    image:
        'https://img.icons8.com/?size=100&id=12237&format=png&color=000000?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    rating: 4.8,
    reviewCount: 245,
    bookingCount: 1250,
    images: [
      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1563453392212-326f5e854473?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1595091029053-d296ad9bf661?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    ],
    features: [
      'Dusting all accessible surfaces',
      'Vacuuming carpets and floors',
      'Mopping all floors',
      'Cleaning kitchen surfaces',
      'Cleaning bathrooms',
      'Waste removal',
    ],
    isFeatured: true,
    isPopular: true,
    providerId: 'provider5',
  ),
  Service(
    id: '2',
    name: 'Deep Cleaning Service',
    description:
        'A thorough cleaning service for homes that need extra attention. Includes cleaning inside appliances, behind furniture, and detailed scrubbing.',
    price: 220,
    categoryId: '1',
    image:
        'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    rating: 4.9,
    reviewCount: 189,
    bookingCount: 876,
    images: [
      'https://images.unsplash.com/photo-1615875409064-e1354e8e6896?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1587316290720-10dfa4e1b7bd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    ],
    features: [
      'All standard cleaning tasks',
      'Inside oven and refrigerator cleaning',
      'Cabinet interiors',
      'Window cleaning',
      'Baseboards and door frames',
      'Light fixtures and ceiling fans',
    ],
    isFeatured: true,
    providerId: 'provider6',
  ),
  Service(
    id: '3',
    name: 'Pipe Leak Repair',
    description:
        'Fast and reliable repair for any pipe leaks in your home. Our certified plumbers fix all types of pipe leaks to prevent water damage.',
    price: 90,
    categoryId: '2',
    image:
        'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.7QWfuGGRlWmxkpaPWePCLgHaE8%3Fpid%3DApi&f=1&ipt=1c8c1eec5a6964c8f820bb8f92e26af83356172dab7b94701093499211619c41&ipo=images?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    rating: 4.7,
    reviewCount: 156,
    bookingCount: 735,
    images: [
      'https://images.unsplash.com/photo-1542013936693-884638332954?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1620626576482-c9b6f7405e3b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1499744937866-d7e566a20a61?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    ],
    features: [
      'Leak detection',
      'Pipe repair or replacement',
      'Water pressure testing',
      'Fixture inspection',
      'Joint sealing',
      '30-day guarantee',
    ],
    isPopular: true,
    providerId: 'provider2',
  ),
  Service(
    id: '4',
    name: 'Bathroom Installation',
    description:
        'Complete bathroom installation service including fixtures, plumbing, and finishing. Transform your bathroom with our expert plumbers.',
    price: 580,
    categoryId: '2',
    image:
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    rating: 4.9,
    reviewCount: 122,
    bookingCount: 450,
    images: [
      'https://images.unsplash.com/photo-1576698483491-8c43f0862543?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1507652313519-d4e9174996dd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1595515106969-1ce29566ff1e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    ],
    features: [
      'Fixture installation',
      'Plumbing connection',
      'Tile installation',
      'Waterproofing',
      'Vanity installation',
      'Final inspection and testing',
    ],
    isFeatured: true,
    providerId: 'provider3',
  ),
  Service(
    id: '5',
    name: 'Electrical Wiring',
    description:
        'Professional electrical wiring service for new installations or rewiring existing systems. All work meets safety codes and regulations.',
    price: 150,
    categoryId: '3',
    image:
        'https://images.pexels.com/photos/9242887/pexels-photo-9242887.jpeg?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    rating: 4.8,
    reviewCount: 178,
    bookingCount: 689,
    images: [
      'https://images.unsplash.com/photo-1585645568877-e5fe4cea5679?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1621905251918-48416bd8575a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1555963966-b7ae5404b6ed?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    ],
    features: [
      'Circuit installation',
      'Panel upgrades',
      'Outlet installation',
      'Safety inspection',
      'Compliance with electrical codes',
      '1-year warranty on work',
    ],
    isPopular: true,
    providerId: 'provider1',
  ),
  Service(
    id: '6',
    name: 'Room Painting',
    description:
        'Transform your space with our professional painting services. We use high-quality paints and techniques for a perfect finish.',
    price: 320,
    categoryId: '4',
    image:
        'https://img.icons8.com/?size=100&id=9fS8epYOUvtK&format=png&color=000000?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    rating: 4.7,
    reviewCount: 205,
    bookingCount: 920,
    images: [
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1558402529-d2638a7023e9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1595428774223-ef52624120d2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
    ],
    features: [
      'Surface preparation',
      'Premium quality paint',
      'Edge protection',
      'Furniture protection',
      'Two coats of paint',
      'Clean-up after completion',
    ],
    isFeatured: true,
    isPopular: true,
    providerId: 'provider4',
  ),
];
