import 'package:flutter/material.dart';
import '../models/business_models.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';

class AnalyticsChart extends StatelessWidget {
  final FlowBizController controller;
  final String period; // 'Diario', 'Semanal', 'Mensual'

  const AnalyticsChart({
    super.key,
    required this.controller,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final data = _computePeriodData();
    double maxVal = 10000;
    for (final item in data) {
      if (item.income > maxVal) maxVal = item.income;
      if (item.expense > maxVal) maxVal = item.expense;
    }

    double totalPeriodIncome = 0;
    double totalPeriodExpense = 0;
    for (final item in data) {
      totalPeriodIncome += item.income;
      totalPeriodExpense += item.expense;
    }
    final netProfit = totalPeriodIncome - totalPeriodExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Summary Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingresos $period',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    controller.formatMoney(totalPeriodIncome),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              Container(
                height: 32,
                width: 1,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gastos $period',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    controller.formatMoney(totalPeriodExpense),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
              Container(
                height: 32,
                width: 1,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Margen Neto',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    controller.formatMoney(netProfit),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: netProfit >= 0 ? AppTheme.primary : AppTheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Chart Bars Container
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.map((item) {
                final incomeHeight = maxVal > 0 ? (item.income / maxVal) * 95 : 0.0;
                final expenseHeight = maxVal > 0 ? (item.expense / maxVal) * 95 : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Income Bar (Green)
                        Container(
                          width: period == 'Semanal' ? 14 : (period == 'Diario' ? 22 : 28),
                          height: (incomeHeight < 4 && item.income > 0) ? 4.0 : (incomeHeight == 0 ? 3.0 : incomeHeight),
                          decoration: BoxDecoration(
                            color: item.income > 0 ? AppTheme.accent : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 3),
                        // Expense Bar (Red)
                        Container(
                          width: period == 'Semanal' ? 14 : (period == 'Diario' ? 22 : 28),
                          height: (expenseHeight < 4 && item.expense > 0) ? 4.0 : (expenseHeight == 0 ? 3.0 : expenseHeight),
                          decoration: BoxDecoration(
                            color: item.expense > 0 ? AppTheme.error : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppTheme.accent, 'Ingresos'),
              const SizedBox(width: 16),
              _legendDot(AppTheme.error, 'Gastos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  List<_ChartPoint> _computePeriodData() {
    final allTx = <Transaction>[
      ...controller.transactions,
    ];
    // Also include past sessions transactions if available
    for (final session in controller.pastSessions) {
      allTx.addAll(session.sessionTransactions);
    }

    final now = DateTime.now();

    if (period == 'Diario') {
      // 4 Time blocks of today: Mañana (8-12), Mediodía (12-16), Tarde (16-20), Noche (20-24)
      final blocks = [
        _ChartPoint(label: '8-12h'),
        _ChartPoint(label: '12-16h'),
        _ChartPoint(label: '16-20h'),
        _ChartPoint(label: '20-24h'),
      ];

      for (final tx in controller.transactions) {
        final h = tx.timestamp.hour;
        int idx = 0;
        if (h >= 8 && h < 12) {
          idx = 0;
        } else if (h >= 12 && h < 16) {
          idx = 1;
        } else if (h >= 16 && h < 20) {
          idx = 2;
        } else {
          idx = 3;
        }

        if (tx.isExpense) {
          blocks[idx].expense += tx.amount;
        } else if (tx.type != TransactionType.initialBalance) {
          blocks[idx].income += tx.amount;
        }
      }
      return blocks;
    } else if (period == 'Semanal') {
      // Last 7 days: Lun to Dom or 7 days back
      final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final points = List.generate(7, (i) => _ChartPoint(label: days[i]));

      for (final tx in allTx) {
        final diffDays = now.difference(tx.timestamp).inDays;
        if (diffDays >= 0 && diffDays < 7) {
          final weekdayIdx = (tx.timestamp.weekday - 1) % 7;
          if (tx.isExpense) {
            points[weekdayIdx].expense += tx.amount;
          } else if (tx.type != TransactionType.initialBalance) {
            points[weekdayIdx].income += tx.amount;
          }
        }
      }
      return points;
    } else {
      // Mensual: 4 Weeks (Sem 1, Sem 2, Sem 3, Sem 4)
      final weeks = [
        _ChartPoint(label: 'Sem 1'),
        _ChartPoint(label: 'Sem 2'),
        _ChartPoint(label: 'Sem 3'),
        _ChartPoint(label: 'Sem 4'),
      ];

      for (final tx in allTx) {
        if (tx.timestamp.month == now.month && tx.timestamp.year == now.year) {
          final day = tx.timestamp.day;
          int wIdx = ((day - 1) ~/ 7).clamp(0, 3);
          if (tx.isExpense) {
            weeks[wIdx].expense += tx.amount;
          } else if (tx.type != TransactionType.initialBalance) {
            weeks[wIdx].income += tx.amount;
          }
        }
      }
      return weeks;
    }
  }
}

class _ChartPoint {
  final String label;
  double income = 0.0;
  double expense = 0.0;

  _ChartPoint({required this.label});
}
