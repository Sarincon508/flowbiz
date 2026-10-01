import 'dart:async';
import '../models/async_task_models.dart';

/// Servicio que simula una consulta de datos a un servidor remoto / API REST
/// demostrando el uso de Future, async y await sin bloquear la interfaz gráfica.
///
/// Estudiante: Samuel Alejandro Rincon Serna (230231045)
/// UCEVA - Electiva Profesional 1 Móviles
class AsyncDataService {
  /// Consulta simulada de reporte financiero y operativo.
  ///
  /// Parámetros:
  /// - [delay]: Tiempo de espera simulado con Future.delayed (2 a 3 segundos por defecto).
  /// - [simulateError]: Si es `true`, simula un fallo en la red o servidor arrojando una excepción.
  /// - [onLog]: Callback opcional para reflejar los logs en la interfaz además de la consola.
  Future<SimulatedReport> fetchReportData({
    Duration delay = const Duration(seconds: 2),
    bool simulateError = false,
    void Function(String message)? onLog,
  }) async {
    void log(String message) {
      // Impresión obligatoria en consola del orden de ejecución
      // ignore: avoid_print
      print(message);
      if (onLog != null) {
        onLog(message);
      }
    }

    final stopwatch = Stopwatch()..start();

    // 1. ANTES: Se anuncia la invocación antes de suspender en el await
    log(
      '[ASYNC-ORDER] 1. [ANTES]: Invocando fetchReportData(). La UI permanece libre e interactiva (Event Loop no bloqueado).',
    );

    try {
      // 2. DURANTE: Se suspende la función de forma asíncrona esperando el Future
      log(
        '[ASYNC-ORDER] 2. [DURANTE]: Esperando respuesta del servidor simulado mediante Future.delayed(${delay.inMilliseconds} ms)...',
      );

      // Espera no bloqueante
      await Future.delayed(delay);

      if (simulateError) {
        throw Exception(
          'Error 503 (Servicio no disponible): Conexión rechazada por el servidor tras ${stopwatch.elapsedMilliseconds} ms de espera.',
        );
      }

      stopwatch.stop();
      final report = SimulatedReport.sample(latencyMs: stopwatch.elapsedMilliseconds);

      // 3. DESPUÉS (Éxito): Se reanuda la ejecución tras resolverse el Future
      log(
        '[ASYNC-ORDER] 3. [DESPUÉS - ÉXITO]: Respuesta recibida en ${stopwatch.elapsedMilliseconds} ms. Datos parseados exitosamente. Actualizando estado en UI.',
      );

      return report;
    } catch (e) {
      stopwatch.stop();
      // 3. DESPUÉS (Error): Si ocurre una excepción, se captura en el catch
      log(
        '[ASYNC-ORDER] 3. [DESPUÉS - ERROR]: Fallo capturado en bloque catch tras ${stopwatch.elapsedMilliseconds} ms: $e. Notificando estado de error a la UI.',
      );
      rethrow;
    }
  }
}
