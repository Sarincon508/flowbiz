/// Model representing a Colombian President.
class President {
  final int id;
  final String name;
  final String lastName;
  final String? startPeriodDate;
  final String? endPeriodDate;
  final String? politicalParty;
  final String? description;
  final String? image;
  final int? cityId;

  President({
    required this.id,
    required this.name,
    required this.lastName,
    this.startPeriodDate,
    this.endPeriodDate,
    this.politicalParty,
    this.description,
    this.image,
    this.cityId,
  });

  /// Full concatenated name
  String get fullName => '$name $lastName'.trim();

  /// Formatted period representation (e.g. 1887 - 1888)
  String get periodDisplay {
    final start = (startPeriodDate != null && startPeriodDate!.isNotEmpty)
        ? startPeriodDate!.split('-').first
        : 'Desconocido';
    final end = (endPeriodDate != null && endPeriodDate!.isNotEmpty)
        ? endPeriodDate!.split('-').first
        : 'Actualidad';
    return '$start – $end';
  }

  factory President.fromJson(Map<String, dynamic> json) {
    return President(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      startPeriodDate: json['startPeriodDate'] as String?,
      endPeriodDate: json['endPeriodDate'] as String?,
      politicalParty: json['politicalParty'] as String? ?? 'Independiente / No especificado',
      description: json['description'] as String? ?? 'Sin biografía disponible.',
      image: json['image'] as String?,
      cityId: json['cityId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'startPeriodDate': startPeriodDate,
      'endPeriodDate': endPeriodDate,
      'politicalParty': politicalParty,
      'description': description,
      'image': image,
      'cityId': cityId,
    };
  }
}
