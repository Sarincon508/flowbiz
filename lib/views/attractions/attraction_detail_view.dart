import 'package:flutter/material.dart';
import '../../models/touristic_attraction_model.dart';
import '../../services/api_colombia_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/image_with_fallback.dart';
import '../../widgets/loading_view.dart';

/// Full detail view for a specific Colombian Touristic Attraction.
class AttractionDetailView extends StatefulWidget {
  final int attractionId;
  final TouristicAttraction? initialAttraction;

  const AttractionDetailView({
    super.key,
    required this.attractionId,
    this.initialAttraction,
  });

  @override
  State<AttractionDetailView> createState() => _AttractionDetailViewState();
}

class _AttractionDetailViewState extends State<AttractionDetailView> {
  final ApiColombiaService _apiService = ApiColombiaService();
  TouristicAttraction? _attraction;
  bool _isLoading = false;
  String? _errorMessage;
  int? _errorStatusCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialAttraction != null) {
      _attraction = widget.initialAttraction;
    } else {
      _fetchAttraction();
    }
  }

  Future<void> _fetchAttraction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final data = await _apiService.getTouristicAttractionById(widget.attractionId);
      if (!mounted) return;
      setState(() {
        _attraction = data;
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
        _errorMessage = 'Error al obtener la atracción: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Atracción')),
        body: const LoadingView(message: 'Cargando información del destino...'),
      );
    }

    if (_errorMessage != null || _attraction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: ErrorView(
          message: _errorMessage ?? 'No fue posible encontrar la atracción.',
          statusCode: _errorStatusCode,
          onRetry: _fetchAttraction,
        ),
      );
    }

    final att = _attraction!;
    final city = att.city;

    return Scaffold(
      appBar: AppBar(
        title: Text(att.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gallery / Image Banner
            if (att.images.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: att.images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageWithFallback(
                          imageUrl: att.images[index],
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.landscape_rounded,
                        ),
                        if (att.images.length > 1)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${index + 1} / ${att.images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
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
                          color: const Color(0xFF047857).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID #${att.id}',
                          style: const TextStyle(
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (city != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          avatar: const Icon(Icons.location_on, size: 16),
                          label: Text(city.name),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    att.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Coordinates Card
                  if (att.latitude != null || att.longitude != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location_rounded, color: Color(0xFF047857)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Coordenadas Geográficas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lat: ${att.latitude ?? 'N/A'} | Lon: ${att.longitude ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Description
                  const Text(
                    'Información del Lugar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF047857),
                    ),
                  ),
                  const Divider(height: 20),
                  Text(
                    att.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
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
