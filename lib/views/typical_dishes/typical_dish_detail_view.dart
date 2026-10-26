import 'package:flutter/material.dart';
import '../../models/typical_dish_model.dart';
import '../../services/api_colombia_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/image_with_fallback.dart';
import '../../widgets/loading_view.dart';

/// Full detail view for a specific Colombian Typical Dish.
class TypicalDishDetailView extends StatefulWidget {
  final int dishId;
  final TypicalDish? initialDish;

  const TypicalDishDetailView({
    super.key,
    required this.dishId,
    this.initialDish,
  });

  @override
  State<TypicalDishDetailView> createState() => _TypicalDishDetailViewState();
}

class _TypicalDishDetailViewState extends State<TypicalDishDetailView> {
  final ApiColombiaService _apiService = ApiColombiaService();
  TypicalDish? _dish;
  bool _isLoading = false;
  String? _errorMessage;
  int? _errorStatusCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialDish != null) {
      _dish = widget.initialDish;
    } else {
      _fetchDish();
    }
  }

  Future<void> _fetchDish() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final data = await _apiService.getTypicalDishById(widget.dishId);
      if (!mounted) return;
      setState(() {
        _dish = data;
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
        _errorMessage = 'Error al obtener la información del plato típico: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del Plato Típico')),
        body: const LoadingView(message: 'Cargando receta y detalles culinarios...'),
      );
    }

    if (_errorMessage != null || _dish == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: ErrorView(
          message: _errorMessage ?? 'No fue posible encontrar el plato típico.',
          statusCode: _errorStatusCode,
          onRetry: _fetchDish,
        ),
      );
    }

    final dish = _dish!;
    final dep = dish.department;
    final ingredientsList = dish.ingredientsList;

    return Scaffold(
      appBar: AppBar(
        title: Text(dish.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dish Hero Image
            if (dish.imageUrl != null)
              ImageWithFallback(
                imageUrl: dish.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                fallbackIcon: Icons.restaurant_rounded,
              ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBE123C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID #${dish.id}',
                          style: const TextStyle(
                            color: Color(0xFFBE123C),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (dep != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          avatar: const Icon(Icons.place_rounded, size: 16),
                          label: Text(dep.name),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dish.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Ingredients Section
                  if (ingredientsList.isNotEmpty) ...[
                    Container(
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
                          const Row(
                            children: [
                              Icon(Icons.kitchen_rounded,
                                  size: 20, color: Color(0xFFBE123C)),
                              SizedBox(width: 8),
                              Text(
                                'Ingredientes Principales',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFBE123C),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ingredientsList.map((ingredient) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.red.shade100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 14,
                                      color: Color(0xFFBE123C),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      ingredient,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFBE123C),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Description Section
                  Container(
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
                        const Row(
                          children: [
                            Icon(Icons.menu_book_rounded,
                                size: 20, color: Color(0xFFBE123C)),
                            SizedBox(width: 8),
                            Text(
                              'Origen y Tradición Culinaria',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(
                          dish.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black87,
                          ),
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
}
