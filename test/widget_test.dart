import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowbiz/models/business_models.dart';
import 'package:flowbiz/providers/flowbiz_controller.dart';
import 'package:flowbiz/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FlowBiz Financial Engine & Cash Register Test', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final controller = FlowBizController(storage);

    // Initial state
    expect(controller.isRegisterOpen, false);
    expect(controller.initialCashBase, 0.0);

    // 1. Open Cash Register with $100,000 cash base and $50,000 digital base
    await controller.openRegister(100000, 50000, notes: 'Base inicial para cambio');
    expect(controller.isRegisterOpen, true);
    expect(controller.initialCashBase, 100000);
    expect(controller.initialDigitalBase, 50000);
    expect(controller.theoreticalCashInDrawer, 100000);
    expect(controller.theoreticalDigitalInBank, 50000);

    // 2. Perform POS Sale of $25,000 in cash
    final service = controller.catalog.first;
    controller.addToCart(service);
    await controller.completePosSale(PaymentMethod.cash, clientName: 'Juan Pérez');

    expect(controller.totalGrossRevenue, service.price);
    expect(controller.theoreticalCashInDrawer, 100000 + service.price);

    // 3. Liquidate an appointment with partial payment (Abono)
    final apt = controller.appointments.first;
    // Service estimated at 38000, client pays 20000 cash, leaves 18000 pending debt
    await controller.liquidateAppointment(
      appointmentId: apt.id,
      amountPaidNow: 20000,
      pendingDebt: 18000,
      extraAmount: 0,
      extraNote: '',
      paymentMethod: PaymentMethod.cash,
    );

    expect(controller.totalAccountsReceivable, 18000);
    expect(controller.theoreticalCashInDrawer, 100000 + service.price + 20000);

    // 4. Register Petty Cash Expense of $10,000 in cash
    await controller.addExpense(
      description: 'Compra de toallas desechables',
      amount: 10000,
      category: ExpenseCategory.supplies,
      paymentMethod: PaymentMethod.cash,
    );

    expect(controller.totalExpenses, 10000);
    expect(
      controller.theoreticalCashInDrawer,
      100000 + service.price + 20000 - 10000,
    );
    expect(
      controller.netProfit,
      (service.price + 20000) - 10000,
    );

    // 5. Close Register with physical cash and digital balance count
    final expectedCash = controller.theoreticalCashInDrawer;
    final expectedDigital = controller.theoreticalDigitalInBank;
    await controller.closeRegister(expectedCash, expectedDigital, notes: 'Cierre sin novedades');

    expect(controller.isRegisterOpen, false);
    expect(controller.activeSession!.discrepancy, 0.0);
    expect(controller.activeSession!.digitalDiscrepancy, 0.0);
    expect(controller.pastSessions.isNotEmpty, true);
  });

  test('Customer Database & Appointment Modification Engine', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final controller = FlowBizController(storage);

    // Initial customers loaded from initial storage
    expect(controller.customers.isNotEmpty, true);
    final initialCount = controller.customers.length;

    // 1. Comparison & Deduplication test:
    // Existing customer Carlos Mendoza (312 456 7890)
    final existing1 = controller.findCustomer(name: 'carlos mendoza');
    expect(existing1, isNotNull);
    expect(existing1!.name, 'Carlos Mendoza');

    final existingByPhone = controller.findCustomer(phone: '312-456-7890');
    expect(existingByPhone, isNotNull);
    expect(existingByPhone!.id, existing1.id);

    // 2. Schedule appointment with an existing customer name
    final scheduledDate = DateTime(2026, 10, 15, 14, 30);
    await controller.createAppointment(
      clientName: 'Carlos Mendoza',
      clientPhone: '3124567890',
      serviceName: 'Corte de Cabello Clásico',
      estimatedAmount: 25000,
      scheduledAt: scheduledDate,
      notes: 'Cita de prueba',
    );

    // Customer count should NOT increase since Carlos already exists
    expect(controller.customers.length, initialCount);
    final createdApt = controller.appointments.last;
    expect(createdApt.clientId, existing1.id);
    expect(createdApt.serviceName, 'Corte de Cabello Clásico');

    // 3. Schedule appointment with a BRAND NEW customer
    await controller.createAppointment(
      clientName: 'Laura Restrepo',
      clientPhone: '300 123 4567',
      serviceName: 'Limpieza Facial Profunda',
      estimatedAmount: 45000,
      scheduledAt: DateTime(2026, 10, 16, 9, 0),
    );

    // Customer count should increase by 1
    expect(controller.customers.length, initialCount + 1);
    final lauraCust = controller.findCustomer(phone: '3001234567');
    expect(lauraCust, isNotNull);
    expect(lauraCust!.name, 'Laura Restrepo');

    // 4. Modify appointment (change date, time, service, notes) WITHOUT deleting
    final aptToModify = controller.appointments.last;
    final aptId = aptToModify.id;
    final newScheduledDate = DateTime(2026, 10, 20, 16, 45);

    await controller.updateAppointment(
      appointmentId: aptId,
      clientName: 'Laura Restrepo',
      clientPhone: '300 123 4567',
      serviceName: 'Combo Ejecutivo (Corte + Barba)',
      estimatedAmount: 38000,
      scheduledAt: newScheduledDate,
      notes: 'Cambio de hora solicitado por WhatsApp',
    );

    final modifiedApt = controller.appointments.firstWhere((a) => a.id == aptId);
    expect(modifiedApt.scheduledAt, newScheduledDate);
    expect(modifiedApt.serviceName, 'Combo Ejecutivo (Corte + Barba)');
    expect(modifiedApt.estimatedAmount, 38000);
    expect(modifiedApt.notes, 'Cambio de hora solicitado por WhatsApp');

    // 5. Edit customer info and verify it syncs to appointment
    lauraCust.name = 'Laura Restrepo Gómez';
    lauraCust.phone = '300 999 8888';
    await controller.updateCustomer(lauraCust);

    final syncedApt = controller.appointments.firstWhere((a) => a.id == aptId);
    expect(syncedApt.clientName, 'Laura Restrepo Gómez');
    expect(syncedApt.clientPhone, '300 999 8888');
  });

  test('Multi-Products, Discounts, and Special Reminders Engine Test', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final controller = FlowBizController(storage);

    // 1. Customer metadata: birthDate, isMother, profession
    final newCust = await controller.findOrCreateCustomer(
      name: 'Valeria Ospina',
      phone: '311 555 4433',
      birthDate: DateTime(1992, 9, 21),
      isMother: true,
      profession: 'Médica',
      notes: 'Doctora pediatra',
    );

    expect(newCust.isMother, true);
    expect(newCust.profession, 'Médica');
    expect(newCust.birthDate, isNotNull);
    expect(newCust.age, greaterThanOrEqualTo(33));

    // 2. Special days reminders for today (Sept 21)
    final todayReminders = controller.getSpecialRemindersForDate(DateTime(2026, 9, 21));
    expect(todayReminders.any((r) => r.type == SpecialDayType.birthday), true);

    // Profession day test (Dec 3 for Médico)
    final docDayReminders = controller.getSpecialRemindersForDate(DateTime(2026, 12, 3));
    expect(docDayReminders.any((r) => r.type == SpecialDayType.professionDay), true);

    // Mother's Day calculation
    final mothersDay = controller.getMothersDay(2026);
    final mothersDayReminders = controller.getSpecialRemindersForDate(mothersDay);
    expect(mothersDayReminders.any((r) => r.type == SpecialDayType.motherDay), true);

    // 3. Appointment with multiple products and discount
    final product1 = AppointmentProductItem(
      id: 'prd-1',
      name: 'Cera Fijadora Mate',
      price: 28000,
      quantity: 2,
    );
    final product2 = AppointmentProductItem(
      id: 'prd-3',
      name: 'Bebida Energizante',
      price: 6000,
      quantity: 1,
    );

    final serviceBase = 25000.0;
    final productsTotal = product1.subtotal + product2.subtotal; // 56000 + 6000 = 62000
    final discount = 10000.0;
    final estimatedTotal = serviceBase + productsTotal - discount; // 25000 + 62000 - 10000 = 77000

    await controller.createAppointment(
      clientName: newCust.name,
      clientPhone: newCust.phone,
      serviceName: 'Corte de Cabello Clásico',
      estimatedAmount: estimatedTotal,
      discountAmount: discount,
      items: [product1, product2],
      scheduledAt: DateTime(2026, 9, 22, 11, 0),
      clientId: newCust.id,
    );

    final apt = controller.appointments.last;
    expect(apt.items.length, 2);
    expect(apt.discountAmount, 10000.0);
    expect(apt.estimatedAmount, 77000.0);

    // 4. POS Sale with Discount
    await controller.openRegister(50000, 0);
    final p = controller.catalog.first;
    controller.addToCart(p);
    final cartSubtotal = controller.cartTotal;
    const posDiscount = 5000.0;

    await controller.completePosSale(
      PaymentMethod.cash,
      clientName: 'Cliente Promoción',
      discountAmount: posDiscount,
    );

    expect(controller.transactions.first.amount, cartSubtotal - posDiscount);
    expect(controller.transactions.first.description, contains('Descuento'));
  });
}
