import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/business_models.dart';
import '../services/storage_service.dart';

class FlowBizController extends ChangeNotifier {
  final StorageService _storage;
  final Uuid _uuid = const Uuid();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  FlowBizController(this._storage) {
    _loadData();
  }

  CashRegisterSession? _activeSession;
  List<CashRegisterSession> _pastSessions = [];
  List<Transaction> _transactions = [];
  List<Appointment> _appointments = [];
  List<ProductService> _catalog = [];
  List<String> _categories = [];
  List<Customer> _customers = [];
  final List<CartItem> _cart = [];

  // Getters
  CashRegisterSession? get activeSession => _activeSession;
  bool get isRegisterOpen => _activeSession != null && !_activeSession!.isClosed;
  List<CashRegisterSession> get pastSessions => List.unmodifiable(_pastSessions.reversed);
  List<Transaction> get transactions => List.unmodifiable(_transactions.reversed);
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  List<ProductService> get catalog => List.unmodifiable(_catalog);
  List<String> get categories => List.unmodifiable(_categories);
  List<Customer> get customers => List.unmodifiable(_customers);
  List<CartItem> get cart => List.unmodifiable(_cart);

  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  String formatMoney(num amount) => _currencyFormat.format(amount);

  void refresh() => notifyListeners();

  void _loadData() {
    _activeSession = _storage.getActiveSession();
    _pastSessions = _storage.getPastSessions();
    _transactions = _storage.getTransactions();
    _appointments = _storage.getAppointments();
    _catalog = _storage.getCatalog();
    _categories = _storage.getCategories();
    _customers = _storage.getCustomers();
    notifyListeners();
  }

  // --- Financial Balances & Metrics ---
  double get initialCashBase => _activeSession?.initialCash ?? 0.0;
  double get initialDigitalBase => _activeSession?.initialDigital ?? 0.0;

