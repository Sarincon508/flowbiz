import 'package:flutter/material.dart';
import 'screens/taller_segundo_plano_page.dart';
import 'screens/taller1_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TallerSegundoPlanoApp());
}

class TallerSegundoPlanoApp extends StatelessWidget {
  const TallerSegundoPlanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller Asincronía, Timer e Isolate - UCEVA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B365D),
          primary: const Color(0xFF1B365D),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const TallerNavigationWrapper(),
    );
  }
}

/// Envoltura de navegación que permite al evaluador alternar fácilmente
/// entre el Taller 2 (Segundo Plano: Timer, Future, Isolate) y el Taller 1 (Widgets).
class TallerNavigationWrapper extends StatefulWidget {
  const TallerNavigationWrapper({super.key});

  @override
  State<TallerNavigationWrapper> createState() => _TallerNavigationWrapperState();
}

class _TallerNavigationWrapperState extends State<TallerNavigationWrapper> {
  int _currentTallerIndex = 0;

  final List<Widget> _talleres = const [
    TallerSegundoPlanoPage(),
    HomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _talleres[_currentTallerIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTallerIndex,
        onDestinationSelected: (idx) => setState(() => _currentTallerIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt, color: Color(0xFF1B365D)),
            label: 'Taller 2: Segundo Plano',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            selectedIcon: Icon(Icons.widgets, color: Color(0xFF1B365D)),
            label: 'Taller 1: Widgets',
          ),
        ],
      ),
    );
  }
}
