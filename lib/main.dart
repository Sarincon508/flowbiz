import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'routes/app_router.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar variables de entorno para Taller 4 (Datos Abiertos de Colombia)
  await Environment.init();

  runApp(const FlowbizTaller4App());
}

/// Aplicación principal para la rama taller_4 en el repositorio FlowBiz.
class FlowbizTaller4App extends StatelessWidget {
  const FlowbizTaller4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Environment.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
