import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/business_models.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';
import 'customers_view.dart';

class AgendaView extends StatefulWidget {
  final FlowBizController controller;

  const AgendaView({super.key, required this.controller});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  String _selectedFilter = 'Pendientes';
  bool _showCalendar = true;
  String _calendarMode = 'Mes'; // 'Día', 'Semana', 'Mes'
  DateTime _selectedDate = DateTime.now();
  bool _filterByDate = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;

    // Filtro combinado de Estado + Fecha (si está activo el filtro de fecha)
    final filtered = controller.appointments.where((a) {
      // 1. Filtro por Estado
      if (_selectedFilter == 'Pendientes' && a.status != AppointmentStatus.pending) return false;
      if (_selectedFilter == 'Con Deuda' && a.pendingDebt <= 0) return false;
      if (_selectedFilter == 'Liquidadas' && (a.status != AppointmentStatus.completed || a.pendingDebt > 0)) return false;

      // 2. Filtro por Fecha (si el usuario seleccionó filtrar por el mini calendario)
      if (_filterByDate) {
        if (_calendarMode == 'Día') {
          return a.scheduledAt.year == _selectedDate.year &&
              a.scheduledAt.month == _selectedDate.month &&
              a.scheduledAt.day == _selectedDate.day;
        } else if (_calendarMode == 'Semana') {
          final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
          final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
          final end = start.add(const Duration(days: 7));
          return a.scheduledAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
              a.scheduledAt.isBefore(end);
        } else if (_calendarMode == 'Mes') {
          return a.scheduledAt.year == _selectedDate.year &&
              a.scheduledAt.month == _selectedDate.month;
        }
      }

      return true;
    }).toList();

    final remindersForSelectedDate = controller.getSpecialRemindersForDate(_selectedDate);
    final upcomingReminders = controller.getUpcomingReminders(daysAhead: 30);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Inteligente'),
        actions: [
          // Recordatorios y Fechas Especiales
          IconButton(
            icon: Badge(
              isLabelVisible: upcomingReminders.isNotEmpty,
              label: Text('${upcomingReminders.length}'),
              backgroundColor: const Color(0xFFE11D48),
              child: const Icon(Icons.celebration_rounded),
            ),
            tooltip: 'Fechas Especiales & Recordatorios',
            onPressed: () => _showUpcomingRemindersModal(context, upcomingReminders),
          ),
          // Alternar visualización del Mini Calendario
          IconButton(
            icon: Icon(
              _showCalendar ? Icons.calendar_month_rounded : Icons.calendar_today_outlined,
              color: _showCalendar ? AppTheme.primary : null,
            ),
            tooltip: _showCalendar ? 'Ocultar Calendario' : 'Mostrar Calendario',
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
          // Acceso directo a deudores si hay
          if (controller.pendingDebtAppointments.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${controller.pendingDebtAppointments.length}'),
                backgroundColor: AppTheme.error,
                child: const Icon(Icons.assignment_late_rounded, color: AppTheme.error),
              ),
              tooltip: 'Ver Clientes con Deuda',
              onPressed: () => setState(() => _selectedFilter = 'Con Deuda'),
            ),
          IconButton(
            icon: const Icon(Icons.people_alt_rounded),
            tooltip: 'Directorio de Clientes',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomersView(controller: controller),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // MINI CALENDARIO INTERACTIVO (Día / Semana / Mes con marcas especiales)
          if (_showCalendar)
            _buildMiniCalendarSection(isDark, controller, remindersForSelectedDate),

          // Banner de Días Especiales para el día seleccionado
          if (_showCalendar && remindersForSelectedDate.isNotEmpty)
            _buildSpecialDayBanner(remindersForSelectedDate),

          // Pestañas de Estado (Pendientes, Con Deuda, Liquidadas, Todas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Pendientes', 'Con Deuda', 'Liquidadas', 'Todas'].map((filter) {
                        final isSel = _selectedFilter == filter;
                        final isDebtTab = filter == 'Con Deuda';
                        final count = isDebtTab ? controller.pendingDebtAppointments.length : null;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(filter),
                                if (count != null && count > 0) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSel ? Colors.white : AppTheme.error,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isSel ? AppTheme.error : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            selected: isSel,
                            selectedColor: isDebtTab ? AppTheme.error : AppTheme.primary,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : null,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                            onSelected: (s) {
                              if (s) setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Indicador y botón para quitar filtro de fecha
                if (_filterByDate)
                  ActionChip(
                    avatar: const Icon(Icons.close_rounded, size: 14),
                    label: const Text('Ver Todo', style: TextStyle(fontSize: 11)),
                    backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
                    onPressed: () => setState(() => _filterByDate = false),
                  ),
              ],
            ),
          ),

