import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/environment.dart';
import '../models/dashboard_card_item.dart';
import '../routes/app_router.dart';
import '../widgets/dashboard_card.dart';

/// Main Dashboard screen introducing the 4 selected API Colombia endpoints.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  List<DashboardCardItem> _getEndpoints() {
    return const [
      DashboardCardItem(
        title: 'Departamentos',
        subtitle: 'División Político-Administrativa',
        description:
            'Consulta los 32 departamentos de Colombia, sus capitales, superficie, población y prefijos telefónicos.',
        routePath: AppRouter.departmentsPath,
        routeName: AppRouter.departmentsName,
        icon: Icons.map_rounded,
        primaryColor: Color(0xFF1E3A8A), // Navy Blue
        secondaryColor: Color(0xFF3B82F6),
        endpointUrl: '/api/v1/Department',
        countBadge: '32 Dptos',
      ),
      DashboardCardItem(
        title: 'Atracciones Turísticas',
        subtitle: 'Patrimonio y Maravillas Naturales',
        description:
            'Descubre parques naturales, museos, monumentos históricos y destinos turísticos emblemáticos.',
        routePath: AppRouter.attractionsPath,
        routeName: AppRouter.attractionsName,
        icon: Icons.photo_camera_rounded,
        primaryColor: Color(0xFF047857), // Emerald Green
        secondaryColor: Color(0xFF10B981),
        endpointUrl: '/api/v1/TouristicAttraction',
        countBadge: 'Top Destinos',
      ),
      DashboardCardItem(
        title: 'Presidentes',
        subtitle: 'Historia Política Republicana',
        description:
            'Recorrido por los mandatarios de Colombia, sus partidos políticos, periodos de gobierno y biografías.',
        routePath: AppRouter.presidentsPath,
        routeName: AppRouter.presidentsName,
        icon: Icons.account_balance_rounded,
        primaryColor: Color(0xFFB45309), // Amber / Gold
        secondaryColor: Color(0xFFF59E0B),
        endpointUrl: '/api/v1/President',
        countBadge: 'Mandatarios',
      ),
      DashboardCardItem(
        title: 'Platos Típicos',
        subtitle: 'Gastronomía Tradicional Colombiana',
        description:
            'Explora la rica gastronomía colombiana, recetas autóctonas, ingredientes esenciales y sus regiones de origen.',
        routePath: AppRouter.typicalDishesPath,
        routeName: AppRouter.typicalDishesName,
        icon: Icons.restaurant_menu_rounded,
        primaryColor: Color(0xFFBE123C), // Crimson Red
        secondaryColor: Color(0xFFF43F5E),
        endpointUrl: '/api/v1/TypicalDish',
        countBadge: 'Gastronomía',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final endpoints = _getEndpoints();

    return Scaffold(
      appBar: AppBar(
        title: Text(Environment.appName),
        actions: [
          IconButton(
            tooltip: 'Acerca de la API',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header Hero Banner
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E3A8A),
                    const Color(0xFF1E40AF),
                    Colors.blue.shade900,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.public_rounded, size: 14, color: Colors.black87),
                            SizedBox(width: 4),
                            Text(
                              'API Colombia v1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '🇨🇴 Colombia',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Explorador de Datos Abiertos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acceso centralizado a información geográfica, cultural, histórica y gastronómica de la República de Colombia.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'Módulos Disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${endpoints.length} Endpoints',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Endpoints Cards List
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = endpoints[index];
                  return DashboardCard(
                    item: item,
                    onTap: () {
                      context.pushNamed(item.routeName);
                    },
                  );
                },
                childCount: endpoints.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFF1E3A8A)),
            SizedBox(width: 8),
            Text('Acerca del Taller'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Abiertos de Colombia',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Aplicación desarrollada en Flutter consumiendo la API pública oficial api-colombia.com.\n\n'
              '• Navegación modular con go_router\n'
              '• Manejo de estados (Carga, Éxito, Error)\n'
              '• Arquitectura en capas (Models, Services, Views, Widgets)\n'
              '• Variables de entorno con flutter_dotenv',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
