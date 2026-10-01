/// Modelos de datos para el Taller de Asincronía, Timer e Isolate
/// Asignatura: Electiva Profesional 1 Móviles - UCEVA
/// Estudiante: Samuel Alejandro Rincon Serna (230231045)
library;

enum AsyncRequestState {
  initial,
  loading,
  success,
  error,
}

enum TimerRunningMode {
  stopwatch('Cronómetro Progresivo'),
  countdown('Cuenta Regresiva');

  final String label;
  const TimerRunningMode(this.label);
}

enum TimerStatus {
  initial('En Reposo'),
  running('En Ejecución'),
  paused('Pausado'),
  finished('Finalizado');

  final String label;
  const TimerStatus(this.label);
}

/// Modelo que encapsula los datos retornados por el servicio asíncrono
class SimulatedReport {
  final String reportId;
  final String businessName;
  final DateTime generatedAt;
  final double totalSales;
  final double totalExpenses;
  final double netCashFlow;
  final int totalAppointments;
  final int pendingOrders;
  final double satisfactionScore;
  final int queryLatencyMs;
  final String serverRegion;
  final List<String> operationalAlerts;

  const SimulatedReport({
    required this.reportId,
    required this.businessName,
    required this.generatedAt,
    required this.totalSales,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.totalAppointments,
    required this.pendingOrders,
    required this.satisfactionScore,
    required this.queryLatencyMs,
    required this.serverRegion,
    required this.operationalAlerts,
  });

  factory SimulatedReport.sample({required int latencyMs}) {
    return SimulatedReport(
      reportId: 'REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      businessName: 'FlowBiz Smart Salon & Spa',
      generatedAt: DateTime.now(),
      totalSales: 1845000.0,
      totalExpenses: 420000.0,
      netCashFlow: 1425000.0,
      totalAppointments: 18,
      pendingOrders: 3,
      satisfactionScore: 4.9,
      queryLatencyMs: latencyMs,
      serverRegion: 'AWS Cloud (us-east-1 Bogotá Edge)',
      operationalAlerts: const [
        'Caja cuadrada con 0 descuadres detectados',
        '3 citas confirmadas para el turno vespertino',
        'Inventario de toallas y cera en umbral óptimo',
      ],
    );
  }
}

/// Mensaje estructurado que viaja entre el Isolate y el Hilo Principal (Main Thread)
class IsolateWorkerMessage {
  final String type; // 'started', 'progress', 'completed', 'error'
  final double progress; // 0.0 a 1.0
  final int progressPercent; // 0 a 100
  final int currentIteration;
  final int totalIterations;
  final BigInt? calculatedSum;
  final int? primesFound;
  final int? durationMs;
  final String message;
  final String? error;

  const IsolateWorkerMessage({
    required this.type,
    this.progress = 0.0,
    this.progressPercent = 0,
    this.currentIteration = 0,
    this.totalIterations = 0,
    this.calculatedSum,
    this.primesFound,
    this.durationMs,
    required this.message,
    this.error,
  });

  bool get isStarted => type == 'started';
  bool get isProgress => type == 'progress';
  bool get isCompleted => type == 'completed';
  bool get isError => type == 'error';
}

/// Entrada para registrar vueltas parciales en el cronómetro
class StopwatchLap {
  final int lapNumber;
  final Duration lapTime;
  final Duration totalTime;

  const StopwatchLap({
    required this.lapNumber,
    required this.lapTime,
    required this.totalTime,
  });
}
