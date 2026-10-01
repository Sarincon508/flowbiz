import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/business_models.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';

class CustomersView extends StatefulWidget {
  final FlowBizController controller;

  const CustomersView({super.key, required this.controller});

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _activeTab = 'Todos'; // 'Todos', 'Mamás', 'Cumpleaños del Mes', 'Con Deuda'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final customers = controller.customers.where((c) {
      // Filtro por pestañas
      if (_activeTab == 'Mamás' && !c.isMother) return false;
      if (_activeTab == 'Cumpleaños del Mes') {
        if (c.birthDate == null || c.birthDate!.month != now.month) return false;
      }
      if (_activeTab == 'Con Deuda') {
        final apts = controller.appointments.where((a) => a.clientId == c.id).toList();
        final debt = apts.fold(0.0, (s, a) => s + a.pendingDebt);
        if (debt <= 0) return false;
      }

      // Filtro por búsqueda
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final nameMatches = c.name.toLowerCase().contains(query);
      final phoneMatches = c.phone.replaceAll(RegExp(r'\D'), '').contains(query.replaceAll(RegExp(r'\D'), ''));
      final profMatches = c.profession.toLowerCase().contains(query);
      return nameMatches || phoneMatches || profMatches;
    }).toList();

    final mothersCount = controller.customers.where((c) => c.isMother).length;
    final bdaysThisMonth = controller.customers.where((c) => c.birthDate != null && c.birthDate!.month == now.month).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Nuevo Cliente',
            onPressed: () => _showAddCustomerDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, teléfono o profesión...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // Chips de filtro rápido
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Todos', controller.customers.length),
                const SizedBox(width: 8),
                _buildFilterChip('Mamás 💐', mothersCount),
                const SizedBox(width: 8),
                _buildFilterChip('Cumpleaños del Mes 🎂', bdaysThisMonth),
                const SizedBox(width: 8),
                _buildFilterChip('Con Deuda ⚠️', null),
              ],
            ),
          ),

          // Contador resumen
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
            child: Row(
              children: [
                Text(
                  '${customers.length} ${customers.length == 1 ? "cliente encontrado" : "clientes encontrados"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Lista de clientes
          Expanded(
            child: customers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 56,
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay clientes en este filtro'
                              : 'No se encontraron clientes para "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_add_rounded),
                          label: const Text('Registrar Nuevo Cliente'),
                          onPressed: () => _showAddCustomerDialog(context),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                    itemCount: customers.length,
                    itemBuilder: (context, idx) {
                      final cust = customers[idx];
                      final apts = controller.appointments.where((a) {
                        return a.clientId == cust.id ||
                            (a.clientName.trim().toLowerCase() == cust.name.trim().toLowerCase() &&
                                a.clientPhone.replaceAll(RegExp(r'\D'), '') ==
                                    cust.phone.replaceAll(RegExp(r'\D'), ''));
                      }).toList();

                      final debtTotal = apts.fold(0.0, (sum, a) => sum + a.pendingDebt);

                      return _CustomerCard(
                        customer: cust,
                        appointmentsCount: apts.length,
                        pendingDebt: debtTotal,
                        formattedDebt: controller.formatMoney(debtTotal),
                        onEdit: () => _showEditCustomerDialog(context, cust),
                        onDelete: () => _confirmDeleteCustomer(context, cust),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nuevo Cliente'),
        onPressed: () => _showAddCustomerDialog(context),
      ),
    );
  }

  Widget _buildFilterChip(String label, int? count) {
    final isSelected = _activeTab == label;
    return ChoiceChip(
      label: Text(count != null ? '$label ($count)' : label),
      selected: isSelected,
      selectedColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _activeTab = label);
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final professionCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? selectedBirthDate;
    bool isMother = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primary),
                SizedBox(width: 8),
                Text('Nuevo Cliente'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre y Apellido *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono / WhatsApp *',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Profesión (opcional)
                    TextField(
                      controller: professionCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Profesión / Ocupación (opcional)',
                        hintText: 'Ej: Abogado, Médico, Docente...',
                        prefixIcon: Icon(Icons.work_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Fecha de Nacimiento (opcional)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedBirthDate != null
                              ? AppTheme.accent.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cake_rounded, color: AppTheme.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha de Nacimiento (opcional)',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  selectedBirthDate != null
                                      ? '${DateFormat('dd/MM/yyyy').format(selectedBirthDate!)} (${_calculateAge(selectedBirthDate!)} años)'
                                      : 'Sin registrar (para recordatorio de cumpleaños)',
                                  style: TextStyle(
                                    fontWeight: selectedBirthDate != null ? FontWeight.w800 : FontWeight.normal,
                                    fontSize: 12,
                                    color: selectedBirthDate != null
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedBirthDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              tooltip: 'Borrar fecha',
                              onPressed: () => setModalState(() => selectedBirthDate = null),
                            ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selectedBirthDate ?? DateTime(1995, 1, 1),
                                firstDate: DateTime(1920),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() => selectedBirthDate = picked);
                              }
                            },
                            child: const Text('Elegir', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ¿Es mamá? (opcional)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('¿Es mamá / madre de familia?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text(
                        'Activar para recordatorios del Día de la Madre',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      secondary: const Icon(Icons.favorite_rounded, color: Color(0xFFDB2777)),
                      value: isMother,
                      onChanged: (val) => setModalState(() => isMother = val),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notas o preferencias (opcional)',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  if (name.isEmpty || phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('El nombre y el teléfono son requeridos.'),
                        backgroundColor: AppTheme.warning,
                      ),
                    );
                    return;
                  }

                  // Comparar si ya existe
                  final existing = widget.controller.findCustomer(name: name, phone: phone);
                  if (existing != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ya existe un cliente con esos datos (${existing.name}).'),
                        backgroundColor: AppTheme.warning,
                      ),
                    );
                    return;
                  }

                  await widget.controller.findOrCreateCustomer(
                    name: name,
                    phone: phone,
                    birthDate: selectedBirthDate,
                    isMother: isMother,
                    profession: professionCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                  );

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cliente "$name" registrado con éxito.'),
                        backgroundColor: AppTheme.accent,
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    final nameCtrl = TextEditingController(text: customer.name);
    final phoneCtrl = TextEditingController(text: customer.phone);
    final professionCtrl = TextEditingController(text: customer.profession);
    final notesCtrl = TextEditingController(text: customer.notes);
    DateTime? selectedBirthDate = customer.birthDate;
    bool isMother = customer.isMother;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: AppTheme.primary),
                SizedBox(width: 8),
                Text('Editar Cliente'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre y Apellido *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono / WhatsApp *',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Profesión
                    TextField(
                      controller: professionCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Profesión / Ocupación',
                        hintText: 'Ej: Abogado, Médico, Docente...',
                        prefixIcon: Icon(Icons.work_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Fecha de Nacimiento
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedBirthDate != null
                              ? AppTheme.accent.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cake_rounded, color: AppTheme.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha de Nacimiento',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  selectedBirthDate != null
                                      ? '${DateFormat('dd/MM/yyyy').format(selectedBirthDate!)} (${_calculateAge(selectedBirthDate!)} años)'
                                      : 'Sin registrar',
                                  style: TextStyle(
                                    fontWeight: selectedBirthDate != null ? FontWeight.w800 : FontWeight.normal,
                                    fontSize: 12,
                                    color: selectedBirthDate != null
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedBirthDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              tooltip: 'Borrar fecha',
                              onPressed: () => setModalState(() => selectedBirthDate = null),
                            ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selectedBirthDate ?? DateTime(1995, 1, 1),
                                firstDate: DateTime(1920),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() => selectedBirthDate = picked);
                              }
                            },
                            child: const Text('Elegir', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ¿Es mamá?
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('¿Es mamá / madre de familia?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text(
                        'Activar para recordatorios del Día de la Madre',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      secondary: const Icon(Icons.favorite_rounded, color: Color(0xFFDB2777)),
                      value: isMother,
                      onChanged: (val) => setModalState(() => isMother = val),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notas o preferencias',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  if (name.isEmpty || phone.isEmpty) return;

                  customer.name = name;
                  customer.phone = phone;
                  customer.profession = professionCtrl.text.trim();
                  customer.birthDate = selectedBirthDate;
                  customer.isMother = isMother;
                  customer.notes = notesCtrl.text.trim();

                  await widget.controller.updateCustomer(customer);

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cliente "$name" actualizado correctamente.'),
                        backgroundColor: AppTheme.accent,
                      ),
                    );
                  }
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          );
        },
      ),
    );
  }

  static int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years >= 0 ? years : 0;
  }

  void _confirmDeleteCustomer(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Cliente?'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a "${customer.name}" del directorio de clientes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await widget.controller.deleteCustomer(customer.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Se eliminó a "${customer.name}".')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final int appointmentsCount;
  final double pendingDebt;
  final String formattedDebt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.customer,
    required this.appointmentsCount,
    required this.pendingDebt,
    required this.formattedDebt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final isBdayToday = customer.birthDate != null &&
        customer.birthDate!.month == now.month &&
        customer.birthDate!.day == now.day;

    final initials = customer.name.trim().isNotEmpty
        ? customer.name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isBdayToday
            ? const BorderSide(color: Color(0xFFE11D48), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isBdayToday
                  ? const Color(0xFFE11D48).withValues(alpha: 0.15)
                  : AppTheme.primary.withValues(alpha: 0.15),
              child: Text(
                initials,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isBdayToday ? const Color(0xFFE11D48) : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Informacion
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                      if (isBdayToday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '🎂 ¡CUMPLEAÑOS HOY!',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        customer.phone.isEmpty ? 'Sin teléfono' : customer.phone,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Chips de atributos: Profesión, Mamá, Cumpleaños
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (customer.profession.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.work_outline_rounded, size: 11, color: Color(0xFF4F46E5)),
                              const SizedBox(width: 4),
                              Text(
                                customer.profession,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (customer.isMother)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDB2777).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite_rounded, size: 11, color: Color(0xFFDB2777)),
                              SizedBox(width: 4),
                              Text(
                                'Mamá ❤️',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFDB2777),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (customer.birthDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cake_rounded, size: 11, color: Color(0xFFE11D48)),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('dd MMM').format(customer.birthDate!)}${customer.age != null ? " (${customer.age}a)" : ""}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$appointmentsCount cita(s)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      if (pendingDebt > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Deuda: $formattedDebt',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (customer.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Nota: ${customer.notes}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Acciones: Editar y Eliminar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primary),
                  tooltip: 'Editar Cliente',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.error),
                  tooltip: 'Eliminar Cliente',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
