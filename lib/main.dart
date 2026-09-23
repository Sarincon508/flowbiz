import 'package:flutter/material.dart';
import 'screens/taller1_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Taller1App());
}

class Taller1App extends StatelessWidget {
  const Taller1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller 1 - Flutter + Widgets + Git Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B365D)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const HomePage(),
    );
  }
}
