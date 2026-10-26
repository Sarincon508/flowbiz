import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/touristic_attraction_model.dart';
import '../../routes/app_router.dart';
import '../../services/api_colombia_service.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/image_with_fallback.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/loading_view.dart';

/// Screen listing Colombian Touristic Attractions with image thumbnails and search.
class AttractionsListView extends StatefulWidget {
  const AttractionsListView({super.key});

  @override
  State<AttractionsListView> createState() => _AttractionsListViewState();
}

class _AttractionsListViewState extends State<AttractionsListView> {
  final ApiColombiaService _apiService = ApiColombiaService();
  final TextEditingController _searchController = TextEditingController();

  List<TouristicAttraction> _allAttractions = [];
  List<TouristicAttraction> _filteredAttractions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _errorStatusCode;

  @override
  void initState() {
    super.initState();
    _loadAttractions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAttractions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final data = await _apiService.getTouristicAttractions();
      if (!mounted) return;
      setState(() {
        _allAttractions = data;
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
        _errorMessage = 'Ocurrió un error al cargar las atracciones: $e';
      });
    }
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredAttractions = List.from(_allAttractions);
      } else {
        _filteredAttractions = _allAttractions.where((item) {
          final nameMatch = item.name.toLowerCase().contains(q);
          final cityMatch = item.city?.name.toLowerCase().contains(q) ?? false;
          final descMatch = item.description.toLowerCase().contains(q);
          return nameMatch || cityMatch || descMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atracciones Turísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _loadAttractions,
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Buscar por atracción, ciudad o descripción...',
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
        message: 'Cargando atracciones turísticas de Colombia...',
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        statusCode: _errorStatusCode,
        onRetry: _loadAttractions,
      );
    }

    if (_filteredAttractions.isEmpty) {
      return const EmptyView(
        title: 'Sin atracciones encontradas',
        message: 'No existen atracciones que coincidan con la búsqueda.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttractions,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _filteredAttractions.length,
        itemBuilder: (context, index) {
          final attraction = _filteredAttractions[index];
          final cityName = attraction.city?.name ?? 'Colombia';

          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                context.pushNamed(
                  AppRouter.attractionDetailName,
                  pathParameters: {'id': attraction.id.toString()},
                  extra: attraction,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (attraction.primaryImage != null)
                    ImageWithFallback(
                      imageUrl: attraction.primaryImage,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.landscape_rounded,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InfoChip(
                              icon: Icons.location_on_rounded,
                              label: cityName,
                              color: const Color(0xFFECFDF5),
                              textColor: const Color(0xFF047857),
                            ),
                            if (attraction.images.length > 1) ...[
                              const SizedBox(width: 8),
                              InfoChip(
                                icon: Icons.photo_library_rounded,
                                label: '${attraction.images.length} fotos',
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          attraction.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          attraction.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
