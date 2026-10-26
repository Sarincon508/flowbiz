import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/department_model.dart';
import '../../routes/app_router.dart';
import '../../services/api_colombia_service.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/loading_view.dart';

/// Screen listing Colombian departments with search and state handling.
class DepartmentsListView extends StatefulWidget {
  const DepartmentsListView({super.key});

  @override
  State<DepartmentsListView> createState() => _DepartmentsListViewState();
}

class _DepartmentsListViewState extends State<DepartmentsListView> {
  final ApiColombiaService _apiService = ApiColombiaService();
  final TextEditingController _searchController = TextEditingController();

  List<Department> _allDepartments = [];
  List<Department> _filteredDepartments = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _errorStatusCode;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final data = await _apiService.getDepartments();
      if (!mounted) return;
      setState(() {
        _allDepartments = data;
        _applyFilter(_searchController.text);
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _errorStatusCode = e.statusCode;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ocurrió un error al cargar los departamentos: $e';
      });
    }
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredDepartments = List.from(_allDepartments);
      } else {
        _filteredDepartments = _allDepartments.where((dep) {
          final nameMatch = dep.name.toLowerCase().contains(q);
          final capitalMatch = dep.cityCapital?.name.toLowerCase().contains(q) ?? false;
          return nameMatch || capitalMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _loadDepartments,
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Buscar por departamento o capital...',
            onChanged: _applyFilter,
            onClear: () => _applyFilter(''),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(
        message: 'Consultando departamentos de Colombia...',
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        statusCode: _errorStatusCode,
        onRetry: _loadDepartments,
      );
    }

    if (_filteredDepartments.isEmpty) {
      return const EmptyView(
        title: 'Sin departamentos coincidentes',
        message: 'No encontramos ningún departamento con ese término.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDepartments,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _filteredDepartments.length,
        itemBuilder: (context, index) {
          final department = _filteredDepartments[index];
          final capitalName = department.cityCapital?.name ?? 'Sin capital asignada';
          final municipalities = department.municipalities ?? 0;

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.pushNamed(
                  AppRouter.departmentDetailName,
                  pathParameters: {'id': department.id.toString()},
                  extra: department,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          department.name.isNotEmpty
                              ? department.name.substring(0, 1).toUpperCase()
                              : 'D',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            department.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Capital: $capitalName',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              InfoChip(
                                icon: Icons.location_city_rounded,
                                label: '$municipalities municipios',
                              ),
                              if (department.population != null)
                                InfoChip(
                                  icon: Icons.people_outline_rounded,
                                  label: '${department.population} hab.',
                                  color: Colors.blue.shade50,
                                  textColor: Colors.blue.shade800,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
