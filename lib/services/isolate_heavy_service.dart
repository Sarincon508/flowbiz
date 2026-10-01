import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/async_task_models.dart';

/// Función de nivel superior que actúa como punto de entrada para `Isolate.spawn`.
/// Al ejecutarse en un Isolate independiente, cuenta con su propio espacio de memoria (heap)
/// y no bloquea el hilo principal (Main Thread) de la interfaz de usuario de Flutter.
@pragma('vm:entry-point')
void _heavyComputationWorker(Map<String, dynamic> params) {
  final SendPort sendPort = params['sendPort'] as SendPort;
  final int totalIterations = params['iterations'] as int;

  // ignore: avoid_print
  print('[ISOLATE-WORKER] 1. Hilo secundario Isolate iniciado con su propio espacio de memoria.');
  // ignore: avoid_print
  print('[ISOLATE-WORKER] 2. Comenzando computación CPU-bound de $totalIterations iteraciones...');

  sendPort.send(
    IsolateWorkerMessage(
      type: 'started',
      progress: 0.0,
      progressPercent: 0,
      totalIterations: totalIterations,
      message: 'Worker Isolate iniciado. Procesando $totalIterations operaciones intensivas.',
    ),
  );

  final stopwatch = Stopwatch()..start();
  BigInt sum = BigInt.zero;
  int primesFound = 0;

  // Determinar intervalos para reportar progreso sin saturar el canal de mensajes
  final int step = (totalIterations / 4).round().clamp(1, totalIterations);

  for (int i = 1; i <= totalIterations; i++) {
    // Tarea CPU-bound 1: Sumatoria ponderada de gran volumen
    sum += BigInt.from(i);

    // Tarea CPU-bound 2: Verificación de números primos en rango
    if (i <= 150000 && _isPrime(i)) {
      primesFound++;
    }

    // Emitir reporte periódico de progreso (cada 25%)
    if (i % step == 0 || i == totalIterations) {
      final int percent = ((i / totalIterations) * 100).round();
      // ignore: avoid_print
      print('[ISOLATE-WORKER] Progreso de cómputo: $percent% ($i/$totalIterations operaciones)');

      sendPort.send(
        IsolateWorkerMessage(
          type: 'progress',
          progress: i / totalIterations,
          progressPercent: percent,
          currentIteration: i,
          totalIterations: totalIterations,
          message: 'Progreso de cómputo: $percent% completado...',
        ),
      );
    }
  }

  stopwatch.stop();

  // ignore: avoid_print
  print(
    '[ISOLATE-WORKER] 3. Cómputo CPU finalizado en ${stopwatch.elapsedMilliseconds} ms. Enviando resultado final al ReceivePort del hilo principal...',
  );

  sendPort.send(
    IsolateWorkerMessage(
      type: 'completed',
      progress: 1.0,
      progressPercent: 100,
      currentIteration: totalIterations,
      totalIterations: totalIterations,
      calculatedSum: sum,
      primesFound: primesFound,
      durationMs: stopwatch.elapsedMilliseconds,
      message:
          'Cálculo intensivo completado con éxito en ${stopwatch.elapsedMilliseconds} ms.',
    ),
  );
}

/// Función auxiliar para determinar primalidad de forma intensiva
bool _isPrime(int n) {
  if (n <= 1) return false;
  if (n <= 3) return true;
  if (n % 2 == 0 || n % 3 == 0) return false;
  for (int i = 5; i * i <= n; i += 6) {
    if (n % i == 0 || n % (i + 2) == 0) return false;
  }
  return true;
}

/// Servicio que gestiona la creación, supervisión y comunicación con el Isolate
/// mediante [Isolate.spawn], [ReceivePort] y [SendPort].
class IsolateHeavyService {
  Isolate? _isolate;
  ReceivePort? _receivePort;

  bool get isRunning => _isolate != null;

