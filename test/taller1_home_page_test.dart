import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowbiz/screens/taller1_home_page.dart';

void main() {
  testWidgets('Taller 1: HomePage renders initial state with student info and required widgets', (WidgetTester tester) async {
    // Build HomePage
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    // 1. Verify initial AppBar title is "Hola, Flutter"
    expect(find.text('Hola, Flutter'), findsOneWidget);

    // 2. Verify student full name and code are present and centered
    expect(find.text('Samuel Alejandro Rincon Serna'), findsOneWidget);
    expect(find.text('Código: 230231045'), findsOneWidget);

    // 3. Verify presence of Image.network and Image.asset widgets
    expect(find.byType(Image), findsAtLeast(2));

    // 4. Verify presence of Container, Stack, and ListView
    expect(find.byType(Container), findsWidgets);
    expect(find.byType(Stack), findsWidgets);
    expect(find.byType(ListView), findsOneWidget);

    // 5. Verify presence of toggle button
    final toggleButton = find.byKey(const Key('toggleTitleButtonKey'));
    expect(toggleButton, findsOneWidget);
  });

  testWidgets('Taller 1: ElevatedButton toggles AppBar title with setState and displays SnackBar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    // Initial title
    expect(find.text('Hola, Flutter'), findsOneWidget);
    expect(find.text('¡Título cambiado!'), findsNothing);

    // Tap toggle button
    final toggleButton = find.byKey(const Key('toggleTitleButtonKey'));
    await tester.tap(toggleButton);
    await tester.pump(); // Start animation / setState

    // Verify AppBar title changed to "¡Título cambiado!"
    expect(find.text('¡Título cambiado!'), findsOneWidget);

    // Pump to show SnackBar
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Título actualizado'), findsOneWidget);

    // Tap toggle button again to verify toggling back
    await tester.tap(toggleButton);
    await tester.pump();

    // Verify title restored to "Hola, Flutter"
    expect(find.text('Hola, Flutter'), findsOneWidget);
    expect(find.text('¡Título cambiado!'), findsNothing);
  });
}
