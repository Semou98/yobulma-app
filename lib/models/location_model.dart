class LocationPoint {
  final double latitude;
  final double longitude;
  final String? address; // Ajoutez ce champ
  final String? quartier; // Ajoutez aussi quartier si nécessaire

  LocationPoint({
    required this.latitude,
    required this.longitude,
    this.address,
    this.quartier,
  });

  // Méthode toMap si nécessaire
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'quartier': quartier,
    };
  }

  // Factory pour créer depuis une Map
  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'],
      quartier: map['quartier'],
    );
  }
}