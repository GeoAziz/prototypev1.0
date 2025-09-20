enum ServiceCategory {
  cleaning,
  plumbing,
  electrical,
  painting,
  carpentry,
  gardening,
  moving,
  appliances,
  other;

  String get displayName =>
      name.substring(0, 1).toUpperCase() + name.substring(1);
}
