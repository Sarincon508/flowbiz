import 'package:flutter/material.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/transaction_tile.dart';
import 'past_sessions_view.dart';

class DashboardView extends StatefulWidget {
  final FlowBizController controller;
  final Function(int) onNavigateToTab;
  final VoidCallback onOpenReceivables;
  final VoidCallback onOpenCashDialog;

  const DashboardView({
    super.key,
    required this.controller,
    required this.onNavigateToTab,
    required this.onOpenReceivables,
    required this.onOpenCashDialog,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String _selectedPeriod = 'Diario';
  bool _showRecentTransactions = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;
    final isOpen = controller.isRegisterOpen;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('FlowBiz', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          // Historial de Arqueos Único (Centralizado en Dashboard)
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Historial de Arqueos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PastSessionsView(controller: controller),
                ),
              );
            },
          ),
          // Register Status Chip
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Icon(
                isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                size: 16,
                color: isOpen ? AppTheme.accent : AppTheme.error,
              ),
              label: Text(
                isOpen ? 'Caja Abierta' : 'Caja Cerrada',
                style: TextStyle(
                  color: isOpen ? AppTheme.accent : AppTheme.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              backgroundColor: (isOpen ? AppTheme.accent : AppTheme.error).withValues(alpha: 0.12),
              side: BorderSide(color: (isOpen ? AppTheme.accent : AppTheme.error).withValues(alpha: 0.3)),
              onPressed: widget.onOpenCashDialog,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cash Register Alert if closed
            if (!isOpen)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jornada no iniciada',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          Text(
                            'Realiza la apertura de caja registrando tu base en efectivo y digital.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warning,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: widget.onOpenCashDialog,
                      child: const Text('Abrir Día', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

            // Accounts Receivable Banner (Cobros pendientes)
            GestureDetector(
              onTap: widget.onOpenReceivables,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: controller.totalAccountsReceivable > 0
                      ? AppTheme.error.withValues(alpha: 0.12)
                      : AppTheme.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.totalAccountsReceivable > 0
                        ? AppTheme.error.withValues(alpha: 0.3)
                        : AppTheme.info.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (controller.totalAccountsReceivable > 0 ? AppTheme.error : AppTheme.info)
                            .withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_late_rounded,
                        color: controller.totalAccountsReceivable > 0 ? AppTheme.error : AppTheme.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.totalAccountsReceivable > 0
                                ? 'Cuentas por Cobrar Pendientes (${controller.pendingDebtAppointments.length})'
                                : 'Cuentas por Cobrar (Al día)',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            controller.totalAccountsReceivable > 0
                                ? 'Total adeudado: ${controller.formatMoney(controller.totalAccountsReceivable)}'
                                : 'No hay clientes con saldos pendientes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: controller.totalAccountsReceivable > 0 ? AppTheme.error : AppTheme.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),

            // Feature: Gráficas de Rendimiento Visual (Diario, Semanal, Mensual)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Métricas y Gráficas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: ['Diario', 'Semana', 'Mes'].map((p) {
                      final periodKey = p == 'Semana' ? 'Semanal' : (p == 'Mes' ? 'Mensual' : 'Diario');
                      final isSel = _selectedPeriod == periodKey;
                      return InkWell(
                        onTap: () => setState(() => _selectedPeriod = periodKey),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Gráfica de barras analítica
            AnalyticsChart(
              controller: controller,
              period: _selectedPeriod,
            ),

            const SizedBox(height: 18),

            // Financial Summary Grid
            const Text(
              'Balance Financiero de Hoy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.18,
              children: [
                StatCard(
                  title: 'Efectivo en Cajón',
                  value: controller.formatMoney(controller.theoreticalCashInDrawer),
                  subtitle: 'Base: ${controller.formatMoney(controller.initialCashBase)}',
                  icon: Icons.payments_rounded,
                  iconColor: AppTheme.accent,
                  onTap: () => widget.onNavigateToTab(4),
                ),
                StatCard(
                  title: 'Saldo Digital',
                  value: controller.formatMoney(controller.theoreticalDigitalInBank),
                  subtitle: 'Base: ${controller.formatMoney(controller.initialDigitalBase)}',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppTheme.info,
                  onTap: () => widget.onNavigateToTab(4),
                ),
                StatCard(
                  title: 'Ingresos Totales',
                  value: controller.formatMoney(controller.totalGrossRevenue),
                  subtitle: 'Efectivo + Digital',
                  icon: Icons.trending_up_rounded,
                  iconColor: AppTheme.primary,
                ),
                StatCard(
                  title: 'Ganancia Neta',
                  value: controller.formatMoney(controller.netProfit),
                  subtitle: 'Gastos: -${controller.formatMoney(controller.totalExpenses)}',
                  icon: Icons.account_balance_rounded,
                  iconColor: controller.netProfit >= 0 ? AppTheme.accent : AppTheme.error,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Quick Actions
            const Text(
              'Acciones Rápidas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.point_of_sale_rounded,
                    label: 'Vender',
                    color: AppTheme.primary,
                    onTap: () => widget.onNavigateToTab(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.calendar_month_rounded,
                    label: 'Citas',
                    color: AppTheme.info,
                    onTap: () => widget.onNavigateToTab(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.receipt_long_rounded,
                    label: 'Gasto',
                    color: AppTheme.error,
                    onTap: () => widget.onNavigateToTab(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.history_rounded,
                    label: 'Arqueos',
                    color: AppTheme.warning,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PastSessionsView(controller: controller)),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Feature: Movimientos Recientes bajo demanda (con botón interactivo)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 20, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Movimientos Recientes',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${controller.transactions.length}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showRecentTransactions = !_showRecentTransactions;
                          });
                        },
                        icon: Icon(
                          _showRecentTransactions ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
                        label: Text(_showRecentTransactions ? 'Ocultar' : 'Ver Lista'),
                      ),
                    ],
                  ),

                  // Si está colapsado, muestra botón directo para abrir
                  if (!_showRecentTransactions) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _showRecentTransactions = true),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: Text('Consultar últimos movimientos (${controller.transactions.length})'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],

                  // Lista expandida solo cuando el usuario lo solicita
                  if (_showRecentTransactions) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    if (controller.transactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No hay transacciones registradas hoy.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      )
                    else
                      ...controller.transactions.reversed.take(10).map((tx) {
                        return TransactionTile(
                          transaction: tx,
                          formattedAmount: controller.formatMoney(tx.amount),
                        );
                      }),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