  /// Ejecuta una tarea intensiva en segundo plano utilizando `Isolate.spawn`
  Future<void> runHeavyTaskWithIsolate({
    required int iterations,
    required void Function(IsolateWorkerMessage) onMessage,
    required void Function(String error) onError,
    void Function(String consoleLog)? onLog,
  }) async {
    // Cancelar cualquier Isolate previo para liberar memoria
    cancel();

    void log(String message) {
      // ignore: avoid_print
      print(message);
      if (onLog != null) {
        onLog(message);
      }
    }

    _receivePort = ReceivePort();

    log(
      '[ISOLATE-MAIN] 1. [Main Thread]: Creando ReceivePort para comunicación bidireccional.',
    );
    log(
      '[ISOLATE-MAIN] 2. [Main Thread]: Invocando Isolate.spawn() para crear un nuevo hilo de ejecución...',
    );

    final Map<String, dynamic> params = {
      'sendPort': _receivePort!.sendPort,
      'iterations': iterations,
    };

    if (kIsWeb) {
      log('[ISOLATE-MAIN] 1. [Entorno Web]: En Web se emplea emulación asíncrona no bloqueante (Isolate.spawn requiere Dart VM nativo).');
      final stopwatch = Stopwatch()..start();
      onMessage(IsolateWorkerMessage(
        type: 'started',
        totalIterations: iterations,
        message: 'Worker iniciado en segundo plano. Procesando $iterations operaciones.',
      ));

      BigInt sum = BigInt.zero;
      int primesFound = 0;
      final step = (iterations / 4).round().clamp(1, iterations);

      for (int i = 1; i <= iterations; i++) {
        sum += BigInt.from(i);
        if (i <= 150000 && _isPrime(i)) {
          primesFound++;
        }

        if (i % step == 0 || i == iterations) {
          final int percent = ((i / iterations) * 100).round();
          await Future.delayed(const Duration(milliseconds: 10)); // Cede tiempo al bucle de eventos
          log('[ISOLATE-WORKER] Progreso de cómputo: $percent% ($i/$iterations operaciones)');
          onMessage(IsolateWorkerMessage(
            type: 'progress',
            progress: i / iterations,
            progressPercent: percent,
            currentIteration: i,
            totalIterations: iterations,
            message: 'Progreso de cómputo: $percent% completado...',
          ));
        }
      }

      stopwatch.stop();
      log('[ISOLATE-MAIN] Cómputo finalizado en ${stopwatch.elapsedMilliseconds} ms.');
      onMessage(IsolateWorkerMessage(
        type: 'completed',
        progress: 1.0,
        progressPercent: 100,
        currentIteration: iterations,
        totalIterations: iterations,
        calculatedSum: sum,
        primesFound: primesFound,
        durationMs: stopwatch.elapsedMilliseconds,
        message: 'Cálculo intensivo completado con éxito en ${stopwatch.elapsedMilliseconds} ms.',
      ));
      return;
    }

    try {
      _isolate = await Isolate.spawn<Map<String, dynamic>>(
        _heavyComputationWorker,
        params,
        onError: _receivePort!.sendPort,
      );

      log(
        '[ISOLATE-MAIN] 3. [Main Thread]: Isolate creado y activo. La interfaz (UI) continúa corriendo a 60 FPS sin bloqueos.',
      );

      _receivePort!.listen((dynamic message) {
        if (message is IsolateWorkerMessage) {
          log(
            '[ISOLATE-MAIN] Mensaje recibido en ReceivePort (${message.type}): ${message.message}',
          );
          onMessage(message);

          if (message.isCompleted) {
            log(
              '[ISOLATE-MAIN] 4. [Main Thread]: Cómputo recibido satisfactoriamente (Suma: ${message.calculatedSum}, Primos: ${message.primesFound}, Tiempo: ${message.durationMs}ms).',
            );
            // Liberar recursos
            cancel();
          }
        } else if (message is List && message.isNotEmpty) {
          // Errores no capturados del Isolate recibidos por onError port
          final errorStr = message[0].toString();
          log('[ISOLATE-MAIN] Error recibido desde el Isolate: $errorStr');
          onError(errorStr);
          cancel();
        }
      });
    } catch (e) {
      log('[ISOLATE-MAIN] Error al invocar Isolate.spawn(): $e');
      onError(e.toString());
      cancel();
    }
  }

  /// Cancela la ejecución del Isolate activo y cierra el puerto de escucha
  void cancel() {
    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }
    if (_receivePort != null) {
      _receivePort!.close();
      _receivePort = null;
    }
    // ignore: avoid_print
    print('[ISOLATE-MAIN] Recursos de Isolate y ReceivePort liberados.');
  }

  /// Ejecuta la tarea síncronamente en el hilo principal (Main Thread).
  /// Esta función demuestra el congelamiento total de la UI cuando NO se usa Isolate.
  IsolateWorkerMessage runSynchronouslyOnMainThread(int totalIterations) {
    // ignore: avoid_print
    print(
      '[MAIN-THREAD-BLOCK] Iniciando tarea pesada en el HILO PRINCIPAL. ¡La UI se congelará!',
    );
    final stopwatch = Stopwatch()..start();
    BigInt sum = BigInt.zero;
    int primesFound = 0;

    for (int i = 1; i <= totalIterations; i++) {
      sum += BigInt.from(i);
      if (i <= 150000 && _isPrime(i)) {
        primesFound++;
      }
    }

    stopwatch.stop();
    // ignore: avoid_print
    print(
      '[MAIN-THREAD-BLOCK] Tarea en hilo principal terminada en ${stopwatch.elapsedMilliseconds} ms.',
    );

    return IsolateWorkerMessage(
      type: 'completed',
      progress: 1.0,
      progressPercent: 100,
      currentIteration: totalIterations,
      totalIterations: totalIterations,
      calculatedSum: sum,
      primesFound: primesFound,
      durationMs: stopwatch.elapsedMilliseconds,
      message:
          'Ejecución síncrona en hilo principal finalizada en ${stopwatch.elapsedMilliseconds} ms (La UI estuvo congelada).',
    );
  }
}
