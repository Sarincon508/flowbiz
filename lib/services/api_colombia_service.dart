import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/department_model.dart';
import '../models/president_model.dart';
import '../models/touristic_attraction_model.dart';
import '../models/typical_dish_model.dart';

/// Custom exception for API errors with status codes and friendly messages.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException (Código $statusCode): $message';
    }
    return 'ApiException: $message';
  }
}

/// Service handling all HTTP GET requests to API Colombia.
class ApiColombiaService {
  final http.Client _client;

  ApiColombiaService({http.Client? client}) : _client = client ?? http.Client();

  /// Generic GET helper with UTF-8 decoding, timeout, and status code verification.
  Future<dynamic> _get(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=utf-8',
        },
      ).timeout(Environment.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Explicitly decode as UTF-8 to prevent accent/tilde distortion
        final decodedString = utf8.decode(response.bodyBytes);
        return json.decode(decodedString);
      } else if (response.statusCode == 404) {
        throw ApiException('El recurso solicitado no fue encontrado en la API.', 404);
      } else if (response.statusCode >= 500) {
        throw ApiException('Error del servidor de API Colombia. Intente más tarde.', response.statusCode);
      } else {
        throw ApiException(
          'Respuesta inesperada del servidor (HTTP ${response.statusCode}).',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('Sin conexión a internet. Verifique su red y vuelva a intentar.');
    } on TimeoutException {
      throw ApiException('El tiempo de espera para conectar con API Colombia se ha agotado.');
    } on FormatException {
      throw ApiException('Error al procesar el formato de la respuesta del servidor.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Ocurrió un error inesperado al consultar los datos: $e');
    }
  }

  // ================= DEPARTMENTS =================

  /// Retrieves all Colombian departments
  Future<List<Department>> getDepartments() async {
    final data = await _get(Environment.departmentsEndpoint);
    if (data is List) {
      return data
          .map((item) => Department.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException('Formato de datos de departamentos inválido.');
  }

  /// Retrieves a single department by its ID
  Future<Department> getDepartmentById(int id) async {
    final data = await _get('${Environment.departmentsEndpoint}/$id');
    if (data is Map<String, dynamic>) {
      return Department.fromJson(data);
    }
    throw ApiException('No se encontró el departamento con ID $id.');
  }

  // ============= TOURISTIC ATTRACTIONS =============

  /// Retrieves all touristic attractions in Colombia
  Future<List<TouristicAttraction>> getTouristicAttractions() async {
    final data = await _get(Environment.touristicAttractionsEndpoint);
    if (data is List) {
      return data
          .map((item) => TouristicAttraction.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException('Formato de atracciones turísticas inválido.');
  }

  /// Retrieves a single touristic attraction by its ID
  Future<TouristicAttraction> getTouristicAttractionById(int id) async {
    final data = await _get('${Environment.touristicAttractionsEndpoint}/$id');
    if (data is Map<String, dynamic>) {
      return TouristicAttraction.fromJson(data);
    }
    throw ApiException('No se encontró la atracción turística con ID $id.');
  }

  // ================= PRESIDENTS =================

  /// Retrieves all historical and current Colombian presidents
  Future<List<President>> getPresidents() async {
    final data = await _get(Environment.presidentsEndpoint);
    if (data is List) {
      return data
          .map((item) => President.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException('Formato de datos de presidentes inválido.');
  }

  /// Retrieves a single president by ID
  Future<President> getPresidentById(int id) async {
    final data = await _get('${Environment.presidentsEndpoint}/$id');
    if (data is Map<String, dynamic>) {
      return President.fromJson(data);
    }
    throw ApiException('No se encontró el presidente con ID $id.');
  }

  // ================ TYPICAL DISHES ================

  /// Retrieves all typical Colombian dishes
  Future<List<TypicalDish>> getTypicalDishes() async {
    final data = await _get(Environment.typicalDishesEndpoint);
    if (data is List) {
      return data
          .map((item) => TypicalDish.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException('Formato de datos de platos típicos inválido.');
  }

  /// Retrieves a single typical dish by ID
  Future<TypicalDish> getTypicalDishById(int id) async {
    final data = await _get('${Environment.typicalDishesEndpoint}/$id');
    if (data is Map<String, dynamic>) {
      return TypicalDish.fromJson(data);
    }
    throw ApiException('No se encontró el plato típico con ID $id.');
  }
}
