/// Model representing a Touristic Attraction in Colombia.
class TouristicAttraction {
  final int id;
  final String name;
  final String description;
  final List<String> images;
  final String? latitude;
  final String? longitude;
  final int? cityId;
  final CitySummary? city;

  TouristicAttraction({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    this.latitude,
    this.longitude,
    this.cityId,
    this.city,
  });

  /// Returns the first image URL or null if empty
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  factory TouristicAttraction.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .where((img) => img != null && img.toString().trim().isNotEmpty)
          .map((img) => img.toString())
          .toList();
    }

    return TouristicAttraction(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Atracción turística',
      description: json['description'] as String? ?? 'Sin descripción disponible.',
      images: parsedImages,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      cityId: json['cityId'] as int?,
      city: json['city'] != null
          ? CitySummary.fromJson(json['city'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'cityId': cityId,
      'city': city?.toJson(),
    };
  }
}

/// Simplified city summary nested inside attraction
class CitySummary {
  final int id;
  final String name;
  final int? departmentId;

  CitySummary({
    required this.id,
    required this.name,
    this.departmentId,
  });

  factory CitySummary.fromJson(Map<String, dynamic> json) {
    return CitySummary(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Ciudad desconocida',
      departmentId: json['departmentId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'departmentId': departmentId,
    };
  }
}
