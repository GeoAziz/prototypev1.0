enum ServiceCategory {
  plumbing,
  electrical,
  cleaning,
  painting,
  carpentry,
  appliance;

  String get displayName {
    switch (this) {
      case ServiceCategory.plumbing:
        return 'Plumbing';
      case ServiceCategory.electrical:
        return 'Electrical';
      case ServiceCategory.cleaning:
        return 'Cleaning';
      case ServiceCategory.painting:
        return 'Painting';
      case ServiceCategory.carpentry:
        return 'Carpentry';
      case ServiceCategory.appliance:
        return 'Appliance';
    }
  }
}
