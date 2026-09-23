import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/business_models.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class PastSessionsView extends StatelessWidget {
  final FlowBizController controller;

  const PastSessionsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastSessions = controller.pastSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Arqueos'),
      ),
      body: pastSessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 64,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No hay arqueos archivados aún',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cuando realices el cierre del día, los arqueos y sus movimientos aparecerán aquí.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pastSessions.length,
              itemBuilder: (context, idx) {
                final session = pastSessions[idx];
                final openTimeStr = DateFormat('dd/MM/yyyy - hh:mm a').format(session.openedAt);
                final closeTimeStr = session.closedAt != null
                    ? DateFormat('hh:mm a').format(session.closedAt!)
                    : 'Cierre registrado';

                final isCashBalanced = session.discrepancy == 0;
                final isDigitalBalanced = session.digitalDiscrepancy == 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    onTap: () => _showSessionDetailsModal(context, session),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.archive_rounded, color: AppTheme.primary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      openTimeStr,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                    ),
                                    Text(
                                      'Cierre: $closeTimeStr • ${session.sessionTransactions.length} movimientos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                            ],
                          ),
                          const Divider(height: 20),

                          // Cash Discrepancy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.payments_outlined, size: 16, color: Color(0xFF64748B)),
                                  SizedBox(width: 6),
                                  Text('Efectivo en Caja:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (isCashBalanced
                                          ? AppTheme.accent
                                          : (session.discrepancy > 0 ? AppTheme.info : AppTheme.error))
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isCashBalanced
                                      ? 'Cuadrada (${controller.formatMoney(session.physicalCashCounted)})'
                                      : (session.discrepancy > 0
                                          ? 'Sobrante: +${controller.formatMoney(session.discrepancy)}'
                                          : 'Faltante: -${controller.formatMoney(session.discrepancy.abs())}'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isCashBalanced
                                        ? AppTheme.accent
                                        : (session.discrepancy > 0 ? AppTheme.info : AppTheme.error),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Digital Discrepancy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.credit_card_outlined, size: 16, color: Color(0xFF64748B)),
                                  SizedBox(width: 6),
                                  Text('Medios Digitales:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (isDigitalBalanced
                                          ? AppTheme.accent
                                          : (session.digitalDiscrepancy > 0 ? AppTheme.info : AppTheme.error))
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isDigitalBalanced
                                      ? 'Cuadrado (${controller.formatMoney(session.physicalDigitalCounted)})'
                                      : (session.digitalDiscrepancy > 0
                                          ? 'Sobrante: +${controller.formatMoney(session.digitalDiscrepancy)}'
                                          : 'Faltante: -${controller.formatMoney(session.digitalDiscrepancy.abs())}'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDigitalBalanced
                                        ? AppTheme.accent
                                        : (session.digitalDiscrepancy > 0 ? AppTheme.info : AppTheme.error),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (session.closingNotes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Nota: ${session.closingNotes}',
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
                  ),
                );
              },
            ),
    );
  }

  void _showSessionDetailsModal(BuildContext context, CashRegisterSession session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.88,
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalle de Arqueo y Movimientos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy - hh:mm a').format(session.openedAt),
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

              // Summary Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Base Efectivo Inicial:'),
                        Text(controller.formatMoney(session.initialCash), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Base Digital Inicial:'),
                        Text(controller.formatMoney(session.initialDigital), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Efectivo Contado al Cierre:'),
                        Text(controller.formatMoney(session.physicalCashCounted), style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo Digital al Cierre:'),
                        Text(controller.formatMoney(session.physicalDigitalCounted), style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Movimientos del Día (${session.sessionTransactions.length})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: session.sessionTransactions.isEmpty
                    ? const Center(
                        child: Text('No se registraron movimientos en esta jornada.'),
                      )
                    : ListView.builder(
                        itemCount: session.sessionTransactions.length,
                        itemBuilder: (context, i) {
                          final tx = session.sessionTransactions[i];
                          return TransactionTile(
                            transaction: tx,
                            formattedAmount: controller.formatMoney(tx.amount),
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
}
