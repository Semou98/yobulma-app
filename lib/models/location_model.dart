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
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      quartier: json['quartier'],
      adresse: json['adresse'],
      details: json['details'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quartier': quartier,
      'adresse': adresse,
      'details': details,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
