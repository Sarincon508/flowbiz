import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/business_models.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';

class ExpensesView extends StatelessWidget {
  final FlowBizController controller;

  const ExpensesView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseTransactions = controller.transactions.where((t) => t.isExpense).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Egresos y Facturas'),
        // Solo un botón: se quitó el botón redundante del AppBar
      ),
      body: Column(
        children: [
          // Total Expenses Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.error.withValues(alpha: 0.15),
                  AppTheme.error.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_outward_rounded, color: AppTheme.error, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Egresos Registrados',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          controller.formatMoney(controller.totalExpenses),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Efectivo caja: ${controller.formatMoney(controller.cashOutflow)} • Digital: ${controller.formatMoney(controller.digitalOutflow)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expenses List (Custom non-overflow layout)
          Expanded(
            child: expenseTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay egresos registrados aún',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: expenseTransactions.length,
                    itemBuilder: (context, idx) {
                      final tx = expenseTransactions[expenseTransactions.length - 1 - idx];
                      final timeStr = DateFormat('dd/MM - hh:mm a').format(tx.timestamp);
                      final hasReceipt = tx.receiptImagePath.isNotEmpty && File(tx.receiptImagePath).existsSync();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => _showExpenseDetailsDialog(context, tx),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon or Photo thumbnail
                                if (hasReceipt)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(tx.receiptImagePath),
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.error.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.receipt_outlined, color: AppTheme.error, size: 22),
                                  ),
                                const SizedBox(width: 12),

                                // Main Content (Flexible & Overflow Safe)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.description,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              tx.paymentMethod.label,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              timeStr,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (hasReceipt) ...[
                                        const SizedBox(height: 3),
                                        const Row(
                                          children: [
                                            Icon(Icons.attach_file_rounded, size: 12, color: AppTheme.accent),
                                            SizedBox(width: 2),
                                            Text(
                                              'Comprobante adjunto',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.accent),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (tx.extraNotes.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          tx.extraNotes,
                                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Amount (Right-aligned, fitted to avoid any overflow)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '- ${controller.formatMoney(tx.amount)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: AppTheme.error,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Ver detalle',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Único botón visible para registrar gastos
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.error,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registrar Gasto'),
        onPressed: () => _showAddExpenseDialog(context),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final conceptCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    ExpenseCategory selectedCategory = ExpenseCategory.supplies;
    PaymentMethod selectedMethod = PaymentMethod.cash;
    String? capturedPhotoPath;

    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Registrar Gasto / Factura'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: conceptCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Concepto del gasto *',
                        hintText: 'ej: Champú, Servicios, Toallas',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Monto a pagar (\$) *',
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ExpenseCategory>(
                      initialValue: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: ExpenseCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.label, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PaymentMethod>(
                      initialValue: selectedMethod,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Pagado desde:',
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      items: PaymentMethod.values.map((pm) {
                        return DropdownMenuItem(
                          value: pm,
                          child: Text(
                            pm == PaymentMethod.cash ? 'Efectivo de Caja' : pm.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'No. Factura / Observaciones (Opcional)',
                        prefixIcon: Icon(Icons.receipt_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Feature: Subir comprobante / Foto opcional
                    const Text(
                      'Comprobante / Foto de Factura (Opcional):',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    if (capturedPhotoPath != null) ...[
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accent),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(
                                File(capturedPhotoPath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const CircleAvatar(
                              backgroundColor: Colors.black54,
                              radius: 14,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                            onPressed: () => setDialogState(() => capturedPhotoPath = null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt_rounded, size: 18),
                              label: const Text('Cámara'),
                              onPressed: () async {
                                final photo = await picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 85,
                                );
                                if (photo != null) {
                                  setDialogState(() => capturedPhotoPath = photo.path);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.photo_library_rounded, size: 18),
                              label: const Text('Galería'),
                              onPressed: () async {
                                final photo = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 85,
                                );
                                if (photo != null) {
                                  setDialogState(() => capturedPhotoPath = photo.path);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                  onPressed: () {
                    final concept = conceptCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    if (concept.isEmpty || amount <= 0) return;

                    controller.addExpense(
                      description: concept,
                      amount: amount,
                      category: selectedCategory,
                      paymentMethod: selectedMethod,
                      notes: notesCtrl.text.trim(),
                      receiptImagePath: capturedPhotoPath ?? '',
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Guardar Gasto'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExpenseDetailsDialog(BuildContext context, Transaction tx) {
    final hasReceipt = tx.receiptImagePath.isNotEmpty && File(tx.receiptImagePath).existsSync();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppTheme.error, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Detalle del Egreso', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.formatMoney(tx.amount),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppTheme.error),
                ),
                const SizedBox(height: 12),
                _detailRow('Medio de pago:', tx.paymentMethod.label),
                _detailRow('Fecha y hora:', DateFormat('dd/MM/yyyy - hh:mm a').format(tx.timestamp)),
                if (tx.extraNotes.isNotEmpty) _detailRow('Observaciones:', tx.extraNotes),
                const SizedBox(height: 14),

                const Text('Factura / Comprobante:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                if (hasReceipt)
                  GestureDetector(
                    onTap: () {
                      // Vista completa
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              InteractiveViewer(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(tx.receiptImagePath)),
                                ),
                              ),
                              IconButton(
                                icon: const CircleAvatar(
                                  backgroundColor: Colors.black87,
                                  child: Icon(Icons.close, color: Colors.white),
                                ),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(tx.receiptImagePath),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Sin comprobante fotográfico adjunto', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Flexible(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
