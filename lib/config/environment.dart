import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment and configuration constants.
class Environment {
  /// Base URL of API Colombia, loaded from .env with fallback.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api-colombia.com/api/v1';

  /// App name from .env with fallback.
  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'Datos Abiertos de Colombia';

  /// Connection timeout duration in seconds.
  static const Duration timeout = Duration(seconds: 15);

  /// Specific endpoints
  static String get departmentsEndpoint => '$apiBaseUrl/Department';
  static String get touristicAttractionsEndpoint =>
      '$apiBaseUrl/TouristicAttraction';
  static String get presidentsEndpoint => '$apiBaseUrl/President';
  static String get typicalDishesEndpoint => '$apiBaseUrl/TypicalDish';

  /// Helper to initialize dotenv safely
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Fallback if .env is missing or fails to load in release/test mode
    }
  }
}
