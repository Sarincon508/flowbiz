import 'package:flutter/material.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';
import 'dashboard_view.dart';
import 'pos_view.dart';
import 'agenda_view.dart';
import 'expenses_view.dart';
import 'cash_register_view.dart';
import 'receivables_modal.dart';

class HomeScreen extends StatefulWidget {
  final FlowBizController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final screens = [
          DashboardView(
            controller: controller,
            onNavigateToTab: _onNavigateToTab,
            onOpenReceivables: () => ReceivablesModal.show(context, controller),
            onOpenCashDialog: () => _onNavigateToTab(4),
          ),
          PosView(controller: controller),
          AgendaView(controller: controller),
          ExpensesView(controller: controller),
          CashRegisterView(controller: controller),
        ];

        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _currentIndex != 0) {
              setState(() => _currentIndex = 0);
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigateToTab,
              backgroundColor: Theme.of(context).cardColor,
              indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primary),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: controller.cartCount > 0,
                    label: Text('${controller.cartCount}'),
                    backgroundColor: AppTheme.accent,
                    child: const Icon(Icons.point_of_sale_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: controller.cartCount > 0,
                    label: Text('${controller.cartCount}'),
                    backgroundColor: AppTheme.accent,
                    child: const Icon(Icons.point_of_sale_rounded, color: AppTheme.primary),
                  ),
                  label: 'POS',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: controller.pendingDebtAppointments.isNotEmpty,
                    backgroundColor: AppTheme.warning,
                    child: const Icon(Icons.calendar_month_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: controller.pendingDebtAppointments.isNotEmpty,
                    backgroundColor: AppTheme.warning,
                    child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                  ),
                  label: 'Agenda',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.error),
                  label: 'Egresos',
                ),
                NavigationDestination(
                  icon: Icon(
                    controller.isRegisterOpen ? Icons.lock_open_outlined : Icons.lock_outline,
                  ),
                  selectedIcon: Icon(
                    controller.isRegisterOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: controller.isRegisterOpen ? AppTheme.accent : AppTheme.error,
                  ),
                  label: 'Caja',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
