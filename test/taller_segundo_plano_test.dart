import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowbiz/screens/taller_segundo_plano_page.dart';
import 'package:flowbiz/services/async_data_service.dart';
import 'package:flowbiz/services/isolate_heavy_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Taller Segundo Plano - Unit & Service Tests', () {
    test('AsyncDataService: fetchReportData returns valid data on success and logs execution order', () async {
      final service = AsyncDataService();
      final logs = <String>[];

      final report = await service.fetchReportData(
        delay: const Duration(milliseconds: 50),
        simulateError: false,
        onLog: logs.add,
      );

      expect(report.businessName, contains('FlowBiz'));
      expect(report.totalSales, greaterThan(0));
      expect(report.netCashFlow, greaterThan(0));

      // Check execution order logs: 1-Antes, 2-Durante, 3-Después
      expect(logs.any((l) => l.contains('1. [ANTES]')), isTrue);
      expect(logs.any((l) => l.contains('2. [DURANTE]')), isTrue);
      expect(logs.any((l) => l.contains('3. [DESPUÉS - ÉXITO]')), isTrue);
    });

    test('AsyncDataService: throws simulated exception when simulateError is true', () async {
      final service = AsyncDataService();
      final logs = <String>[];

      expect(
        () => service.fetchReportData(
          delay: const Duration(milliseconds: 50),
          simulateError: true,
          onLog: logs.add,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('IsolateHeavyService: synchronous fallback computes sum correctly', () {
      final service = IsolateHeavyService();
      final result = service.runSynchronouslyOnMainThread(10000);

      expect(result.calculatedSum, isNotNull);
      expect(result.calculatedSum!, greaterThan(BigInt.zero));
      expect(result.isCompleted, isTrue);
    });
  });

  group('Taller Segundo Plano - Widget Tests', () {
    testWidgets('Renders all tabs and student credentials in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TallerSegundoPlanoPage(),
        ),
      );

      // Verify AppBar credentials
      expect(find.text('Taller: Segundo Plano en Flutter'), findsOneWidget);
      expect(find.textContaining('Samuel Rincon (230231045)'), findsOneWidget);

      // Verify 3 Tabs exist
      expect(find.text('1. Timer'), findsOneWidget);
      expect(find.text('2. Future & Async'), findsOneWidget);
      expect(find.text('3. Isolate.spawn'), findsOneWidget);
    });

    testWidgets('Tab 1 - Timer: Controls Iniciar, Pausar, Reanudar, Reiniciar work properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TallerSegundoPlanoPage(),
        ),
      );

      // Verify initial display state
      expect(find.byKey(const Key('timerDisplayKey')), findsOneWidget);
      expect(find.text('00:00.0'), findsOneWidget);
      expect(find.text('EN REPOSO'), findsOneWidget);

      // Tap Iniciar
      final btnIniciar = find.byKey(const Key('btnIniciarTimer'));
      await tester.tap(btnIniciar);
      await tester.pump();

      expect(find.text('EN EJECUCIÓN'), findsOneWidget);

      // Advance time by 300 ms (3 ticks of 100ms)
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('00:00.3'), findsOneWidget);

      // Tap Pausar
      final btnPausar = find.byKey(const Key('btnPausarTimer'));
      await tester.tap(btnPausar);
      await tester.pump();

      expect(find.text('PAUSADO'), findsOneWidget);

      // Advance time and verify it remains frozen
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('00:00.3'), findsOneWidget);

      // Tap Reanudar
      final btnReanudar = find.byKey(const Key('btnReanudarTimer'));
      await tester.tap(btnReanudar);
      await tester.pump();

      expect(find.text('EN EJECUCIÓN'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('00:00.5'), findsOneWidget);

      // Tap Reiniciar
      final btnReiniciar = find.byKey(const Key('btnReiniciarTimer'));
      await tester.tap(btnReiniciar);
      await tester.pump();

      expect(find.text('EN REPOSO'), findsOneWidget);
      expect(find.text('00:00.0'), findsOneWidget);
    });

    testWidgets('Tab 2 - Future & Async: Shows Loading and Success states', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: TallerSegundoPlanoPage(),
        ),
      );

      // Switch to Tab 2
      await tester.tap(find.text('2. Future & Async'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Initial State
      expect(find.textContaining('Presiona "Consultar Datos"'), findsOneWidget);

      // Tap Consultar Datos button
      final btnConsultar = find.byKey(const Key('btnConsultarAsync'));
      await tester.ensureVisible(btnConsultar);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(btnConsultar);
      await tester.pump(); // Enter loading state

      // Verify Loading State
      expect(find.byKey(const Key('asyncStateLoadingKey')), findsOneWidget);
      expect(find.text('Cargando datos...'), findsOneWidget);

      // Advance time by 2.5 seconds to resolve the Future.delayed
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Success State
      expect(find.byKey(const Key('asyncStateSuccessKey')), findsOneWidget);
      expect(find.textContaining('Estado: Éxito (HTTP 200)'), findsOneWidget);
      expect(find.text('FlowBiz Smart Salon & Spa'), findsOneWidget);
    });
  });
}
