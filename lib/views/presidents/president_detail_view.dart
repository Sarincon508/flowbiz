import 'package:flutter/material.dart';
import '../../models/president_model.dart';
import '../../services/api_colombia_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/image_with_fallback.dart';
import '../../widgets/loading_view.dart';

/// Full detail view for a specific Colombian President.
class PresidentDetailView extends StatefulWidget {
  final int presidentId;
  final President? initialPresident;

  const PresidentDetailView({
    super.key,
    required this.presidentId,
    this.initialPresident,
  });

  @override
  State<PresidentDetailView> createState() => _PresidentDetailViewState();
}

class _PresidentDetailViewState extends State<PresidentDetailView> {
  final ApiColombiaService _apiService = ApiColombiaService();
  President? _president;
  bool _isLoading = false;
  String? _errorMessage;
  int? _errorStatusCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialPresident != null) {
      _president = widget.initialPresident;
    } else {
      _fetchPresident();
    }
  }

  Future<void> _fetchPresident() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final data = await _apiService.getPresidentById(widget.presidentId);
      if (!mounted) return;
      setState(() {
        _president = data;
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
        _errorMessage = 'Error al obtener la información del presidente: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Presidente')),
        body: const LoadingView(message: 'Cargando biografía presidencial...'),
      );
    }

    if (_errorMessage != null || _president == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: ErrorView(
          message: _errorMessage ?? 'No fue posible encontrar el mandatario.',
          statusCode: _errorStatusCode,
          onRetry: _fetchPresident,
        ),
      );
    }

    final p = _president!;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.fullName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Portrait and Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF78350F), // Deep Warm Amber
                    Colors.amber.shade900,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: ImageWithFallback(
                        imageUrl: p.image,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.person_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Periodo: ${p.periodDisplay}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Political party card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.how_to_vote_rounded,
                            color: Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Partido Político / Afiliación',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.politicalParty ?? 'Independiente',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Biography Card
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
                            Icon(Icons.history_edu_rounded,
                                size: 20, color: Color(0xFFB45309)),
                            SizedBox(width: 8),
                            Text(
                              'Reseña Histórica y Biografía',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(
                          p.description ?? 'Sin biografía disponible en el registro.',
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
