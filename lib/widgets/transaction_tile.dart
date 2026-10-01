import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/business_models.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final String formattedAmount;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.formattedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('hh:mm a - dd/MM').format(transaction.timestamp);

    IconData iconData;
    Color iconColor;
    String sign;
    Color amountColor;

    if (transaction.isExpense) {
      iconData = Icons.arrow_outward_rounded;
      iconColor = AppTheme.error;
      sign = '-';
      amountColor = AppTheme.error;
    } else if (transaction.type == TransactionType.initialBalance) {
      iconData = Icons.account_balance_wallet_rounded;
      iconColor = AppTheme.info;
      sign = '+';
      amountColor = AppTheme.info;
    } else if (transaction.type == TransactionType.debtPayment) {
      iconData = Icons.payments_rounded;
      iconColor = AppTheme.warning;
      sign = '+';
      amountColor = AppTheme.accent;
    } else {
      iconData = Icons.south_west_rounded;
      iconColor = AppTheme.accent;
      sign = '+';
      amountColor = AppTheme.accent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        transaction.paymentMethod.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                if (transaction.extraNotes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.extraNotes,
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
          const SizedBox(width: 8),
          Text(
            '$sign $formattedAmount',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
