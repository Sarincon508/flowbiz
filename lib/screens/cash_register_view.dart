import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/business_models.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class CashRegisterView extends StatefulWidget {
  final FlowBizController controller;

  const CashRegisterView({super.key, required this.controller});

  @override
  State<CashRegisterView> createState() => _CashRegisterViewState();
}

class _CashRegisterViewState extends State<CashRegisterView> {
  final _initialBaseCtrl = TextEditingController(text: '100000');
  final _initialDigitalCtrl = TextEditingController(text: '50000');
  final _openNotesCtrl = TextEditingController();

  final _physicalCashCtrl = TextEditingController();
  final _physicalDigitalCtrl = TextEditingController();
  final _closingNotesCtrl = TextEditingController();

  @override
  void dispose() {
    _initialBaseCtrl.dispose();
    _initialDigitalCtrl.dispose();
    _openNotesCtrl.dispose();
    _physicalCashCtrl.dispose();
    _physicalDigitalCtrl.dispose();
    _closingNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;
    final isOpen = controller.isRegisterOpen;
    final session = controller.activeSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja y Arqueo Doble'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: !isOpen
            ? _buildOpenRegisterCard(context, isDark, controller, session)
            : _buildActiveRegisterAudit(context, isDark, controller, session!),
      ),
    );
  }

  // --- Vista 1: Formulario de Apertura de Jornada con Efectivo y Digital ---
  Widget _buildOpenRegisterCard(
    BuildContext context,
    bool isDark,
    FlowBizController controller,
    dynamic lastSession,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_open_rounded, color: AppTheme.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apertura del Día',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Registra la base física y el saldo digital para habilitar la jornada',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Base física
              const Text(
                '1. Efectivo Físico en Cajón',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _initialBaseCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Base inicial en efectivo (\$)',
                  hintText: 'ej: 100000',
                  prefixIcon: Icon(Icons.monetization_on_rounded, color: AppTheme.accent),
                ),
              ),
              const SizedBox(height: 16),

              // Saldo digital inicial
              const Text(
                '2. Saldo en Cuentas Digitales (Nequi / Daviplata / Banco)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _initialDigitalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial digital (\$)',
                  hintText: 'ej: 50000',
                  prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.info),
                ),
              ),
              const SizedBox(height: 16),

              // Notas
              TextField(
                controller: _openNotesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas de apertura (Opcional)',
                  hintText: 'ej: Cambio en billetes de 10k y 20k',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.key_rounded),
                  label: const Text('Abrir Caja e Iniciar Jornada'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  onPressed: () async {
                    final baseCash = double.tryParse(_initialBaseCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                    final baseDigital = double.tryParse(_initialDigitalCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

                    await controller.openRegister(
                      baseCash,
                      baseDigital,
                      notes: _openNotesCtrl.text.trim(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Caja abierta exitosamente! Efectivo físico y digital registrados.'),
                          backgroundColor: AppTheme.accent,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        if (lastSession != null && lastSession.isClosed) ...[
          const SizedBox(height: 20),
          const Text('Último Cierre de Jornada Registrado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fecha de Cierre:'),
                      Text(
                        lastSession.closedAt != null
                            ? DateFormat('dd/MM/yyyy hh:mm a').format(lastSession.closedAt!)
                            : 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Efectivo Físico Contado:'),
                      Text(
                        controller.formatMoney(lastSession.physicalCashCounted),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saldo Digital Verificado:'),
                      Text(
                        controller.formatMoney(lastSession.physicalDigitalCounted),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.info),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- Vista 2: Arqueo en Vivo y Cierre de Jornada Asistido (Efectivo + Digital) ---
  Widget _buildActiveRegisterAudit(
    BuildContext context,
    bool isDark,
    FlowBizController controller,
    CashRegisterSession session,
  ) {
    final expectedCash = controller.theoreticalCashInDrawer;
    final expectedDigital = controller.theoreticalDigitalInBank;

    final cashCounted = double.tryParse(_physicalCashCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    final digitalCounted = double.tryParse(_physicalDigitalCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

    final diffCash = cashCounted - expectedCash;
    final diffDigital = digitalCounted - expectedDigital;

    final hasEnteredCash = _physicalCashCtrl.text.isNotEmpty;
    final hasEnteredDigital = _physicalDigitalCtrl.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Caja en Operación', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(
                      'Abierta: ${DateFormat('hh:mm a - dd MMM').format(session.openedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 1. Conciliación de Efectivo Físico
        const Text('1. Conciliación de Efectivo en Cajón', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMathRow(
                  label: 'Base Inicial Efectivo:',
                  value: controller.formatMoney(controller.initialCashBase),
                  color: AppTheme.info,
                  sign: '',
                ),
                const SizedBox(height: 6),
                _buildMathRow(
                  label: '(+) Entradas en Efectivo:',
                  value: controller.formatMoney(controller.cashInflow),
                  color: AppTheme.accent,
                  sign: '+',
                ),
                const SizedBox(height: 6),
                _buildMathRow(
                  label: '(-) Egresos / Gastos en Efectivo:',
                  value: controller.formatMoney(controller.cashOutflow),
                  color: AppTheme.error,
                  sign: '-',
                ),
                const Divider(height: 20, thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('(=) Efectivo Teórico en Cajón:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(
                      controller.formatMoney(expectedCash),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Conciliación de Medios Digitales
        const Text('2. Conciliación Cuentas Digitales (Nequi / Banco)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 8),
        Card(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMathRow(
                  label: 'Saldo Inicial Digital:',
                  value: controller.formatMoney(controller.initialDigitalBase),
                  color: AppTheme.info,
                  sign: '',
                ),
                const SizedBox(height: 6),
                _buildMathRow(
                  label: '(+) Recaudos Digitales (Nequi/Transferencias):',
                  value: controller.formatMoney(controller.digitalInflow),
                  color: AppTheme.accent,
                  sign: '+',
                ),
                const SizedBox(height: 6),
                _buildMathRow(
                  label: '(-) Pagos / Egresos Digitales:',
                  value: controller.formatMoney(controller.digitalOutflow),
                  color: AppTheme.error,
                  sign: '-',
                ),
                const Divider(height: 20, thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('(=) Saldo Digital Esperado en App:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(
                      controller.formatMoney(expectedDigital),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.info),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 3. Formulario de Arqueo Doble de Cierre
        const Text('3. Arqueo y Conteo de Cierre del Día', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresa el dinero físico contado y el saldo actual de tu app Nequi/Banco:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),

                // Conteo efectivo
                TextField(
                  controller: _physicalCashCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Efectivo físico contado en cajón (\$)',
                    prefixIcon: const Icon(Icons.point_of_sale_rounded, color: AppTheme.accent),
                    suffixIcon: hasEnteredCash
                        ? Icon(
                            diffCash == 0 ? Icons.check_circle : Icons.warning_amber,
                            color: diffCash == 0 ? AppTheme.accent : (diffCash > 0 ? AppTheme.info : AppTheme.error),
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (hasEnteredCash) ...[
                  const SizedBox(height: 6),
                  Text(
                    diffCash == 0
                        ? '✓ Efectivo físico cuadra exacto.'
                        : (diffCash > 0
                            ? 'Sobrante en efectivo: +${controller.formatMoney(diffCash)}'
                            : 'Faltante en efectivo: -${controller.formatMoney(diffCash.abs())}'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: diffCash == 0 ? AppTheme.accent : (diffCash > 0 ? AppTheme.info : AppTheme.error),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Conteo digital
                TextField(
                  controller: _physicalDigitalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Saldo actual visto en Nequi / App Bancaria (\$)',
                    prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.info),
                    suffixIcon: hasEnteredDigital
                        ? Icon(
                            diffDigital == 0 ? Icons.check_circle : Icons.warning_amber,
                            color: diffDigital == 0 ? AppTheme.accent : (diffDigital > 0 ? AppTheme.info : AppTheme.error),
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (hasEnteredDigital) ...[
                  const SizedBox(height: 6),
                  Text(
                    diffDigital == 0
                        ? '✓ Saldo digital cuadra exacto.'
                        : (diffDigital > 0
                            ? 'Sobrante en digital: +${controller.formatMoney(diffDigital)}'
                            : 'Faltante en digital: -${controller.formatMoney(diffDigital.abs())}'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: diffDigital == 0 ? AppTheme.accent : (diffDigital > 0 ? AppTheme.info : AppTheme.error),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                TextField(
                  controller: _closingNotesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones del arqueo (Opcional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón Cierre
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock_rounded),
                    label: const Text('Completar Arqueo y Cerrar Jornada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    onPressed: () async {
                      if (!hasEnteredCash || !hasEnteredDigital) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor ingresa tanto el conteo de efectivo físico como el saldo digital.'),
                          ),
                        );
                        return;
                      }

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('¿Confirmar Cierre y Arqueo?'),
                          content: Text(
                            'Se archivará el arqueo de la jornada con:\n\n'
                            '• Efectivo: ${controller.formatMoney(cashCounted)} (${diffCash == 0 ? "Cuadrado" : (diffCash > 0 ? "Sobrante +${controller.formatMoney(diffCash)}" : "Faltante -${controller.formatMoney(diffCash.abs())}")})\n'
                            '• Digital: ${controller.formatMoney(digitalCounted)} (${diffDigital == 0 ? "Cuadrado" : (diffDigital > 0 ? "Sobrante +${controller.formatMoney(diffDigital)}" : "Faltante -${controller.formatMoney(diffDigital.abs())}")})',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Confirmar y Archivar'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await controller.closeRegister(
                          cashCounted,
                          digitalCounted,
                          notes: _closingNotesCtrl.text.trim(),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Arqueo archivado y jornada cerrada exitosamente!'),
                              backgroundColor: AppTheme.accent,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 4. Movimientos realizados en la jornada en curso
        Text(
          'Movimientos del Día (${controller.transactions.length})',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 8),

        if (controller.transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No se han registrado movimientos en esta jornada aún.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.transactions.length,
            itemBuilder: (context, idx) {
              final tx = controller.transactions[controller.transactions.length - 1 - idx];
              return TransactionTile(
                transaction: tx,
                formattedAmount: controller.formatMoney(tx.amount),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMathRow({
    required String label,
    required String value,
    required Color color,
    required String sign,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(
          '$sign $value',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color),
        ),
      ],
    );
  }
}
