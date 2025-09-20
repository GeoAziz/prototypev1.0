class Availability {
  final String providerId;
  final List<DateTime> availableSlots;
  final bool isOnline;

  Availability({
    required this.providerId,
    required this.availableSlots,
    required this.isOnline,
  });

  Map<String, dynamic> toJson() => {
    'providerId': providerId,
    'availableSlots': availableSlots.map((dt) => dt.toIso8601String()).toList(),
    'isOnline': isOnline,
  };

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
    providerId: json['providerId'],
    availableSlots: (json['availableSlots'] as List)
        .map((s) => DateTime.parse(s))
        .toList(),
    isOnline: json['isOnline'] ?? false,
  );
}
