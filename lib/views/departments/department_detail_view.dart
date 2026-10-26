import 'package:flutter/material.dart';
import '../../models/department_model.dart';
import '../../services/api_colombia_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

/// Full detail view for a specific Colombian Department.
class DepartmentDetailView extends StatefulWidget {
  final int departmentId;
  final Department? initialDepartment;

  const DepartmentDetailView({
    super.key,
    required this.departmentId,
    this.initialDepartment,
  });

  @override
  State<DepartmentDetailView> createState() => _DepartmentDetailViewState();
}

class _DepartmentDetailViewState extends State<DepartmentDetailView> {
  final ApiColombiaService _apiService = ApiColombiaService();
  Department? _department;
  bool _isLoading = false;
  String? _errorMessage;
  int? _errorStatusCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialDepartment != null) {
      _department = widget.initialDepartment;
    } else {
      _fetchDepartment();
    }
  }

  Future<void> _fetchDepartment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final data = await _apiService.getDepartmentById(widget.departmentId);
      if (!mounted) return;
      setState(() {
        _department = data;
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
        _errorMessage = 'Error al obtener el detalle del departamento: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Departamento')),
        body: const LoadingView(message: 'Cargando información detallada...'),
      );
    }

    if (_errorMessage != null || _department == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: ErrorView(
          message: _errorMessage ?? 'No fue posible encontrar el departamento.',
          statusCode: _errorStatusCode,
          onRetry: _fetchDepartment,
        ),
      );
    }

    final dep = _department!;
    final capital = dep.cityCapital;

    return Scaffold(
      appBar: AppBar(
        title: Text(dep.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Hero Banner
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E3A8A),
                    Colors.blue.shade800,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ID #${dep.id} • República de Colombia',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dep.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (capital != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Capital: ${capital.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.people_alt_rounded,
                          label: 'Población',
                          value: dep.population != null
                              ? '${dep.population} hab.'
                              : 'No registrado',
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.square_foot_rounded,
                          label: 'Superficie',
                          value: dep.surface != null
                              ? '${dep.surface} km²'
                              : 'No registrado',
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.location_city_rounded,
                          label: 'Municipios',
                          value: '${dep.municipalities ?? 0}',
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.phone_rounded,
                          label: 'Prefijo Telefónico',
                          value: dep.phonePrefix != null && dep.phonePrefix!.isNotEmpty
                              ? '+57 (${dep.phonePrefix})'
                              : 'N/A',
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description Card
                  _buildSectionCard(
                    title: 'Descripción General',
                    icon: Icons.description_outlined,
                    child: Text(
                      dep.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Capital City Detail Card
                  if (capital != null)
                    _buildSectionCard(
                      title: 'Información de la Capital: ${capital.name}',
                      icon: Icons.apartment_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (capital.description != null &&
                              capital.description!.isNotEmpty) ...[
                            Text(
                              capital.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (capital.population != null)
                                Chip(
                                  avatar: const Icon(Icons.people_outline, size: 16),
                                  label: Text('Población: ${capital.population}'),
                                ),
                              if (capital.surface != null)
                                Chip(
                                  avatar: const Icon(Icons.aspect_ratio, size: 16),
                                  label: Text('Superficie: ${capital.surface} km²'),
                                ),
                              if (capital.postalCode != null)
                                Chip(
                                  avatar: const Icon(Icons.markunread_mailbox_outlined,
                                      size: 16),
                                  label: Text('Cód. Postal: ${capital.postalCode}'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}
