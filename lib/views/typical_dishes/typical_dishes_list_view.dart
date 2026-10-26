import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/typical_dish_model.dart';
import '../../routes/app_router.dart';
import '../../services/api_colombia_service.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/image_with_fallback.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/loading_view.dart';

/// Screen listing Colombian Typical Dishes with search and state handling.
class TypicalDishesListView extends StatefulWidget {
  const TypicalDishesListView({super.key});

  @override
  State<TypicalDishesListView> createState() => _TypicalDishesListViewState();
}

class _TypicalDishesListViewState extends State<TypicalDishesListView> {
  final ApiColombiaService _apiService = ApiColombiaService();
  final TextEditingController _searchController = TextEditingController();

  List<TypicalDish> _allDishes = [];
  List<TypicalDish> _filteredDishes = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _errorStatusCode;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDishes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final data = await _apiService.getTypicalDishes();
      if (!mounted) return;
      setState(() {
        _allDishes = data;
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
        _errorMessage = 'Ocurrió un error al cargar los platos típicos: $e';
      });
    }
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredDishes = List.from(_allDishes);
      } else {
        _filteredDishes = _allDishes.where((dish) {
          final nameMatch = dish.name.toLowerCase().contains(q);
          final depMatch = dish.department?.name.toLowerCase().contains(q) ?? false;
          final ingMatch = (dish.ingredients ?? '').toLowerCase().contains(q);
          return nameMatch || depMatch || ingMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platos Típicos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _loadDishes,
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Buscar por plato, ingrediente o región...',
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
        message: 'Cargando gastronomía tradicional colombiana...',
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        statusCode: _errorStatusCode,
        onRetry: _loadDishes,
      );
    }

    if (_filteredDishes.isEmpty) {
      return const EmptyView(
        title: 'Sin platos típicos encontrados',
        message: 'No existen recetas que coincidan con la búsqueda.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDishes,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _filteredDishes.length,
        itemBuilder: (context, index) {
          final dish = _filteredDishes[index];
          final depName = dish.department?.name ?? 'Colombia';

          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                context.pushNamed(
                  AppRouter.typicalDishDetailName,
                  pathParameters: {'id': dish.id.toString()},
                  extra: dish,
                );
              },
              child: Row(
                children: [
                  ImageWithFallback(
                    imageUrl: dish.imageUrl,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.restaurant_rounded,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoChip(
                            icon: Icons.place_rounded,
                            label: depName,
                            color: Colors.red.shade50,
                            textColor: const Color(0xFFBE123C),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dish.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dish.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.chevron_right_rounded, color: Colors.grey),
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