  double get cashInflow {
    return _transactions
        .where((t) =>
            !t.isExpense &&
            t.type != TransactionType.initialBalance &&
            t.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get cashOutflow {
    return _transactions
        .where((t) => t.isExpense && t.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Efectivo teórico exacto que debe haber físicamente en el cajón de dinero
  double get theoreticalCashInDrawer => initialCashBase + cashInflow - cashOutflow;

  double get digitalInflow {
    return _transactions
        .where((t) =>
            !t.isExpense &&
            t.type != TransactionType.initialBalance &&
            t.paymentMethod != PaymentMethod.cash)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get digitalOutflow {
    return _transactions
        .where((t) => t.isExpense && t.paymentMethod != PaymentMethod.cash)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Saldo digital esperado (ej: Nequi, Daviplata, Bancos)
  double get theoreticalDigitalInBank => initialDigitalBase + digitalInflow - digitalOutflow;

  double get totalGrossRevenue {
    return _transactions
        .where((t) => !t.isExpense && t.type != TransactionType.initialBalance)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netProfit => totalGrossRevenue - totalExpenses;

  double get totalAccountsReceivable {
    return _appointments
        .where((a) => a.pendingDebt > 0)
        .fold(0.0, (sum, a) => sum + a.pendingDebt);
  }

  List<Appointment> get pendingDebtAppointments {
    return _appointments.where((a) => a.pendingDebt > 0).toList();
  }

  // --- Cash Register Management ---
  Future<void> openRegister(
    double initialCash,
    double initialDigital, {
    String notes = '',
  }) async {
    final newSession = CashRegisterSession(
      id: _uuid.v4(),
      openedAt: DateTime.now(),
      initialCash: initialCash,
      initialDigital: initialDigital,
      isClosed: false,
      closingNotes: notes,
    );

    _activeSession = newSession;
    await _storage.saveActiveSession(_activeSession);

    // Registrar transaccion de base inicial en efectivo
    if (initialCash > 0) {
      final initialCashTx = Transaction(
        id: _uuid.v4(),
        type: TransactionType.initialBalance,
        description: 'Apertura de Jornada (Base Inicial Efectivo)',
        amount: initialCash,
        paymentMethod: PaymentMethod.cash,
        timestamp: DateTime.now(),
        extraNotes: notes,
      );
      _transactions.add(initialCashTx);
    }

    // Registrar transaccion de saldo inicial digital
    if (initialDigital > 0) {
      final initialDigitalTx = Transaction(
        id: _uuid.v4(),
        type: TransactionType.initialBalance,
        description: 'Apertura de Jornada (Saldo Base Digital)',
        amount: initialDigital,
        paymentMethod: PaymentMethod.transfer,
        timestamp: DateTime.now(),
        extraNotes: notes,
      );
      _transactions.add(initialDigitalTx);
    }

    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> closeRegister(
    double physicalCashCounted,
    double physicalDigitalCounted, {
    String notes = '',
  }) async {
    if (_activeSession == null) return;

    final expectedCash = theoreticalCashInDrawer;
    final diffCash = physicalCashCounted - expectedCash;

    final expectedDigital = theoreticalDigitalInBank;
    final diffDigital = physicalDigitalCounted - expectedDigital;

    _activeSession!.closedAt = DateTime.now();
    _activeSession!.isClosed = true;
    _activeSession!.physicalCashCounted = physicalCashCounted;
    _activeSession!.physicalDigitalCounted = physicalDigitalCounted;
    _activeSession!.discrepancy = diffCash;
    _activeSession!.digitalDiscrepancy = diffDigital;
    _activeSession!.closingNotes = notes;
    _activeSession!.sessionTransactions = List.from(_transactions);

    // Archivar en historial de sesiones pasadas
    _pastSessions.add(_activeSession!);
    await _storage.savePastSessions(_pastSessions);

    await _storage.saveActiveSession(_activeSession);
    notifyListeners();
  }

  // --- Category & Product Management ---
  Future<void> addProduct(ProductService item) async {
    _catalog.add(item);
    await _storage.saveCatalog(_catalog);
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    _catalog.removeWhere((p) => p.id == productId);
    _cart.removeWhere((c) => c.product.id == productId);
    await _storage.saveCatalog(_catalog);
    notifyListeners();
  }

  Future<bool> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _categories.contains(trimmed)) return false;
    _categories.add(trimmed);
    await _storage.saveCategories(_categories);
    notifyListeners();
    return true;
  }

  Future<bool> deleteCategory(String name) async {
    // Validar que no tenga productos o servicios asociados
    final hasProducts = _catalog.any((p) => p.category.toLowerCase() == name.toLowerCase());
    if (hasProducts) {
      return false; // No se puede eliminar si contiene ítems
    }

    _categories.removeWhere((c) => c.toLowerCase() == name.toLowerCase());
    await _storage.saveCategories(_categories);
    notifyListeners();
    return true;
  }

  // --- POS / Cart Operations ---
  void addToCart(ProductService product) {
    final idx = _cart.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      _cart[idx].quantity++;
    } else {
      _cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void updateCartQuantity(String productId, int delta) {
    final idx = _cart.indexWhere((c) => c.product.id == productId);
    if (idx >= 0) {
      _cart[idx].quantity += delta;
      if (_cart[idx].quantity <= 0) {
        _cart.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<bool> completePosSale(
    PaymentMethod paymentMethod, {
    String clientName = '',
    double discountAmount = 0.0,
  }) async {
    if (_cart.isEmpty) return false;

    final subtotal = cartTotal;
    final total = (subtotal - discountAmount).clamp(0.0, double.infinity);
    final itemSummaries = _cart.map((c) => '${c.quantity}x ${c.product.name}').join(', ');
    String desc = 'Venta POS: $itemSummaries';
    if (discountAmount > 0) {
      desc += ' [Descuento: ${formatMoney(discountAmount)}]';
    }

    final tx = Transaction(
      id: _uuid.v4(),
      type: TransactionType.sale,
      description: desc,
      amount: total,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
      clientName: clientName.isEmpty ? 'Cliente Mostrador' : clientName,
    );

    _transactions.add(tx);
    await _storage.saveTransactions(_transactions);
    clearCart();
    notifyListeners();
    return true;
  }

  Future<void> addDirectSale({
    required String description,
    required double amount,
    required PaymentMethod paymentMethod,
    String clientName = 'Cliente Mostrador',
  }) async {
    final tx = Transaction(
      id: _uuid.v4(),
      type: TransactionType.sale,
      description: 'Venta Directa: $description',
      amount: amount,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
      clientName: clientName.isEmpty ? 'Cliente Mostrador' : clientName,
    );

    _transactions.add(tx);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  // --- Customer Database & Comparison Engine ---
  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Compara y busca si un cliente ya existe por teléfono normalizado o nombre exacto
  Customer? findCustomer({String? name, String? phone}) {
    final normPhone = phone != null ? _normalizePhone(phone) : '';
    final normName = name?.trim().toLowerCase() ?? '';

    for (final c in _customers) {
      if (normPhone.isNotEmpty && _normalizePhone(c.phone) == normPhone) {
        return c;
      }
      if (normName.isNotEmpty && c.name.trim().toLowerCase() == normName) {
        return c;
      }
    }
    return null;
  }

  /// Crea un nuevo cliente o asocia a uno existente tras comparar nombres y teléfonos
  Future<Customer> findOrCreateCustomer({
    required String name,
    required String phone,
    DateTime? birthDate,
    bool isMother = false,
    String profession = '',
    String notes = '',
  }) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();

    final existing = findCustomer(name: trimmedName, phone: trimmedPhone);
    if (existing != null) {
      bool changed = false;
      if (existing.phone.isEmpty && trimmedPhone.isNotEmpty) {
        existing.phone = trimmedPhone;
        changed = true;
      }
      if (existing.notes.isEmpty && notes.isNotEmpty) {
        existing.notes = notes;
        changed = true;
      }
      if (existing.birthDate == null && birthDate != null) {
        existing.birthDate = birthDate;
        changed = true;
      }
      if (!existing.isMother && isMother) {
        existing.isMother = isMother;
        changed = true;
      }
      if (existing.profession.isEmpty && profession.isNotEmpty) {
        existing.profession = profession.trim();
        changed = true;
      }
      if (changed) {
        await _storage.saveCustomers(_customers);
        notifyListeners();
      }
      return existing;
    }

    final newCust = Customer(
      id: _uuid.v4(),
      name: trimmedName.isEmpty ? 'Cliente Sin Nombre' : trimmedName,
      phone: trimmedPhone,
      birthDate: birthDate,
      isMother: isMother,
      profession: profession.trim(),
      notes: notes,
      createdAt: DateTime.now(),
    );
    _customers.add(newCust);
    await _storage.saveCustomers(_customers);
    notifyListeners();
    return newCust;
  }

  Future<void> addCustomer(Customer customer) async {
    final existing = findCustomer(name: customer.name, phone: customer.phone);
    if (existing != null) {
      await updateCustomer(customer);
      return;
    }
    _customers.add(customer);
    await _storage.saveCustomers(_customers);
    notifyListeners();
  }

  Future<void> updateCustomer(Customer updated) async {
    final idx = _customers.indexWhere((c) => c.id == updated.id);
    if (idx >= 0) {
      final oldName = _customers[idx].name;
      final oldPhone = _customers[idx].phone;
      _customers[idx] = updated;
      await _storage.saveCustomers(_customers);

      // Sincronizar citas asociadas
      bool aptsChanged = false;
      for (final apt in _appointments) {
        if (apt.clientId == updated.id ||
            (apt.clientName.trim().toLowerCase() == oldName.trim().toLowerCase() &&
             _normalizePhone(apt.clientPhone) == _normalizePhone(oldPhone))) {
          apt.clientName = updated.name;
          apt.clientPhone = updated.phone;
          apt.clientId = updated.id;
          aptsChanged = true;
        }
      }
      if (aptsChanged) {
        await _storage.saveAppointments(_appointments);
      }
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    _customers.removeWhere((c) => c.id == customerId);
    await _storage.saveCustomers(_customers);
    notifyListeners();
  }

  // --- Appointments & Flexible Liquidation ---
  Future<void> createAppointment({
    required String clientName,
    required String clientPhone,
    required String serviceName,
    required double estimatedAmount,
    required DateTime scheduledAt,
    double discountAmount = 0.0,
    List<AppointmentProductItem>? items,
    String notes = '',
    String? clientId,
  }) async {
    Customer? cust;
    if (clientId != null && clientId.isNotEmpty) {
      cust = _customers.where((c) => c.id == clientId).firstOrNull;
    }
    cust ??= await findOrCreateCustomer(
      name: clientName,
      phone: clientPhone,
      notes: notes,
    );

    final apt = Appointment(
      id: _uuid.v4(),
      clientId: cust.id,
      clientName: cust.name,
      clientPhone: cust.phone,
      serviceName: serviceName,
      estimatedAmount: estimatedAmount,
      discountAmount: discountAmount,
      items: items ?? [],
      scheduledAt: scheduledAt,
      status: AppointmentStatus.pending,
      notes: notes,
    );

    _appointments.add(apt);
    await _storage.saveAppointments(_appointments);
    notifyListeners();
  }

  Future<void> updateAppointment({
    required String appointmentId,
    required String clientName,
    required String clientPhone,
    required String serviceName,
    required double estimatedAmount,
    required DateTime scheduledAt,
    double discountAmount = 0.0,
    List<AppointmentProductItem>? items,
    String notes = '',
    String? clientId,
  }) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx < 0) return;

    Customer? cust;
    if (clientId != null && clientId.isNotEmpty) {
      cust = _customers.where((c) => c.id == clientId).firstOrNull;
    }
    cust ??= await findOrCreateCustomer(
      name: clientName,
      phone: clientPhone,
      notes: notes,
    );

    final apt = _appointments[idx];
    apt.clientId = cust.id;
    apt.clientName = cust.name;
    apt.clientPhone = cust.phone;
    apt.serviceName = serviceName;
    apt.estimatedAmount = estimatedAmount;
    apt.discountAmount = discountAmount;
    if (items != null) apt.items = items;
    apt.scheduledAt = scheduledAt;
    apt.notes = notes;

    await _storage.saveAppointments(_appointments);
    notifyListeners();
  }

  // --- Special Days, Profession Days & Reminders Engine ---
  static const Map<String, (int, int)> professionDays = {
    'médic': (12, 3),      // 3 de Diciembre - Día del Médico
    'doctor': (12, 3),
    'abogad': (6, 22),     // 22 de Junio - Día del Abogado
    'docent': (5, 15),     // 15 de Mayo - Día del Maestro/Docente
    'profesor': (5, 15),
    'maestr': (5, 15),
    'ingenier': (8, 17),   // 17 de Agosto - Día del Ingeniero
    'contador': (3, 1),    // 1 de Marzo - Día del Contador
    'enfermer': (5, 12),   // 12 de Mayo - Día de la Enfermería
    'barber': (8, 25),     // 25 de Agosto - Día del Barbero/Peluquero
    'estilist': (8, 25),
    'peluquer': (8, 25),
    'diseñad': (10, 24),   // 24 de Octubre - Día del Diseñador
    'odontólog': (10, 3),  // 3 de Octubre - Día del Odontólogo
    'dentist': (10, 3),
    'secretari': (4, 26),  // 26 de Abril - Día de la Secretaria
    'asistent': (4, 26),
    'psicólog': (11, 20),  // 20 de Noviembre - Día del Psicólogo
    'periodist': (2, 9),   // 9 de Febrero - Día del Periodista
    'veterinari': (5, 10), // 10 de Mayo - Día del Veterinario
    'arquitect': (10, 27), // 27 de Octubre - Día del Arquitecto
    'administrad': (11, 4),// 4 de Noviembre - Día del Administrador
  };

  /// Calcula el segundo domingo de mayo para el año dado (Día de la Madre)
  DateTime getMothersDay(int year) {
    DateTime dt = DateTime(year, 5, 1);
    while (dt.weekday != DateTime.sunday) {
      dt = dt.add(const Duration(days: 1));
    }
    return dt.add(const Duration(days: 7)); // Segundo domingo
  }

  /// Retorna recordatorios o fechas especiales para un día específico
  List<SpecialReminder> getSpecialRemindersForDate(DateTime date) {
    final List<SpecialReminder> list = [];

    // 1. Cumpleaños de clientes
    for (final c in _customers) {
      if (c.birthDate != null &&
          c.birthDate!.month == date.month &&
          c.birthDate!.day == date.day) {
        final ageStr = c.age != null ? ' (${c.age} años)' : '';
        list.add(
          SpecialReminder(
            title: '🎂 ¡Cumpleaños de ${c.name}!$ageStr',
            subtitle: 'Cliente cumpleañero hoy. Tel: ${c.phone}',
            type: SpecialDayType.birthday,
            date: date,
            customerId: c.id,
            customerPhone: c.phone,
          ),
        );
      }
    }

    // 2. Día de la Madre
    final mothersDay = getMothersDay(date.year);
    if (date.month == mothersDay.month && date.day == mothersDay.day) {
      final mothersCount = _customers.where((c) => c.isMother).length;
      final mothersNames = _customers
          .where((c) => c.isMother)
          .map((c) => c.name.split(' ').first)
          .take(3)
          .join(', ');
      list.add(
        SpecialReminder(
          title: '💐 ¡Día de la Madre!',
          subtitle: mothersCount > 0
              ? '$mothersCount mamá(s) registrada(s) ($mothersNames...). ¡Ofrecer promo especial!'
              : 'Homenaje a todas las madres de familia.',
          type: SpecialDayType.motherDay,
          date: date,
        ),
      );
    }

    // 3. Día de la Profesión
    for (final c in _customers) {
      if (c.profession.isNotEmpty) {
        final lower = c.profession.toLowerCase();
        for (final entry in professionDays.entries) {
          if (lower.contains(entry.key)) {
            final targetMonth = entry.value.$1;
            final targetDay = entry.value.$2;
            if (date.month == targetMonth && date.day == targetDay) {
              list.add(
                SpecialReminder(
                  title: '👔 Día de la Profesión: ${c.profession}',
                  subtitle: 'Celebración para ${c.name} (${c.profession})',
                  type: SpecialDayType.professionDay,
                  date: date,
                  customerId: c.id,
                  customerPhone: c.phone,
                ),
              );
              break;
            }
          }
        }
      }
    }

    return list;
  }

  /// Retorna los próximos recordatorios para los siguientes días
  List<SpecialReminder> getUpcomingReminders({int daysAhead = 30}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<SpecialReminder> reminders = [];

    for (int i = 0; i < daysAhead; i++) {
      final checkDate = today.add(Duration(days: i));
      final forDate = getSpecialRemindersForDate(checkDate);
      reminders.addAll(forDate);
    }
    return reminders;
  }

  /// Citas en un día específico (ignora hora)
  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments.where((a) {
      return a.scheduledAt.year == date.year &&
          a.scheduledAt.month == date.month &&
          a.scheduledAt.day == date.day;
    }).toList();
  }

  Future<void> deleteAppointment(String appointmentId) async {
    _appointments.removeWhere((a) => a.id == appointmentId);
    await _storage.saveAppointments(_appointments);
    notifyListeners();
  }

  /// Differentiator feature: Liquidar cita a caja con cobro flexible
  Future<void> liquidateAppointment({
    required String appointmentId,
    required double amountPaidNow,
    required double pendingDebt,
    required double extraAmount,
    required String extraNote,
    required PaymentMethod paymentMethod,
  }) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx < 0) return;

    final apt = _appointments[idx];
    apt.status = AppointmentStatus.completed;
    apt.finalAmountPaid = amountPaidNow;
    apt.pendingDebt = pendingDebt;
    apt.extraAmount = extraAmount;
    apt.extraNote = extraNote;
    apt.paymentMethod = paymentMethod;

    await _storage.saveAppointments(_appointments);

    // Si hubo pago o abono inmediato, ingresa a la caja
    if (amountPaidNow > 0) {
      String desc = 'Liquidación Cita: ${apt.serviceName} (${apt.clientName})';
      if (pendingDebt > 0) {
        desc += ' [Abono parcial - Queda debiendo ${formatMoney(pendingDebt)}]';
      }
      if (extraAmount > 0) {
        desc += ' [+ Extra: ${formatMoney(extraAmount)} por $extraNote]';
      }

      final tx = Transaction(
        id: _uuid.v4(),
        type: TransactionType.appointmentLiquidation,
        description: desc,
        amount: amountPaidNow,
        paymentMethod: paymentMethod,
        timestamp: DateTime.now(),
        referenceId: apt.id,
        clientName: apt.clientName,
      );

      _transactions.add(tx);
      await _storage.saveTransactions(_transactions);
    }

    notifyListeners();
  }

  Future<void> payPendingDebt({
    required String appointmentId,
    required double amountToPay,
    required PaymentMethod paymentMethod,
  }) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx < 0) return;

    final apt = _appointments[idx];
    if (amountToPay > apt.pendingDebt) {
      amountToPay = apt.pendingDebt;
    }

    apt.pendingDebt -= amountToPay;
    apt.finalAmountPaid += amountToPay;

    await _storage.saveAppointments(_appointments);

    final tx = Transaction(
      id: _uuid.v4(),
      type: TransactionType.debtPayment,
      description: 'Abono Saldo Pendiente: ${apt.serviceName} (${apt.clientName})',
      amount: amountToPay,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
      referenceId: apt.id,
      clientName: apt.clientName,
      extraNotes: 'Saldo restante por cobrar: ${formatMoney(apt.pendingDebt)}',
    );

    _transactions.add(tx);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx >= 0) {
      _appointments[idx].status = AppointmentStatus.cancelled;
      await _storage.saveAppointments(_appointments);
      notifyListeners();
    }
  }

  // --- Expenses & Petty Cash ---
  Future<void> addExpense({
    required String description,
    required double amount,
    required ExpenseCategory category,
    required PaymentMethod paymentMethod,
    String notes = '',
    String receiptImagePath = '',
  }) async {
    final tx = Transaction(
      id: _uuid.v4(),
      type: TransactionType.expense,
      description: '$description [${category.label}]',
      amount: amount,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
      extraNotes: notes,
      isExpense: true,
      receiptImagePath: receiptImagePath,
    );

    _transactions.add(tx);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }
}
