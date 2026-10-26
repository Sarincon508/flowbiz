import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/president_model.dart';
import '../../routes/app_router.dart';
import '../../services/api_colombia_service.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/image_with_fallback.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/loading_view.dart';

/// Screen listing Colombian Presidents with portrait and search.
class PresidentsListView extends StatefulWidget {
  const PresidentsListView({super.key});

  @override
  State<PresidentsListView> createState() => _PresidentsListViewState();
}

class _PresidentsListViewState extends State<PresidentsListView> {
  final ApiColombiaService _apiService = ApiColombiaService();
  final TextEditingController _searchController = TextEditingController();

  List<President> _allPresidents = [];
  List<President> _filteredPresidents = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _errorStatusCode;

  @override
  void initState() {
    super.initState();
    _loadPresidents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPresidents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final data = await _apiService.getPresidents();
      if (!mounted) return;
      setState(() {
        _allPresidents = data;
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
        _errorMessage = 'Ocurrió un error al cargar los presidentes: $e';
      });
    }
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredPresidents = List.from(_allPresidents);
      } else {
        _filteredPresidents = _allPresidents.where((p) {
          final fullName = '${p.name} ${p.lastName}'.toLowerCase();
          final party = (p.politicalParty ?? '').toLowerCase();
          final desc = (p.description ?? '').toLowerCase();
          return fullName.contains(q) || party.contains(q) || desc.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presidentes de Colombia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _loadPresidents,
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Buscar por nombre, apellido o partido...',
            onChanged: _applyFilter,
            onClear: () => _applyFilter(''),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(
        message: 'Cargando presidentes históricos de Colombia...',
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        statusCode: _errorStatusCode,
        onRetry: _loadPresidents,
      );
    }

    if (_filteredPresidents.isEmpty) {
      return const EmptyView(
        title: 'Sin presidentes encontrados',
        message: 'No existen mandatarios que coincidan con la búsqueda.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPresidents,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _filteredPresidents.length,
        itemBuilder: (context, index) {
          final president = _filteredPresidents[index];

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.pushNamed(
                  AppRouter.presidentDetailName,
                  pathParameters: {'id': president.id.toString()},
                  extra: president,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ImageWithFallback(
                        imageUrl: president.image,
                        width: 58,
                        height: 72,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.person_rounded,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            president.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            president.politicalParty ?? 'Independiente',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InfoChip(
                            icon: Icons.calendar_today_rounded,
                            label: president.periodDisplay,
                            color: Colors.amber.shade50,
                            textColor: const Color(0xFFB45309),
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
