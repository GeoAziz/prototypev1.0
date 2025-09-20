class PackageDeal {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final double price;
  final List<String> services;

  PackageDeal({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.price,
    required this.services,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'providerId': providerId,
    'title': title,
    'description': description,
    'price': price,
    'services': services,
  };

  factory PackageDeal.fromJson(Map<String, dynamic> json) => PackageDeal(
    id: json['id'],
    providerId: json['providerId'],
    title: json['title'],
    description: json['description'],
    price: (json['price'] ?? 0.0).toDouble(),
    services: List<String>.from(json['services'] ?? []),
  );
}
