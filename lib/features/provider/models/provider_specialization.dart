import 'dart:convert';

class ProviderSpecialization {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? verificationDocument;
  final Map<String, dynamic>? metadata;

  ProviderSpecialization({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    this.isVerified = false,
    required this.createdAt,
    this.verifiedAt,
    this.verificationDocument,
    this.metadata,
  });

  factory ProviderSpecialization.fromJson(Map<String, dynamic> json) {
    return ProviderSpecialization(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      verificationDocument: json['verificationDocument'] as String?,
      metadata: json['metadata'] != null
          ? jsonDecode(json['metadata'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verificationDocument': verificationDocument,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  ProviderSpecialization copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? tags,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? verifiedAt,
    String? verificationDocument,
    Map<String, dynamic>? metadata,
  }) {
    return ProviderSpecialization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationDocument: verificationDocument ?? this.verificationDocument,
      metadata: metadata ?? this.metadata,
    );
  }
}