          // Banner de filtro activo de fecha
          if (_filterByDate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Filtrando por $_calendarMode: ${_formatFilterLabel()}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary),
                  ),
                ],
              ),
            ),

          // Summary banner si Con Deuda está seleccionado
          if (_selectedFilter == 'Con Deuda' && controller.totalAccountsReceivable > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppTheme.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Cuentas por Cobrar',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.error),
                        ),
                        Text(
                          controller.formatMoney(controller.totalAccountsReceivable),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.error),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${controller.pendingDebtAppointments.length} deudor(es)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.error),
                  ),
                ],
              ),
            ),

          // Lista de Citas
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 48,
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filterByDate
                              ? 'No hay citas para $_calendarMode (${_formatFilterLabel()})'
                              : 'No hay citas registradas en esta sección',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_filterByDate) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_view_month_rounded, size: 16),
                            label: const Text('Ver todas las citas sin filtrar fecha'),
                            onPressed: () => setState(() => _filterByDate = false),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final apt = filtered[idx];
                      return _AppointmentCard(
                        appointment: apt,
                        controller: controller,
                        onLiquidate: () => _showLiquidationModal(context, apt),
                        onCancel: () => controller.cancelAppointment(apt.id),
                        onPayDebt: () => _showPayDebtDialog(context, apt),
                        onEdit: () => _showEditAppointmentDialog(context, apt),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
        onPressed: () => _showNewAppointmentDialog(context),
      ),
    );
  }

  String _formatFilterLabel() {
    if (_calendarMode == 'Día') {
      return DateFormat('dd MMM yyyy').format(_selectedDate);
    } else if (_calendarMode == 'Semana') {
      final start = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
    } else {
      return DateFormat('MMMM yyyy').format(_selectedDate);
    }
  }

  // --- Widget: Mini Calendario Interactivo ---
  Widget _buildMiniCalendarSection(
    bool isDark,
    FlowBizController controller,
    List<SpecialReminder> remindersForDate,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selector de Modo (Día | Semana | Mes) + Controles de Navegación
          Row(
            children: [
              // Selector de Modo
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Día', 'Semana', 'Mes'].map((mode) {
                    final isSel = _calendarMode == mode;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _calendarMode = mode;
                          _filterByDate = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mode,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Spacer(),

              // Botón Hoy
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _filterByDate = true;
                  });
                },
                child: const Text('Hoy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),

              // Botones < y >
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () => _navigateCalendar(-1),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () => _navigateCalendar(1),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Título de la fecha actual mostrada
          Row(
            children: [
              const Icon(Icons.event_note_rounded, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                _calendarMode == 'Día'
                    ? DateFormat('EEEE, dd de MMMM yyyy').format(_selectedDate)
                    : (_calendarMode == 'Semana'
                        ? 'Semana del ${DateFormat('dd MMM').format(_selectedDate.subtract(Duration(days: _selectedDate.weekday - 1)))} al ${DateFormat('dd MMM yyyy').format(_selectedDate.add(Duration(days: 7 - _selectedDate.weekday)))}'
                        : DateFormat('MMMM yyyy').format(_selectedDate)),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ],
          ),

          const Divider(height: 14),

          // Cuerpo según el Modo
          if (_calendarMode == 'Mes')
            _buildMonthGrid(isDark, controller)
          else if (_calendarMode == 'Semana')
            _buildWeekStrip(isDark, controller)
          else
            _buildDayView(isDark, controller),
        ],
      ),
    );
  }

  void _navigateCalendar(int direction) {
    setState(() {
      if (_calendarMode == 'Día') {
        _selectedDate = _selectedDate.add(Duration(days: direction));
      } else if (_calendarMode == 'Semana') {
        _selectedDate = _selectedDate.add(Duration(days: direction * 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + direction, 1);
      }
      _filterByDate = true;
    });
  }

  // Vista de Mes
  Widget _buildMonthGrid(bool isDark, FlowBizController controller) {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday; // 1 = Lun, 7 = Dom
    final today = DateTime.now();

    final dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Column(
      children: [
        // Encabezados de días
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayNames
              .map((d) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),

        // Matriz de días
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42, // 6 semanas
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final dayOffset = index - (startWeekday - 1);
            if (dayOffset < 0 || dayOffset >= daysInMonth) {
              return const SizedBox.shrink();
            }

            final day = dayOffset + 1;
            final cellDate = DateTime(_selectedDate.year, _selectedDate.month, day);
            final isSelected = _selectedDate.year == cellDate.year &&
                _selectedDate.month == cellDate.month &&
                _selectedDate.day == cellDate.day;
            final isToday = today.year == cellDate.year &&
                today.month == cellDate.month &&
                today.day == cellDate.day;

            final aptsOnDay = controller.getAppointmentsForDate(cellDate);
            final specialReminders = controller.getSpecialRemindersForDate(cellDate);
            final hasBday = specialReminders.any((r) => r.type == SpecialDayType.birthday);
            final hasMother = specialReminders.any((r) => r.type == SpecialDayType.motherDay);
            final hasProf = specialReminders.any((r) => r.type == SpecialDayType.professionDay);

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDate = cellDate;
                  _filterByDate = true;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : (isToday ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: AppTheme.primary, width: 1.2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: (isSelected || isToday) ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    // Indicadores de Citas y Fechas Especiales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (aptsOnDay.isNotEmpty)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasBday)
                          const Text('🎂', style: TextStyle(fontSize: 8))
                        else if (hasMother)
                          const Text('💐', style: TextStyle(fontSize: 8))
                        else if (hasProf)
                          const Text('👔', style: TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Vista de Semana
  Widget _buildWeekStrip(bool isDark, FlowBizController controller) {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final today = DateTime.now();

    final dayLabels = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final cellDate = startOfWeek.add(Duration(days: i));
        final isSelected = _selectedDate.year == cellDate.year &&
            _selectedDate.month == cellDate.month &&
            _selectedDate.day == cellDate.day;
        final isToday = today.year == cellDate.year &&
            today.month == cellDate.month &&
            today.day == cellDate.day;

        final aptsOnDay = controller.getAppointmentsForDate(cellDate);
        final specialReminders = controller.getSpecialRemindersForDate(cellDate);
        final hasBday = specialReminders.any((r) => r.type == SpecialDayType.birthday);
        final hasMother = specialReminders.any((r) => r.type == SpecialDayType.motherDay);
        final hasProf = specialReminders.any((r) => r.type == SpecialDayType.professionDay);

        return Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedDate = cellDate;
                _filterByDate = true;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : (isToday ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
                border: isToday && !isSelected
                    ? Border.all(color: AppTheme.primary, width: 1.2)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cellDate.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Badges
                  if (aptsOnDay.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppTheme.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${aptsOnDay.length}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : Colors.white,
                        ),
                      ),
                    )
                  else if (hasBday)
                    const Text('🎂', style: TextStyle(fontSize: 10))
                  else if (hasMother)
                    const Text('💐', style: TextStyle(fontSize: 10))
                  else if (hasProf)
                    const Text('👔', style: TextStyle(fontSize: 10))
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Vista de Día
  Widget _buildDayView(bool isDark, FlowBizController controller) {
    final aptsOnDay = controller.getAppointmentsForDate(_selectedDate);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd de MMMM, yyyy').format(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              Text(
                '${aptsOnDay.length} cita(s) programada(s) para este día',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Cita Aquí', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => _showNewAppointmentDialog(context, initialDate: _selectedDate),
          ),
        ],
      ),
    );
  }

  // Banner para días especiales
  Widget _buildSpecialDayBanner(List<SpecialReminder> reminders) {
    return Column(
      children: reminders.map((rem) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: rem.type.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: rem.type.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(rem.type.icon, color: rem.type.color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rem.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: rem.type.color,
                      ),
                    ),
                    Text(
                      rem.subtitle,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (rem.customerPhone != null && rem.customerPhone!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.sms_outlined, size: 20),
                  color: rem.type.color,
                  tooltip: 'Contactar para felicitar',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Enviar felicitación a ${rem.customerPhone}'),
                        backgroundColor: rem.type.color,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Modal para Próximos Recordatorios Especiales (Cumpleaños, Día de la Madre, Profesión)
  void _showUpcomingRemindersModal(
    BuildContext context,
    List<SpecialReminder> reminders,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.celebration_rounded, color: Color(0xFFE11D48)),
                  SizedBox(width: 10),
                  Text(
                    'Fechas Especiales & Recordatorios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Próximos 30 días: Cumpleaños de clientes, Día de la Madre y profesiones',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 20),
              Expanded(
                child: reminders.isEmpty
                    ? const Center(
                        child: Text('No hay fechas especiales en los próximos 30 días.'),
                      )
                    : ListView.separated(
                        itemCount: reminders.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final rem = reminders[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: rem.type.color.withValues(alpha: 0.15),
                              child: Icon(rem.type.icon, color: rem.type.color, size: 20),
                            ),
                            title: Text(rem.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            subtitle: Text(
                              '${DateFormat('dd MMMM').format(rem.date)} • ${rem.subtitle}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: TextButton.icon(
                              icon: const Icon(Icons.calendar_today_rounded, size: 14),
                              label: const Text('Ver Día', style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  _selectedDate = rem.date;
                                  _calendarMode = 'Día';
                                  _filterByDate = true;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Selector de Productos Adicionales Modal ---
  void _showPickProductModal(
    BuildContext context,
    Function(ProductService product) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final items = widget.controller.catalog.where((item) {
              if (query.isEmpty) return true;
              return item.name.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Agregar Producto a la Cita',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar en productos y servicios...',
                      prefixIcon: Icon(Icons.search_rounded),
                      isDense: true,
                    ),
                    onChanged: (v) => setModalState(() => query = v.trim()),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final item = items[idx];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.isService
                                ? AppTheme.primary.withValues(alpha: 0.15)
                                : AppTheme.accent.withValues(alpha: 0.15),
                            child: Icon(
                              item.isService ? Icons.content_cut_rounded : Icons.shopping_bag_outlined,
                              color: item.isService ? AppTheme.primary : AppTheme.accent,
                              size: 18,
                            ),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${item.category} • ${widget.controller.formatMoney(item.price)}'),
                          trailing: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
                          onTap: () {
                            Navigator.pop(ctx);
                            onSelected(item);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Modal de Selector de Clientes ---
  void _showSelectCustomerModal(
    BuildContext context,
    Function(Customer customer) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final customers = widget.controller.customers.where((c) {
              if (query.isEmpty) return true;
              final q = query.toLowerCase();
              return c.name.toLowerCase().contains(q) ||
                  c.phone.replaceAll(RegExp(r'\D'), '').contains(q.replaceAll(RegExp(r'\D'), ''));
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Seleccionar Cliente',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.person_add_rounded, size: 16),
                        label: const Text('Nuevo'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomersView(controller: widget.controller),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o teléfono...',
                      prefixIcon: Icon(Icons.search_rounded),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      isDense: true,
                    ),
                    onChanged: (v) => setModalState(() => query = v.trim()),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: customers.isEmpty
                        ? Center(
                            child: Text(
                              'No se encontraron clientes',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: customers.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final c = customers[i];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                                  child: Text(
                                    c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                                  ),
                                ),
                                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                  '${c.phone}${c.profession.isNotEmpty ? " • ${c.profession}" : ""}${c.isMother ? " • Mamá ❤️" : ""}',
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onSelected(c);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Diálogo: Agendar Nueva Cita (Con Múltiples Productos y Descuentos) ---
  void _showNewAppointmentDialog(BuildContext context, {DateTime? initialDate}) {
    final clientNameCtrl = TextEditingController();
    final clientPhoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    final controller = widget.controller;
    String? selectedCustomerId;

    ProductService? selectedService = controller.catalog.where((c) => c.isService).firstOrNull ??
        controller.catalog.firstOrNull;
    final List<AppointmentProductItem> addedProducts = [];
    double discountAmount = 0.0;
    DateTime scheduledDate = initialDate ?? DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final matchedCust = controller.findCustomer(
              name: clientNameCtrl.text,
              phone: clientPhoneCtrl.text,
            );

            final servicePrice = selectedService?.price ?? 0.0;
            final productsPrice = addedProducts.fold(0.0, (s, p) => s + p.subtotal);
            final totalCalculated = (servicePrice + productsPrice - discountAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('Agendar Nueva Cita'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Boton para seleccionar cliente registrado
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.contacts_rounded, size: 16),
                          label: const Text('Elegir de Directorio', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            _showSelectCustomerModal(context, (cust) {
                              setDialogState(() {
                                selectedCustomerId = cust.id;
                                clientNameCtrl.text = cust.name;
                                clientPhoneCtrl.text = cust.phone;
                                if (notesCtrl.text.isEmpty && cust.notes.isNotEmpty) {
                                  notesCtrl.text = cust.notes;
                                }
                              });
                            });
                          },
                        ),
                      ),
                      TextField(
                        controller: clientNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre y Apellido *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: clientPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono / WhatsApp *',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      // Feedback de detección de cliente
                      if (matchedCust != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Cliente: ${matchedCust.name} (${matchedCust.phone})',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Selector de Servicio Principal
                      DropdownButtonFormField<ProductService>(
                        initialValue: selectedService,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Servicio Principal *',
                          prefixIcon: Icon(Icons.content_cut_rounded),
                        ),
                        items: controller.catalog.where((c) => c.isService).map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              '${item.name} (${controller.formatMoney(item.price)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedService = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // SECCIÓN: MÚLTIPLES PRODUCTOS ADICIONALES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Productos Adicionales:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                            label: const Text('+ Agregar Producto', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _showPickProductModal(context, (product) {
                                setDialogState(() {
                                  final idx = addedProducts.indexWhere((p) => p.id == product.id);
                                  if (idx >= 0) {
                                    addedProducts[idx].quantity++;
                                  } else {
                                    addedProducts.add(
                                      AppointmentProductItem(
                                        id: product.id,
                                        name: product.name,
                                        price: product.price,
                                        quantity: 1,
                                        isService: product.isService,
                                      ),
                                    );
                                  }
                                });
                              });
                            },
                          ),
                        ],
                      ),

                      if (addedProducts.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: addedProducts.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                          Text(
                                            '${item.quantity}x ${controller.formatMoney(item.price)} = ${controller.formatMoney(item.subtotal)}',
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                                      onPressed: () {
                                        setDialogState(() {
                                          item.quantity--;
                                          if (item.quantity <= 0) addedProducts.remove(item);
                                        });
                                      },
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 18),
                                      onPressed: () => setDialogState(() => item.quantity++),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      // SECCIÓN: DESCUENTO
                      TextField(
                        controller: discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Descuento aplicado (\$)',
                          hintText: 'Ej: 5000',
                          prefixIcon: Icon(Icons.discount_outlined),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final d = double.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                          setDialogState(() => discountAmount = d);
                        },
                      ),
                      const SizedBox(height: 12),

                      // RESUMEN FINANCIERO EN TIEMPO REAL
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Servicio:', style: TextStyle(fontSize: 12)),
                                Text(controller.formatMoney(servicePrice), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            if (addedProducts.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Productos (${addedProducts.length}):', style: const TextStyle(fontSize: 12)),
                                  Text('+ ${controller.formatMoney(productsPrice)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                            if (discountAmount > 0) ...[
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Descuento:', style: TextStyle(fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.w600)),
                                  Text('- ${controller.formatMoney(discountAmount)}', style: const TextStyle(fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Estimado:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                Text(
                                  controller.formatMoney(totalCalculated),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Selector de Fecha y Hora
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Fecha y Hora:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  Text(
                                    DateFormat('dd/MM/yyyy - hh:mm a').format(scheduledDate),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_month_rounded, size: 14),
                              label: const Text('Cambiar', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: ctx,
                                  initialDate: scheduledDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (pickedDate != null && ctx.mounted) {
                                  final pickedTime = await showTimePicker(
                                    context: ctx,
                                    initialTime: TimeOfDay.fromDateTime(scheduledDate),
                                  );
                                  if (pickedTime != null) {
                                    setDialogState(() {
                                      scheduledDate = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notas o preferencias del cliente',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    final name = clientNameCtrl.text.trim();
                    if (name.isEmpty) return;

                    await controller.createAppointment(
                      clientName: name,
                      clientPhone: clientPhoneCtrl.text.trim(),
                      serviceName: selectedService?.name ?? 'Servicio General',
                      estimatedAmount: totalCalculated,
                      discountAmount: discountAmount,
                      items: addedProducts,
                      scheduledAt: scheduledDate,
                      notes: notesCtrl.text.trim(),
                      clientId: selectedCustomerId,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cita agendada para "$name" (${controller.formatMoney(totalCalculated)}).'),
                          backgroundColor: AppTheme.accent,
                        ),
                      );
                    }
                  },
                  child: const Text('Agendar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Diálogo: Modificar Cita (Permite cambiar día, hora, productos y descuentos) ---
  void _showEditAppointmentDialog(BuildContext context, Appointment apt) {
    final clientNameCtrl = TextEditingController(text: apt.clientName);
    final clientPhoneCtrl = TextEditingController(text: apt.clientPhone);
    final notesCtrl = TextEditingController(text: apt.notes);
    final discountCtrl = TextEditingController(
      text: apt.discountAmount > 0 ? '${apt.discountAmount.toInt()}' : '',
    );
    final controller = widget.controller;
    String? selectedCustomerId = apt.clientId;

    ProductService? selectedService = controller.catalog
            .where((c) => c.name.toLowerCase() == apt.serviceName.toLowerCase())
            .firstOrNull ??
        controller.catalog.where((c) => c.isService).firstOrNull ??
        controller.catalog.firstOrNull;

    final List<AppointmentProductItem> addedProducts = List.from(apt.items);
    double discountAmount = apt.discountAmount;
    DateTime scheduledDate = apt.scheduledAt;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final matchedCust = controller.findCustomer(
              name: clientNameCtrl.text,
              phone: clientPhoneCtrl.text,
            );

            final servicePrice = selectedService?.price ?? 0.0;
            final productsPrice = addedProducts.fold(0.0, (s, p) => s + p.subtotal);
            final totalCalculated = (servicePrice + productsPrice - discountAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.edit_calendar_rounded, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('Modificar Cita'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Boton para seleccionar otro cliente registrado
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.contacts_rounded, size: 16),
                          label: const Text('Elegir de Directorio', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            _showSelectCustomerModal(context, (cust) {
                              setDialogState(() {
                                selectedCustomerId = cust.id;
                                clientNameCtrl.text = cust.name;
                                clientPhoneCtrl.text = cust.phone;
                                if (notesCtrl.text.isEmpty && cust.notes.isNotEmpty) {
                                  notesCtrl.text = cust.notes;
                                }
                              });
                            });
                          },
                        ),
                      ),
                      TextField(
                        controller: clientNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre y Apellido *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: clientPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono / WhatsApp *',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      if (matchedCust != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Cliente: ${matchedCust.name} (${matchedCust.phone})',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Selector de Servicio Principal
                      DropdownButtonFormField<ProductService>(
                        initialValue: selectedService,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Servicio Principal',
                          prefixIcon: Icon(Icons.content_cut_rounded),
                        ),
                        items: controller.catalog.where((c) => c.isService).map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              '${item.name} (${controller.formatMoney(item.price)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedService = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // SECCIÓN: MÚLTIPLES PRODUCTOS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Productos Adicionales:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          TextButton.icon(
                            icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                            label: const Text('+ Agregar Producto', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _showPickProductModal(context, (product) {
                                setDialogState(() {
                                  final idx = addedProducts.indexWhere((p) => p.id == product.id);
                                  if (idx >= 0) {
                                    addedProducts[idx].quantity++;
                                  } else {
                                    addedProducts.add(
                                      AppointmentProductItem(
                                        id: product.id,
                                        name: product.name,
                                        price: product.price,
                                        quantity: 1,
                                        isService: product.isService,
                                      ),
                                    );
                                  }
                                });
                              });
                            },
                          ),
                        ],
                      ),

                      if (addedProducts.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: addedProducts.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                          Text(
                                            '${item.quantity}x ${controller.formatMoney(item.price)} = ${controller.formatMoney(item.subtotal)}',
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                                      onPressed: () {
                                        setDialogState(() {
                                          item.quantity--;
                                          if (item.quantity <= 0) addedProducts.remove(item);
                                        });
                                      },
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 18),
                                      onPressed: () => setDialogState(() => item.quantity++),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      // SECCIÓN: DESCUENTO
                      TextField(
                        controller: discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Descuento aplicado (\$)',
                          hintText: '0',
                          prefixIcon: Icon(Icons.discount_outlined),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final d = double.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                          setDialogState(() => discountAmount = d);
                        },
                      ),
                      const SizedBox(height: 12),

                      // RESUMEN FINANCIERO
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Servicio:', style: TextStyle(fontSize: 12)),
                                Text(controller.formatMoney(servicePrice), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            if (addedProducts.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Productos (${addedProducts.length}):', style: const TextStyle(fontSize: 12)),
                                  Text('+ ${controller.formatMoney(productsPrice)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                            if (discountAmount > 0) ...[
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Descuento:', style: TextStyle(fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.w600)),
                                  Text('- ${controller.formatMoney(discountAmount)}', style: const TextStyle(fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Estimado:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                Text(
                                  controller.formatMoney(totalCalculated),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Selector de Fecha y Hora (Cambiar Día y Hora)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_calendar_rounded, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Fecha y Hora:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  Text(
                                    DateFormat('dd/MM/yyyy - hh:mm a').format(scheduledDate),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_month_rounded, size: 14),
                              label: const Text('Cambiar', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: ctx,
                                  initialDate: scheduledDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 60)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (pickedDate != null && ctx.mounted) {
                                  final pickedTime = await showTimePicker(
                                    context: ctx,
                                    initialTime: TimeOfDay.fromDateTime(scheduledDate),
                                  );
                                  if (pickedTime != null) {
                                    setDialogState(() {
                                      scheduledDate = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notas o preferencias del cliente',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    final name = clientNameCtrl.text.trim();
                    if (name.isEmpty) return;

                    await controller.updateAppointment(
                      appointmentId: apt.id,
                      clientName: name,
                      clientPhone: clientPhoneCtrl.text.trim(),
                      serviceName: selectedService?.name ?? apt.serviceName,
                      estimatedAmount: totalCalculated,
                      discountAmount: discountAmount,
                      items: addedProducts,
                      scheduledAt: scheduledDate,
                      notes: notesCtrl.text.trim(),
                      clientId: selectedCustomerId,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cita de "$name" reprogramada correctamente.'),
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
        );
      },
    );
  }

  // --- Modal de Liquidación Flexible a Caja ---
  void _showLiquidationModal(BuildContext context, Appointment apt) {
    final controller = widget.controller;
    double extraAmount = 0.0;
    final extraNoteCtrl = TextEditingController();
    final amountPaidCtrl = TextEditingController(text: '${apt.estimatedAmount.toInt()}');
    PaymentMethod selectedMethod = PaymentMethod.cash;
    bool isPartialPayment = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;

            final totalCalculated = apt.estimatedAmount + extraAmount;
            final currentPaid = double.tryParse(amountPaidCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
            final pendingDebt = (totalCalculated - currentPaid) > 0 ? (totalCalculated - currentPaid) : 0.0;

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.price_check_rounded, color: AppTheme.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Liquidar Cita a Caja',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${apt.clientName} • ${apt.serviceName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Desglose de Base + Productos + Descuento
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Servicio Principal:', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(apt.serviceName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          if (apt.items.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            ...apt.items.map((it) => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('+ ${it.quantity}x ${it.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(controller.formatMoney(it.subtotal), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                )),
                          ],
                          if (apt.discountAmount > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Descuento aplicado:', style: TextStyle(fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.w600)),
                                Text('- ${controller.formatMoney(apt.discountAmount)}', style: const TextStyle(fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                          const Divider(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Estimado:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(
                                controller.formatMoney(apt.estimatedAmount),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cobros adicionales
                    const Text('¿Hubo cobros adicionales o propinas?', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Monto extra (\$)',
                              prefixIcon: Icon(Icons.add_rounded),
                            ),
                            onChanged: (val) {
                              final p = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              setModalState(() {
                                extraAmount = p;
                                if (!isPartialPayment) {
                                  amountPaidCtrl.text = '${(apt.estimatedAmount + extraAmount).toInt()}';
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: extraNoteCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Motivo (ej: Mascarilla)',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Total vs Parcial Switch
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  isPartialPayment = false;
                                  amountPaidCtrl.text = '${totalCalculated.toInt()}';
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isPartialPayment ? AppTheme.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Pago Total (${controller.formatMoney(totalCalculated)})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: !isPartialPayment ? Colors.white : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => isPartialPayment = true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isPartialPayment ? AppTheme.warning : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Abono Parcial / Fiado',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: isPartialPayment ? Colors.black : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isPartialPayment) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: amountPaidCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monto que abona hoy el cliente (\$)',
                          prefixIcon: Icon(Icons.payment_rounded),
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Saldo que queda pendiente:', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              controller.formatMoney(pendingDebt),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Método de Pago
                    const Text('Método de Pago:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: PaymentMethod.values.map((method) {
                        final isSel = selectedMethod == method;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                method == PaymentMethod.transfer ? 'Digital' : method.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : null,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: AppTheme.primary,
                              onSelected: (s) {
                                if (s) setModalState(() => selectedMethod = method);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Confirmar Liquidación
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          final nav = Navigator.of(ctx);
                          final sm = ScaffoldMessenger.of(context);
                          await controller.liquidateAppointment(
                            appointmentId: apt.id,
                            amountPaidNow: currentPaid,
                            pendingDebt: pendingDebt,
                            extraAmount: extraAmount,
                            extraNote: extraNoteCtrl.text.trim(),
                            paymentMethod: selectedMethod,
                          );
                          nav.pop();
                          sm.showSnackBar(
                            SnackBar(
                              content: Text(
                                pendingDebt > 0
                                    ? 'Cita liquidada: Abono de ${controller.formatMoney(currentPaid)} registrado. Quedan pendientes ${controller.formatMoney(pendingDebt)}.'
                                    : '¡Cita liquidada exitosamente por ${controller.formatMoney(currentPaid)}!',
                              ),
                              backgroundColor: AppTheme.accent,
                            ),
                          );
                        },
                        child: Text(
                          'Liquidar e Ingresar ${controller.formatMoney(currentPaid)} a Caja',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Diálogo: Abonar a Deuda ---
  void _showPayDebtDialog(BuildContext context, Appointment apt) {
    final controller = widget.controller;
    final amountCtrl = TextEditingController(text: '${apt.pendingDebt.toInt()}');
    PaymentMethod selectedMethod = PaymentMethod.cash;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            final enteredAmount = double.tryParse(amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
            final remainingAfter = (apt.pendingDebt - enteredAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.payments_rounded, color: AppTheme.error, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Abonar a Deuda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cliente: ${apt.clientName}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      'Servicio: ${apt.serviceName}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Saldo pendiente actual:', style: TextStyle(fontSize: 13)),
                          Text(
                            controller.formatMoney(apt.pendingDebt),
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.error, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Monto a recibir (\$)',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      onChanged: (_) => setDlgState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setDlgState(() {
                              amountCtrl.text = '${(apt.pendingDebt / 2).toInt()}';
                            });
                          },
                          child: const Text('50% del saldo', style: TextStyle(fontSize: 11)),
                        ),
                        TextButton(
                          onPressed: () {
                            setDlgState(() {
                              amountCtrl.text = '${apt.pendingDebt.toInt()}';
                            });
                          },
                          child: const Text('Pagar Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (remainingAfter > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Quedará debiendo: ${controller.formatMoney(remainingAfter)}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.warning, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text('Método de Pago:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: PaymentMethod.values.map((method) {
                        final isSel = selectedMethod == method;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                method == PaymentMethod.transfer ? 'Digital' : method.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : null,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: AppTheme.primary,
                              onSelected: (s) {
                                if (s) setDlgState(() => selectedMethod = method);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: enteredAmount <= 0
                      ? null
                      : () async {
                          final nav = Navigator.of(ctx);
                          final sm = ScaffoldMessenger.of(context);
                          await controller.payPendingDebt(
                            appointmentId: apt.id,
                            amountToPay: enteredAmount,
                            paymentMethod: selectedMethod,
                          );
                          nav.pop();
                          sm.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Abono de ${controller.formatMoney(enteredAmount)} registrado con éxito.',
                              ),
                              backgroundColor: AppTheme.accent,
                            ),
                          );
                        },
                  child: const Text('Registrar en Caja', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// --- Tarjeta de Cita Individual ---
class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final FlowBizController controller;
  final VoidCallback onLiquidate;
  final VoidCallback onCancel;
  final VoidCallback? onPayDebt;
  final VoidCallback? onEdit;

  const _AppointmentCard({
    required this.appointment,
    required this.controller,
    required this.onLiquidate,
    required this.onCancel,
    this.onPayDebt,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('hh:mm a').format(appointment.scheduledAt);
    final dateStr = DateFormat('dd MMM').format(appointment.scheduledAt);
    final isCompleted = appointment.status == AppointmentStatus.completed;
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    Color badgeColor;
    String badgeText;
    if (isCompleted) {
      badgeColor = AppTheme.accent;
      badgeText = appointment.pendingDebt > 0 ? 'Con Saldo Pendiente' : 'Liquidada';
    } else if (isCancelled) {
      badgeColor = AppTheme.error;
      badgeText = 'Cancelada';
    } else {
      badgeColor = AppTheme.warning;
      badgeText = 'Pendiente';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  '$timeStr ($dateStr)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: Icon(Icons.edit_calendar_rounded, size: 17, color: AppTheme.primary),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              appointment.clientName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              '${appointment.serviceName} • Tel: ${appointment.clientPhone.isEmpty ? 'N/A' : appointment.clientPhone}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),

            // Muestra productos adicionales si los tiene
            if (appointment.items.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: appointment.items.map((it) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+ ${it.quantity}x ${it.name}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Muestra descuento si se aplicó
            if (appointment.discountAmount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Descuento aplicado: - ${controller.formatMoney(appointment.discountAmount)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.error),
                ),
              ),
            ],

            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Nota: ${appointment.notes}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? 'Pagado a caja:' : 'Estimado:',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      controller.formatMoney(
                        isCompleted ? appointment.finalAmountPaid : appointment.estimatedAmount,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isCompleted ? AppTheme.accent : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                if (appointment.status == AppointmentStatus.pending) ...[
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 22),
                        tooltip: 'Modificar Cita / Cambiar Hora',
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: AppTheme.error, size: 20),
                        tooltip: 'Cancelar Cita',
                        onPressed: onCancel,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text('Liquidar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: onLiquidate,
                      ),
                    ],
                  ),
                ] else if (appointment.pendingDebt > 0) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Debe: ${controller.formatMoney(appointment.pendingDebt)}',
                          style: const TextStyle(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.payments_rounded, size: 14),
                        label: const Text('Abonar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: onPayDebt,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
