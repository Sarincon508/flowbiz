import 'package:flutter/material.dart';

/// Pantalla Principal para Taller 1: Flutter + Widgets + Git Flow
/// Estudiante: Samuel Alejandro Rincon Serna
/// Código: 230231045
/// Asignatura: Electiva Profesional 1 Móviles
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable de estado obligatoria para el título del AppBar
  String _tituloAppBar = 'Hola, Flutter';

  // Contador de alternancias para enriquecer la experiencia de usuario
  int _contadorCambios = 0;

  /// Método que demuestra el uso de setState() y SnackBar
  void _alternarTitulo() {
    setState(() {
      if (_tituloAppBar == 'Hola, Flutter') {
        _tituloAppBar = '¡Título cambiado!';
      } else {
        _tituloAppBar = 'Hola, Flutter';
      }
      _contadorCambios++;
    });

    // Mostrar SnackBar con el mensaje solicitado
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Título actualizado (Estado: $_tituloAppBar)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B365D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _reiniciarEstado() {
    setState(() {
      _tituloAppBar = 'Hola, Flutter';
      _contadorCambios = 0;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Estado restablecido a "Hola, Flutter"'),
        backgroundColor: Colors.blueGrey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar con título en variable de estado reactiva
        title: Text(
          _tituloAppBar,
          key: const Key('appBarTitleKey'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------
              // WIDGET ADICIONAL 1: Container con márgenes, colores y bordes
              // ---------------------------------------------------------------
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B365D), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B365D).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Badge institucional
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'UCEVA • ELECTIVA PROFESIONAL 1 MÓVILES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TEXT CENTRADO CON EL NOMBRE COMPLETO DEL ESTUDIANTE (Obligatorio)
                    const Center(
                      child: Text(
                        'Samuel Alejandro Rincon Serna',
                        key: Key('studentNameKey'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Código y detalles del estudiante
                    const Text(
                      'Código: 230231045',
                      key: Key('studentCodeKey'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFBAE6FD),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 10),

                    // Indicador de estado reactivo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sync_alt_rounded, color: Colors.amberAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Título AppBar: "$_tituloAppBar" (Interacciones: $_contadorCambios)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---------------------------------------------------------------
              // SECCIÓN DE IMÁGENES EN UN ROW (Obligatorio: Network + Asset)
              // ---------------------------------------------------------------
              const Text(
                'Galería de Imágenes (Row: Network + Asset)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  // Imagen con Image.network()
                  Expanded(
                    child: Container(
                      height: 145,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFE2E8F0),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.wifi_off, color: Colors.blueGrey),
                                          SizedBox(height: 4),
                                          Text('Network Img', style: TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Image.network()',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          const Text(
                            'Flutter CDN (Remoto)',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Imagen con Image.asset()
                  Expanded(
                    child: Container(
                      height: 145,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/flutter_taller.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFE2E8F0),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, color: Colors.blueGrey),
                                          SizedBox(height: 4),
                                          Text('Asset Img', style: TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Image.asset()',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const Text(
                            'assets/images/ (Local)',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ---------------------------------------------------------------
              // BOTÓN + setState() (OBLIGATORIO)
              // ---------------------------------------------------------------
              ElevatedButton.icon(
                key: const Key('toggleTitleButtonKey'),
                icon: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),
                label: Text(
                  _tituloAppBar == 'Hola, Flutter'
                      ? 'Cambiar a "¡Título cambiado!"'
                      : 'Restaurar a "Hola, Flutter"',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _alternarTitulo,
              ),

              const SizedBox(height: 22),

              // ---------------------------------------------------------------
              // WIDGET ADICIONAL 2: Stack (Superponer texto sobre una imagen)
              // ---------------------------------------------------------------
              const Text(
                'Widget Adicional: Stack (Superposición de Texto sobre Imagen)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen de fondo del Stack
                      Image.asset(
                        'assets/images/flowbiz_banner.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0F172A), Color(0xFF334155)],
                              ),
                            ),
                          );
                        },
                      ),

                      // Capa semitransparente para legibilidad de textos
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.75),
                              Colors.black.withValues(alpha: 0.35),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),

                      // Texto superpuesto en la esquina superior izquierda
                      Positioned(
                        top: 14,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'STACK • TEXTO SUPERPUESTO SOBRE IMAGEN',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),

                      // Texto principal superpuesto en la parte inferior con estado dinámico
                      Positioned(
                        bottom: 14,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.amberAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Estado Actual: "$_tituloAppBar"',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ---------------------------------------------------------------
              // WIDGET ADICIONAL 3: ListView (Lista simple de 4 elementos con icono y texto)
              // ---------------------------------------------------------------
              const Text(
                'Widget Adicional: ListView (Módulos y Competencias del Taller)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    _buildModuleTile(
                      icon: Icons.refresh_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: '1. StatefulWidget & setState()',
                      subtitle: 'Gestión reactiva del árbol de widgets ante eventos del usuario.',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildModuleTile(
                      icon: Icons.image_outlined,
                      iconColor: const Color(0xFF16A34A),
                      title: '2. Renderizado de Imágenes',
                      subtitle: 'Integración híbrida de Image.network() e Image.asset().',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildModuleTile(
                      icon: Icons.alt_route_rounded,
                      iconColor: const Color(0xFF9333EA),
                      title: '3. Flujo Git Flow Profesional',
                      subtitle: 'Ramas main, dev y feature/taller1 con Pull Requests.',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildModuleTile(
                      icon: Icons.layers_outlined,
                      iconColor: const Color(0xFFEA580C),
                      title: '4. Layouts y Composición Limpia',
                      subtitle: 'Estructuración armónica con Column, Row, Padding y SizedBox.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ---------------------------------------------------------------
              // WIDGET ADICIONAL 4: OutlinedButton / Acción Secundaria
              // ---------------------------------------------------------------
              OutlinedButton.icon(
                icon: const Icon(Icons.restart_alt_rounded, size: 20),
                label: const Text('Restablecer Estado Inicial'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B365D),
                  side: const BorderSide(color: Color(0xFF1B365D), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _reiniciarEstado,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
      dense: true,
    );
  }
}
