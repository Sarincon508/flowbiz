import 'package:flutter/material.dart';
import 'providers/flowbiz_controller.dart';
import 'screens/taller1_home_page.dart';
import 'services/storage_service.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();
  final controller = FlowBizController(storageService);

  runApp(FlowBizApp(controller: controller));
}

class FlowBizApp extends StatelessWidget {
  final FlowBizController controller;

  const FlowBizApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller 1 - Flutter + Widgets + Git Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: HomePage(controller: controller),
    );
  }
}

