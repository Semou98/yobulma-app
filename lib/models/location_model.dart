class Location {
  final String quartier;
  final String adresse;
  final String? details;
  final double? latitude;
  final double? longitude;

  Location({
    required this.quartier,
    required this.adresse,
    this.details,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      quartier: json['quartier'],
      adresse: json['adresse'],
      details: json['details'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quartier': quartier,
      'adresse': adresse,
      'details': details,
      'lat': latitude, // Adapté au format attendu par ton API (lat/lon)
      'lon': longitude,
    };
  }
}
