import 'dart:async';
import 'package:flutter/material.dart';
import '../models/async_task_models.dart';
import '../services/async_data_service.dart';
import '../services/isolate_heavy_service.dart';

/// Pantalla Principal del Taller de Asincronía, Timer e Isolate
/// Demuestra:
/// 1. Asincronía con Future, async y await (Estados: Cargando, Éxito, Error)
/// 2. Timer: Cronómetro y Cuenta regresiva (Iniciar, Pausar, Reanudar, Reiniciar)
/// 3. Isolate.spawn: Tarea pesada CPU-bound sin congelar la UI
///
/// Estudiante: Samuel Alejandro Rincon Serna (230231045)
/// Institución: Unidad Central del Valle del Cauca (UCEVA)
/// Asignatura: Electiva Profesional 1 Móviles
class TallerSegundoPlanoPage extends StatefulWidget {
  const TallerSegundoPlanoPage({super.key});

  @override
  State<TallerSegundoPlanoPage> createState() => _TallerSegundoPlanoPageState();
}

class _TallerSegundoPlanoPageState extends State<TallerSegundoPlanoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // ==========================================
  // ESTADO - SECCIÓN 1: TIMER (CRONÓMETRO)
  // ==========================================
  Timer? _timer;
  int _elapsedMilliseconds = 0;
  TimerStatus _timerStatus = TimerStatus.initial;
  TimerRunningMode _timerMode = TimerRunningMode.stopwatch;
  final int _countdownStartSeconds = 30;
  final List<StopwatchLap> _laps = [];
  Duration _lastLapTime = Duration.zero;

  // ==========================================
  // ESTADO - SECCIÓN 2: ASINCRONÍA (FUTURE)
  // ==========================================
  final AsyncDataService _asyncDataService = AsyncDataService();
  AsyncRequestState _asyncState = AsyncRequestState.initial;
  SimulatedReport? _simulatedReport;
  String? _asyncErrorMessage;
  double _asyncDelaySeconds = 2.5;
  bool _simulateError = false;
  int _asyncUiTapCount = 0; // Para demostrar que la UI no se bloquea
  final List<String> _asyncConsoleLogs = [];

  // ==========================================
  // ESTADO - SECCIÓN 3: ISOLATE (TAREA PESADA)
  // ==========================================
  final IsolateHeavyService _isolateService = IsolateHeavyService();
  int _isolateIterations = 30000000; // 30 Millones por defecto
  bool _isIsolateRunning = false;
  double _isolateProgress = 0.0;
  int _isolateProgressPercent = 0;
  String _isolateStatusMessage = 'Listo para iniciar cómputo con Isolate.spawn';
  BigInt? _isolateCalculatedSum;
  int? _isolatePrimesFound;
  int? _isolateElapsedMs;
  int _isolateUiTapCount = 0; // Para probar reactividad a 60 FPS
  final List<String> _isolateMessageFeed = [];

  // Animación para probar si la UI se congela
  late AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    // Limpieza obligatoria de recursos para evitar fugas de memoria
    _timer?.cancel();
    _timer = null;
    _isolateService.cancel();
    _tabController.dispose();
    _spinnerController.dispose();
    // ignore: avoid_print
    print('[LIFECYCLE] Recursos de Timer e Isolate liberados exitosamente en dispose().');
    super.dispose();
  }

  // ===========================================================================
  // MÉTODOS - SECCIÓN 1: TIMER
  // ===========================================================================

  void _iniciarTimer() {
    if (_timer != null) return;

    if (_timerMode == TimerRunningMode.countdown && _elapsedMilliseconds == 0) {
      _elapsedMilliseconds = _countdownStartSeconds * 1000;
    }

    setState(() {
      _timerStatus = TimerStatus.running;
    });

    // Actualización periódica cada 100 ms (décimas de segundo)
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      setState(() {
        if (_timerMode == TimerRunningMode.stopwatch) {
          _elapsedMilliseconds += 100;
        } else {
          // Modo Cuenta Regresiva
          if (_elapsedMilliseconds > 100) {
            _elapsedMilliseconds -= 100;
          } else {
            _elapsedMilliseconds = 0;
            _timer?.cancel();
            _timer = null;
            _timerStatus = TimerStatus.finished;
            _mostrarAlertaCountdownFinalizado();
          }
        }
      });
    });

    // ignore: avoid_print
    print('[Timer] Timer iniciado a una frecuencia de 100ms. Estado: $_timerStatus');
  }

  void _pausarTimer() {
    if (_timer == null) return;

    _timer?.cancel();
    _timer = null;

    setState(() {
      _timerStatus = TimerStatus.paused;
    });

    // ignore: avoid_print
    print('[Timer] Timer pausado. Tiempo retenido: ${_formatearTiempo(_elapsedMilliseconds)}');
  }

  void _reanudarTimer() {
    if (_timerStatus != TimerStatus.paused) return;
    _iniciarTimer();
    // ignore: avoid_print
    print('[Timer] Timer reanudado desde: ${_formatearTiempo(_elapsedMilliseconds)}');
  }

  void _reiniciarTimer() {
    _timer?.cancel();
    _timer = null;

    setState(() {
      _timerStatus = TimerStatus.initial;
      _elapsedMilliseconds =
          _timerMode == TimerRunningMode.stopwatch
              ? 0
              : _countdownStartSeconds * 1000;
      _laps.clear();
      _lastLapTime = Duration.zero;
    });

    // ignore: avoid_print
    print('[Timer] Timer reiniciado a estado inicial.');
  }

  void _registrarVuelta() {
    if (_timerStatus != TimerStatus.running) return;

    final currentTotal = Duration(milliseconds: _elapsedMilliseconds);
    final lapDiff = currentTotal - _lastLapTime;
    _lastLapTime = currentTotal;

    setState(() {
      _laps.insert(
        0,
        StopwatchLap(
          lapNumber: _laps.length + 1,
          lapTime: lapDiff,
          totalTime: currentTotal,
        ),
      );
    });
  }

  void _cambiarModoTimer(TimerRunningMode nuevoModo) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    setState(() {
      _timerMode = nuevoModo;
      _timerStatus = TimerStatus.initial;
      _elapsedMilliseconds =
          nuevoModo == TimerRunningMode.stopwatch
              ? 0
              : _countdownStartSeconds * 1000;
      _laps.clear();
      _lastLapTime = Duration.zero;
    });
  }

  void _mostrarAlertaCountdownFinalizado() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.alarm_on, color: Colors.white),
            SizedBox(width: 10),
            Text(
              '¡Cuenta regresiva completada!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatearTiempo(int totalMs) {
    final int hours = totalMs ~/ 3600000;
    final int minutes = (totalMs % 3600000) ~/ 60000;
    final int seconds = (totalMs % 60000) ~/ 1000;
    final int tenths = (totalMs % 1000) ~/ 100;

    final String hStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    final String mStr = minutes.toString().padLeft(2, '0');
    final String sStr = seconds.toString().padLeft(2, '0');
    final String tStr = tenths.toString();

    return '$hStr$mStr:$sStr.$tStr';
  }

  // ===========================================================================
  // MÉTODOS - SECCIÓN 2: ASINCRONÍA (FUTURE / ASYNC / AWAIT)
  // ===========================================================================

  Future<void> _ejecutarConsultaAsincrona() async {
    setState(() {
      _asyncState = AsyncRequestState.loading;
      _simulatedReport = null;
      _asyncErrorMessage = null;
      _asyncConsoleLogs.clear();
    });

    void appendLog(String msg) {
      if (mounted) {
        setState(() {
          _asyncConsoleLogs.add(msg);
        });
      }
    }

    try {
      final report = await _asyncDataService.fetchReportData(
        delay: Duration(milliseconds: (_asyncDelaySeconds * 1000).toInt()),
        simulateError: _simulateError,
        onLog: appendLog,
      );

      if (!mounted) return;
      setState(() {
        _asyncState = AsyncRequestState.success;
        _simulatedReport = report;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _asyncState = AsyncRequestState.error;
        _asyncErrorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ===========================================================================
  // MÉTODOS - SECCIÓN 3: ISOLATE (TAREA PESADA CPU-BOUND)
  // ===========================================================================

  Future<void> _ejecutarConIsolate() async {
    setState(() {
      _isIsolateRunning = true;
      _isolateProgress = 0.0;
      _isolateProgressPercent = 0;
      _isolateCalculatedSum = null;
      _isolatePrimesFound = null;
      _isolateElapsedMs = null;
      _isolateStatusMessage = 'Iniciando Isolate.spawn...';
      _isolateMessageFeed.clear();
    });

    void appendLog(String log) {
      if (mounted) {
        setState(() {
          _isolateMessageFeed.add(log);
        });
      }
    }

    await _isolateService.runHeavyTaskWithIsolate(
      iterations: _isolateIterations,
      onLog: appendLog,
      onMessage: (msg) {
        if (!mounted) return;
        setState(() {
          _isolateProgress = msg.progress;
          _isolateProgressPercent = msg.progressPercent;
          _isolateStatusMessage = msg.message;

          if (msg.isCompleted) {
            _isIsolateRunning = false;
            _isolateCalculatedSum = msg.calculatedSum;
            _isolatePrimesFound = msg.primesFound;
            _isolateElapsedMs = msg.durationMs;
          }
        });
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isIsolateRunning = false;
          _isolateStatusMessage = 'Error en Isolate: $err';
        });
      },
    );
  }

  void _ejecutarSincronoEnMainThread() {
    // Alerta previa para explicar qué ocurrirá
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Demostración de Bloqueo'),
          ],
        ),
        content: const Text(
          'Esta prueba ejecutará el cómputo intensivo DIRECTAMENTE en el hilo principal (Main Thread) '
          'sin utilizar Isolate. Podrás notar que la animación rotatoria se CONGELA por completo y la UI no '
          'responderá a toques hasta que termine.\n\n¿Deseas continuar para comparar el comportamiento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade100),
            onPressed: () {
              Navigator.of(ctx).pop();
              _ejecutarBloqueoMainThread();
            },
            child: const Text('Ejecutar y Congelar UI'),
          ),
        ],
      ),
    );
  }

  void _ejecutarBloqueoMainThread() {
    setState(() {
      _isIsolateRunning = true;
      _isolateStatusMessage = 'Ejecutando en Main Thread (UI CONGELADA)...';
      _isolateCalculatedSum = null;
      _isolatePrimesFound = null;
      _isolateElapsedMs = null;
    });

    // Pequeño delay de 50ms para que la UI pinte el texto antes del bloqueo síncrono
    Future.delayed(const Duration(milliseconds: 50), () {
      final result = _isolateService.runSynchronouslyOnMainThread(_isolateIterations);
      if (!mounted) return;
      setState(() {
        _isIsolateRunning = false;
        _isolateProgress = 1.0;
        _isolateProgressPercent = 100;
        _isolateCalculatedSum = result.calculatedSum;
        _isolatePrimesFound = result.primesFound;
        _isolateElapsedMs = result.durationMs;
        _isolateStatusMessage = result.message;
        _isolateMessageFeed.add('[MAIN-THREAD] Tarea CPU finalizada en el hilo de UI.');
      });
    });
  }

  void _cancelarIsolate() {
    _isolateService.cancel();
    setState(() {
      _isIsolateRunning = false;
      _isolateStatusMessage = 'Isolate cancelado por el usuario.';
      _isolateMessageFeed.add('[ISOLATE] Isolate cancelado inmediatamente.');
    });
  }

  // ===========================================================================
  // CONSTRUCCIÓN DE LA INTERFAZ (BUILD)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B365D); // UCEVA Navy

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taller: Segundo Plano en Flutter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              'Future • Timer • Isolate.spawn | Samuel Rincon (230231045)',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.timer_outlined), text: '1. Timer'),
            Tab(icon: Icon(Icons.cloud_sync_outlined), text: '2. Future & Async'),
            Tab(icon: Icon(Icons.memory_outlined), text: '3. Isolate.spawn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimerTab(primaryColor),
          _buildAsyncFutureTab(primaryColor),
          _buildIsolateTab(primaryColor),
        ],
      ),
    );
  }

  // ===========================================================================
  // VISTA TAB 1: TIMER (CRONÓMETRO Y CUENTA REGRESIVA)
  // ===========================================================================

  Widget _buildTimerTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de contexto institucional y técnico
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: const Color(0xFFF1F5F9),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Uso de Timer.periodic() con actualización cada 100 ms. '
                      'Garantiza cancelación al pausar y en dispose() para evitar fugas de memoria.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Selector de modo: Cronómetro Progresivo vs Cuenta Regresiva
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('⏱️ Cronómetro'),
                selected: _timerMode == TimerRunningMode.stopwatch,
                onSelected: (selected) {
                  if (selected) _cambiarModoTimer(TimerRunningMode.stopwatch);
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('⏳ Cuenta Regresiva (30s)'),
                selected: _timerMode == TimerRunningMode.countdown,
                onSelected: (selected) {
                  if (selected) _cambiarModoTimer(TimerRunningMode.countdown);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Marcador Digital Gigante (Scoreboard Style)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: const Color(0xFF334155), width: 1.5),
            ),
            child: Column(
              children: [
                // Estado actual del Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _obtenerColorEstadoTimer().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _obtenerColorEstadoTimer()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _obtenerColorEstadoTimer(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timerStatus.label.toUpperCase(),
                        style: TextStyle(
                          color: _obtenerColorEstadoTimer(),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tiempo formateado estilo LED
                Text(
                  _formatearTiempo(_elapsedMilliseconds),
                  key: const Key('timerDisplayKey'),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF38BDF8),
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _timerMode == TimerRunningMode.stopwatch
                      ? 'MINUTOS : SEGUNDOS . DÉCIMAS'
                      : 'TIEMPO RESTANTE ESTIMADO',
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botonera de Control: Iniciar / Pausar / Reanudar / Reiniciar
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              // Botón Iniciar
              ElevatedButton.icon(
                key: const Key('btnIniciarTimer'),
                onPressed: _timerStatus == TimerStatus.initial ||
                        _timerStatus == TimerStatus.finished
                    ? _iniciarTimer
                    : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Iniciar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              // Botón Pausar
              ElevatedButton.icon(
                key: const Key('btnPausarTimer'),
                onPressed: _timerStatus == TimerStatus.running ? _pausarTimer : null,
                icon: const Icon(Icons.pause_rounded),
                label: const Text('Pausar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              // Botón Reanudar
              ElevatedButton.icon(
                key: const Key('btnReanudarTimer'),
                onPressed: _timerStatus == TimerStatus.paused ? _reanudarTimer : null,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Reanudar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              // Botón Reiniciar
              OutlinedButton.icon(
                key: const Key('btnReiniciarTimer'),
                onPressed: _timerStatus != TimerStatus.initial ? _reiniciarTimer : null,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reiniciar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              // Botón Vuelta (Solo para cronómetro)
              if (_timerMode == TimerRunningMode.stopwatch)
                TextButton.icon(
                  onPressed: _timerStatus == TimerStatus.running ? _registrarVuelta : null,
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Vuelta'),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Historial de Vueltas (Laps)
          if (_laps.isNotEmpty) ...[
            const Text(
              'Vueltas Registradas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _laps.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final lap = _laps[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: primaryColor,
                      child: Text(
                        '#${lap.lapNumber}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      'Vuelta: ${_formatearTiempo(lap.lapTime.inMilliseconds)}',
                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      'Total: ${_formatearTiempo(lap.totalTime.inMilliseconds)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _obtenerColorEstadoTimer() {
    switch (_timerStatus) {
      case TimerStatus.initial:
        return const Color(0xFF94A3B8);
      case TimerStatus.running:
        return const Color(0xFF4ADE80);
      case TimerStatus.paused:
        return const Color(0xFFFBBF24);
      case TimerStatus.finished:
        return const Color(0xFFF87171);
    }
  }

  // ===========================================================================
  // VISTA TAB 2: ASINCRONÍA CON FUTURE, ASYNC Y AWAIT
  // ===========================================================================

  Widget _buildAsyncFutureTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de Explicación Conceptual
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt, color: Colors.amber.shade800, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Petición Asíncrona con Future.delayed',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Simula una consulta de red remota a FlowBiz Cloud. El uso de async/await '
                    'permite suspender la función sin detener el Event Loop de Flutter, '
                    'manteniendo la interfaz totalmente reactiva a interacciones.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Controles de Configuración de la Solicitud
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiempo de retardo: ${_asyncDelaySeconds.toStringAsFixed(1)} s',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        '${(_asyncDelaySeconds * 1000).toInt()} ms',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Slider(
                    value: _asyncDelaySeconds,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    label: '${_asyncDelaySeconds.toStringAsFixed(1)}s',
                    onChanged: _asyncState == AsyncRequestState.loading
                        ? null
                        : (val) => setState(() => _asyncDelaySeconds = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Simular Fallo / Error de Servidor',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Lanza una excepción para verificar el estado de Error y captura en catch',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: _simulateError,
                    activeThumbColor: Colors.red,
                    onChanged: _asyncState == AsyncRequestState.loading
                        ? null
                        : (val) => setState(() => _simulateError = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Botón Principal de Petición Asíncrona
          ElevatedButton.icon(
            key: const Key('btnConsultarAsync'),
            onPressed: _asyncState == AsyncRequestState.loading
                ? null
                : _ejecutarConsultaAsincrona,
            icon: _asyncState == AsyncRequestState.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_download_outlined),
            label: Text(
              _asyncState == AsyncRequestState.loading
                  ? 'Consultando Servidor...'
                  : 'Consultar Datos con async / await',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),

          // Probador de Reactividad en la UI (demuestra que la UI no se congela)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                RotationTransition(
                  turns: _spinnerController,
                  child: const Icon(Icons.sync, color: Color(0xFF0284C7), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prueba de UI Viva (Event Loop Libre)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        'Toca el botón mientras se ejecuta la consulta para verificar 0 bloqueos: Clicks: $_asyncUiTapCount',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _asyncUiTapCount++),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text('¡Tocar!'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // RENDERIZADO CONDICIONAL DE LOS 3 ESTADOS: CARGANDO / ÉXITO / ERROR
          _buildAsyncStateContent(primaryColor),
          const SizedBox(height: 16),

          // Visualizador de Consola en Pantalla (Imprime el orden 1-Antes, 2-Durante, 3-Después)
          if (_asyncConsoleLogs.isNotEmpty) ...[
            const Text(
              'Terminal de Ejecución Asíncrona (Orden de Flujo)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _asyncConsoleLogs.map((log) {
                  Color logColor = const Color(0xFF38BDF8);
                  if (log.contains('ANTES')) logColor = const Color(0xFFFBBF24);
                  if (log.contains('DURANTE')) logColor = const Color(0xFFA78BFA);
                  if (log.contains('ÉXITO')) logColor = const Color(0xFF4ADE80);
                  if (log.contains('ERROR')) logColor = const Color(0xFFF87171);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: logColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construye el widget específico según el estado actual de la petición
  Widget _buildAsyncStateContent(Color primaryColor) {
    switch (_asyncState) {
      case AsyncRequestState.initial:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(Icons.touch_app_outlined, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              const Text(
                'Presiona "Consultar Datos" para iniciar la simulación',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Se mostrarán los estados: Cargando... ➔ Éxito o Error',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        );

      case AsyncRequestState.loading:
        return Container(
          key: const Key('asyncStateLoadingKey'),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const CircularProgressIndicator(
                strokeWidth: 3.5,
                color: Color(0xFF0284C7),
              ),
              const SizedBox(height: 18),
              const Text(
                'Cargando datos...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Esperando respuesta asíncrona (${_asyncDelaySeconds.toStringAsFixed(1)} segundos con Future.delayed)...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        );

      case AsyncRequestState.success:
        final r = _simulatedReport!;
        return Container(
          key: const Key('asyncStateSuccessKey'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF16A34A)),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Estado: Éxito (HTTP 200)',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${r.queryLatencyMs} ms',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                r.businessName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                'Reporte: ${r.reportId} • ${r.serverRegion}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'Ventas Totales',
                      '\$${r.totalSales.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      'Flujo Neto',
                      '\$${r.netCashFlow.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'Citas Agendadas',
                      '${r.totalAppointments} citas',
                      Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      'Satisfacción',
                      '⭐ ${r.satisfactionScore} / 5.0',
                      Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case AsyncRequestState.error:
        return Container(
          key: const Key('asyncStateErrorKey'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF4444)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Estado: Error Capturado',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _asyncErrorMessage ?? 'Ha ocurrido un error inesperado.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: _ejecutarConsultaAsincrona,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: const Color(0xFF991B1B),
                  ),
                  child: const Text('Reintentar Consulta'),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VISTA TAB 3: TAREA PESADA CON ISOLATE (ISOLATE.SPAWN)
  // ===========================================================================

  Widget _buildIsolateTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Explicativo de Arquitectura
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.developer_board, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Aislamiento de Cómputo con Isolate.spawn',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Dart es mono-hilo con un bucle de eventos. Tareas intensivas en CPU '
                    'bloquean el renderizado a 60 FPS si se corren en el hilo principal. '
                    'Isolate.spawn crea un hilo secundario con memoria independiente que '
                    'se comunica mediante puertos (SendPort / ReceivePort).',
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Configuración de la Carga de Trabajo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Volumen de Operaciones CPU-Bound:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('15 Millones'),
                      selected: _isolateIterations == 15000000,
                      onSelected: _isIsolateRunning
                          ? null
                          : (s) {
                              if (s) setState(() => _isolateIterations = 15000000);
                            },
                    ),
                    ChoiceChip(
                      label: const Text('30 Millones'),
                      selected: _isolateIterations == 30000000,
                      onSelected: _isIsolateRunning
                          ? null
                          : (s) {
                              if (s) setState(() => _isolateIterations = 30000000);
                            },
                    ),
                    ChoiceChip(
                      label: const Text('50 Millones'),
                      selected: _isolateIterations == 50000000,
                      onSelected: _isIsolateRunning
                          ? null
                          : (s) {
                              if (s) setState(() => _isolateIterations = 50000000);
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Probador de Fluidez de UI en tiempo real
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                RotationTransition(
                  turns: _spinnerController,
                  child: const Icon(
                    Icons.slow_motion_video_rounded,
                    color: Color(0xFF2563EB),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monitor de Fluidez a 60 FPS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        'Si el engranaje gira fluido, el hilo UI está libre. Clicks registrados: $_isolateUiTapCount',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _isolateUiTapCount++),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text('¡Probar UI!'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botones de Ejecución (Isolate vs Main Thread)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  key: const Key('btnEjecutarIsolate'),
                  onPressed: _isIsolateRunning ? null : _ejecutarConIsolate,
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text(
                    'Ejecutar con Isolate.spawn',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_isIsolateRunning)
                IconButton.filled(
                  onPressed: _cancelarIsolate,
                  icon: const Icon(Icons.stop_circle_outlined),
                  color: Colors.white,
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                  tooltip: 'Cancelar Isolate',
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Botón comparativo de bloqueo voluntario del hilo principal
          OutlinedButton.icon(
            onPressed: _isIsolateRunning ? null : _ejecutarSincronoEnMainThread,
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            label: const Text(
              'Comparar: Ejecutar en Main Thread (Bloquea UI)',
              style: TextStyle(color: Colors.deepOrange),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          // Panel de Progreso y Resultados
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estado del Proceso',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      '$_isolateProgressPercent%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _isIsolateRunning ? _isolateProgress : (_isolateProgressPercent == 100 ? 1.0 : 0.0),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF0284C7),
                ),
                const SizedBox(height: 10),
                Text(
                  _isolateStatusMessage,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),

                // Tarjeta de Resultados Computados
                if (_isolateCalculatedSum != null) ...[
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Resultado Computado por el Isolate',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Sumatoria calculada: $_isolateCalculatedSum',
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                        Text(
                          '• Primos verificados: $_isolatePrimesFound',
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                        Text(
                          '• Tiempo transcurrido en segundo plano: ${_isolateElapsedMs ?? 0} ms',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Feed de Mensajes Recibidos vía ReceivePort
          if (_isolateMessageFeed.isNotEmpty) ...[
            const Text(
              'Mensajes Inter-Hilos (ReceivePort / SendPort)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _isolateMessageFeed.map((msg) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      msg,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
