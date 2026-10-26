/// Model representing a Typical Dish in Colombia.
class TypicalDish {
  final int id;
  final String name;
  final String description;
  final String? ingredients;
  final String? imageUrl;
  final int? departmentId;
  final DepartmentSummary? department;

  TypicalDish({
    required this.id,
    required this.name,
    required this.description,
    this.ingredients,
    this.imageUrl,
    this.departmentId,
    this.department,
  });

  /// Returns parsed list of ingredients
  List<String> get ingredientsList {
    if (ingredients == null || ingredients!.trim().isEmpty) return [];
    return ingredients!
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  factory TypicalDish.fromJson(Map<String, dynamic> json) {
    return TypicalDish(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Plato típico',
      description: json['description'] as String? ?? 'Sin descripción disponible.',
      ingredients: json['ingredients'] as String?,
      imageUrl: json['imageUrl'] as String?,
      departmentId: json['departmentId'] as int?,
      department: json['department'] != null
          ? DepartmentSummary.fromJson(json['department'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'departmentId': departmentId,
      'department': department?.toJson(),
    };
  }
}

/// Simplified department summary nested inside typical dish
class DepartmentSummary {
  final int id;
  final String name;
  final String? description;

  DepartmentSummary({
    required this.id,
    required this.name,
    this.description,
  });

  factory DepartmentSummary.fromJson(Map<String, dynamic> json) {
    return DepartmentSummary(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Departamento desconocido',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
