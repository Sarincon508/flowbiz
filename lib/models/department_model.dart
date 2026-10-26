/// Model representing a Department in Colombia.
class Department {
  final int id;
  final String name;
  final String description;
  final int? cityCapitalId;
  final int? municipalities;
  final num? surface;
  final int? population;
  final String? phonePrefix;
  final CityCapital? cityCapital;
  final int? regionId;

  Department({
    required this.id,
    required this.name,
    required this.description,
    this.cityCapitalId,
    this.municipalities,
    this.surface,
    this.population,
    this.phonePrefix,
    this.cityCapital,
    this.regionId,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Sin nombre',
      description: json['description'] as String? ?? 'Sin descripción disponible.',
      cityCapitalId: json['cityCapitalId'] as int?,
      municipalities: json['municipalities'] as int?,
      surface: json['surface'] as num?,
      population: json['population'] as int?,
      phonePrefix: json['phonePrefix']?.toString(),
      cityCapital: json['cityCapital'] != null
          ? CityCapital.fromJson(json['cityCapital'] as Map<String, dynamic>)
          : null,
      regionId: json['regionId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cityCapitalId': cityCapitalId,
      'municipalities': municipalities,
      'surface': surface,
      'population': population,
      'phonePrefix': phonePrefix,
      'cityCapital': cityCapital?.toJson(),
      'regionId': regionId,
    };
  }
}

/// Model representing the Capital City of a Department.
class CityCapital {
  final int id;
  final String name;
  final String? description;
  final num? surface;
  final int? population;
  final String? postalCode;

  CityCapital({
    required this.id,
    required this.name,
    this.description,
    this.surface,
    this.population,
    this.postalCode,
  });

  factory CityCapital.fromJson(Map<String, dynamic> json) {
    return CityCapital(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Capital no registrada',
      description: json['description'] as String?,
      surface: json['surface'] as num?,
      population: json['population'] as int?,
      postalCode: json['postalCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'surface': surface,
      'population': population,
      'postalCode': postalCode,
    };
  }
}
