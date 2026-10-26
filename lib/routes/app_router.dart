import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/department_model.dart';
import '../models/president_model.dart';
import '../models/touristic_attraction_model.dart';
import '../models/typical_dish_model.dart';
import '../views/attractions/attraction_detail_view.dart';
import '../views/attractions/attractions_list_view.dart';
import '../views/dashboard_view.dart';
import '../views/departments/department_detail_view.dart';
import '../views/departments/departments_list_view.dart';
import '../views/presidents/president_detail_view.dart';
import '../views/presidents/presidents_list_view.dart';
import '../views/typical_dishes/typical_dish_detail_view.dart';
import '../views/typical_dishes/typical_dishes_list_view.dart';

/// Centralized GoRouter navigation configuration for Datos Abiertos de Colombia.
class AppRouter {
  // Route names
  static const String dashboardName = 'dashboard';
  static const String departmentsName = 'departments';
  static const String departmentDetailName = 'department-detail';
  static const String attractionsName = 'attractions';
  static const String attractionDetailName = 'attraction-detail';
  static const String presidentsName = 'presidents';
  static const String presidentDetailName = 'president-detail';
  static const String typicalDishesName = 'typical-dishes';
  static const String typicalDishDetailName = 'typical-dish-detail';

  // Route paths
  static const String dashboardPath = '/';
  static const String departmentsPath = '/departments';
  static const String departmentDetailPath = '/departments/:id';
  static const String attractionsPath = '/attractions';
  static const String attractionDetailPath = '/attractions/:id';
  static const String presidentsPath = '/presidents';
  static const String presidentDetailPath = '/presidents/:id';
  static const String typicalDishesPath = '/typical-dishes';
  static const String typicalDishDetailPath = '/typical-dishes/:id';

  /// GoRouter instance singleton
  static final GoRouter router = GoRouter(
    initialLocation: dashboardPath,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: dashboardPath,
        name: dashboardName,
        builder: (context, state) => const DashboardView(),
      ),
      // 1. Departamentos
      GoRoute(
        path: departmentsPath,
        name: departmentsName,
        builder: (context, state) => const DepartmentsListView(),
        routes: [
          GoRoute(
            path: ':id',
            name: departmentDetailName,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              final initial = state.extra as Department?;
              return DepartmentDetailView(
                departmentId: id,
                initialDepartment: initial,
              );
            },
          ),
        ],
      ),
      // 2. Atracciones Turísticas
      GoRoute(
        path: attractionsPath,
        name: attractionsName,
        builder: (context, state) => const AttractionsListView(),
        routes: [
          GoRoute(
            path: ':id',
            name: attractionDetailName,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              final initial = state.extra as TouristicAttraction?;
              return AttractionDetailView(
                attractionId: id,
                initialAttraction: initial,
              );
            },
          ),
        ],
      ),
      // 3. Presidentes
      GoRoute(
        path: presidentsPath,
        name: presidentsName,
        builder: (context, state) => const PresidentsListView(),
        routes: [
          GoRoute(
            path: ':id',
            name: presidentDetailName,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              final initial = state.extra as President?;
              return PresidentDetailView(
                presidentId: id,
                initialPresident: initial,
              );
            },
          ),
        ],
      ),
      // 4. Platos Típicos
      GoRoute(
        path: typicalDishesPath,
        name: typicalDishesName,
        builder: (context, state) => const TypicalDishesListView(),
        routes: [
          GoRoute(
            path: ':id',
            name: typicalDishDetailName,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              final initial = state.extra as TypicalDish?;
              return TypicalDishDetailView(
                dishId: id,
                initialDish: initial,
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image_outlined, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Ruta no encontrada: ${state.uri}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.goNamed(dashboardName),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
