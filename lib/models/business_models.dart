
import 'package:flutter/material.dart';

enum PaymentMethod {
  cash('Efectivo'),
  transfer('Transferencia / Digital'),
  card('Tarjeta');

  final String label;
  const PaymentMethod(this.label);

  static PaymentMethod fromString(String val) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == val,
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum TransactionType {
  initialBalance('Base Inicial'),
  sale('Venta POS'),
  appointmentLiquidation('Liquidación Cita'),
  debtPayment('Abono a Saldo Pendiente'),
  expense('Egreso / Gasto');

  final String label;
  const TransactionType(this.label);

  static TransactionType fromString(String val) {
    return TransactionType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => TransactionType.sale,
    );
  }
}

enum AppointmentStatus {
  pending('Agendada'),
  completed('Liquidada'),
  cancelled('Cancelada');

  final String label;
  const AppointmentStatus(this.label);

  static AppointmentStatus fromString(String val) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.name == val,
      orElse: () => AppointmentStatus.pending,
    );
  }
}

enum ExpenseCategory {
  supplies('Insumos / Mercancía'),
  utilities('Servicios Públicos'),
  payroll('Sueldos / Comisiones'),
  maintenance('Mantenimiento'),
  food('Alimentación / Refrigerios'),
  pettyCash('Caja Menor / Imprevistos'),
  other('Otros Gastos');

  final String label;
  const ExpenseCategory(this.label);

  static ExpenseCategory fromString(String val) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == val,
      orElse: () => ExpenseCategory.other,
    );
  }
}

class ProductService {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool isService;
  final String description;

  const ProductService({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isService = false,
    this.description = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'isService': isService,
        'description': description,
      };

  factory ProductService.fromMap(Map<String, dynamic> map) => ProductService(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        category: map['category'] ?? 'General',
        isService: map['isService'] ?? false,
        description: map['description'] ?? '',
      );
}

class CartItem {
  final ProductService product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class Transaction {
  final String id;
  final TransactionType type;
  final String description;
  final double amount;
  final PaymentMethod paymentMethod;
  final DateTime timestamp;
  final String referenceId;
  final String clientName;
  final String extraNotes;
  final bool isExpense;
  final String receiptImagePath;

  Transaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.paymentMethod,
    required this.timestamp,
    this.referenceId = '',
    this.clientName = '',
    this.extraNotes = '',
    this.isExpense = false,
    this.receiptImagePath = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'description': description,
        'amount': amount,
        'paymentMethod': paymentMethod.name,
        'timestamp': timestamp.toIso8601String(),
        'referenceId': referenceId,
        'clientName': clientName,
        'extraNotes': extraNotes,
        'isExpense': isExpense,
        'receiptImagePath': receiptImagePath,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] ?? '',
        type: TransactionType.fromString(map['type'] ?? 'sale'),
        description: map['description'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        paymentMethod: PaymentMethod.fromString(map['paymentMethod'] ?? 'cash'),
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
        referenceId: map['referenceId'] ?? '',
        clientName: map['clientName'] ?? '',
        extraNotes: map['extraNotes'] ?? '',
        isExpense: map['isExpense'] ?? false,
        receiptImagePath: map['receiptImagePath'] ?? '',
      );
}

class Customer {
  final String id;
  String name;
  String phone;
  DateTime? birthDate;
  bool isMother;
  String profession;
  DateTime createdAt;
  String notes;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.birthDate,
    this.isMother = false,
    this.profession = '',
    DateTime? createdAt,
    this.notes = '',
  }) : createdAt = createdAt ?? DateTime.now();

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years >= 0 ? years : 0;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'birthDate': birthDate?.toIso8601String(),
        'isMother': isMother,
        'profession': profession,
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
      };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        birthDate: map['birthDate'] != null ? DateTime.tryParse(map['birthDate']) : null,
        isMother: map['isMother'] ?? false,
        profession: map['profession'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        notes: map['notes'] ?? '',
      );
}

class AppointmentProductItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final bool isService;

  AppointmentProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.isService = false,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'isService': isService,
      };

  factory AppointmentProductItem.fromMap(Map<String, dynamic> map) =>
      AppointmentProductItem(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        isService: map['isService'] ?? false,
      );
}

class Appointment {
  final String id;
  String clientName;
  String clientPhone;
  String? clientId;
  String serviceName;
  double estimatedAmount;
  double discountAmount;
  List<AppointmentProductItem> items;
  DateTime scheduledAt;
  AppointmentStatus status;
  double finalAmountPaid;
  double pendingDebt;
  double extraAmount;
  String extraNote;
  PaymentMethod paymentMethod;
  String notes;

  Appointment({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    this.clientId,
    required this.serviceName,
    required this.estimatedAmount,
    this.discountAmount = 0.0,
    List<AppointmentProductItem>? items,
    required this.scheduledAt,
    this.status = AppointmentStatus.pending,
    this.finalAmountPaid = 0.0,
    this.pendingDebt = 0.0,
    this.extraAmount = 0.0,
    this.extraNote = '',
    this.paymentMethod = PaymentMethod.cash,
    this.notes = '',
  }) : items = items ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'clientId': clientId,
        'serviceName': serviceName,
        'estimatedAmount': estimatedAmount,
        'discountAmount': discountAmount,
        'items': items.map((i) => i.toMap()).toList(),
        'scheduledAt': scheduledAt.toIso8601String(),
        'status': status.name,
        'finalAmountPaid': finalAmountPaid,
        'pendingDebt': pendingDebt,
        'extraAmount': extraAmount,
        'extraNote': extraNote,
        'paymentMethod': paymentMethod.name,
        'notes': notes,
      };

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
        id: map['id'] ?? '',
        clientName: map['clientName'] ?? '',
        clientPhone: map['clientPhone'] ?? '',
        clientId: map['clientId'],
        serviceName: map['serviceName'] ?? '',
        estimatedAmount: (map['estimatedAmount'] as num?)?.toDouble() ?? 0.0,
        discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
        items: (map['items'] as List?)
                ?.map((i) => AppointmentProductItem.fromMap(i as Map<String, dynamic>))
                .toList() ??
            [],
        scheduledAt: DateTime.tryParse(map['scheduledAt'] ?? '') ?? DateTime.now(),
        status: AppointmentStatus.fromString(map['status'] ?? 'pending'),
        finalAmountPaid: (map['finalAmountPaid'] as num?)?.toDouble() ?? 0.0,
        pendingDebt: (map['pendingDebt'] as num?)?.toDouble() ?? 0.0,
        extraAmount: (map['extraAmount'] as num?)?.toDouble() ?? 0.0,
        extraNote: map['extraNote'] ?? '',
        paymentMethod: PaymentMethod.fromString(map['paymentMethod'] ?? 'cash'),
        notes: map['notes'] ?? '',
      );
}

enum SpecialDayType {
  birthday('Cumpleaños', Icons.cake_rounded, Color(0xFFE11D48)),
  motherDay('Día de la Madre', Icons.favorite_rounded, Color(0xFFDB2777)),
  professionDay('Día de la Profesión', Icons.work_rounded, Color(0xFF4F46E5)),
  customSpecial('Día Especial', Icons.star_rounded, Color(0xFFD97706));

  final String label;
  final IconData icon;
  final Color color;
  const SpecialDayType(this.label, this.icon, this.color);
}

class SpecialReminder {
  final String title;
  final String subtitle;
  final SpecialDayType type;
  final DateTime date;
  final String? customerId;
  final String? customerPhone;

  SpecialReminder({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
    this.customerId,
    this.customerPhone,
  });
}

class CashRegisterSession {
  final String id;
  final DateTime openedAt;
  DateTime? closedAt;
  final double initialCash;
  final double initialDigital;
  bool isClosed;
  double physicalCashCounted;
  double physicalDigitalCounted;
  double discrepancy;
  double digitalDiscrepancy;
  String closingNotes;
  List<Transaction> sessionTransactions;

  CashRegisterSession({
    required this.id,
    required this.openedAt,
    this.closedAt,
    required this.initialCash,
    this.initialDigital = 0.0,
    this.isClosed = false,
    this.physicalCashCounted = 0.0,
    this.physicalDigitalCounted = 0.0,
    this.discrepancy = 0.0,
    this.digitalDiscrepancy = 0.0,
    this.closingNotes = '',
    List<Transaction>? sessionTransactions,
  }) : sessionTransactions = sessionTransactions ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'openedAt': openedAt.toIso8601String(),
        'closedAt': closedAt?.toIso8601String(),
        'initialCash': initialCash,
        'initialDigital': initialDigital,
        'isClosed': isClosed,
        'physicalCashCounted': physicalCashCounted,
        'physicalDigitalCounted': physicalDigitalCounted,
        'discrepancy': discrepancy,
        'digitalDiscrepancy': digitalDiscrepancy,
        'closingNotes': closingNotes,
        'sessionTransactions': sessionTransactions.map((t) => t.toMap()).toList(),
      };

  factory CashRegisterSession.fromMap(Map<String, dynamic> map) =>
      CashRegisterSession(
        id: map['id'] ?? '',
        openedAt: DateTime.tryParse(map['openedAt'] ?? '') ?? DateTime.now(),
        closedAt: map['closedAt'] != null ? DateTime.tryParse(map['closedAt']) : null,
        initialCash: (map['initialCash'] as num?)?.toDouble() ?? 0.0,
        initialDigital: (map['initialDigital'] as num?)?.toDouble() ?? 0.0,
        isClosed: map['isClosed'] ?? false,
        physicalCashCounted:
            (map['physicalCashCounted'] as num?)?.toDouble() ?? 0.0,
        physicalDigitalCounted:
            (map['physicalDigitalCounted'] as num?)?.toDouble() ?? 0.0,
        discrepancy: (map['discrepancy'] as num?)?.toDouble() ?? 0.0,
        digitalDiscrepancy: (map['digitalDiscrepancy'] as num?)?.toDouble() ?? 0.0,
        closingNotes: map['closingNotes'] ?? '',
        sessionTransactions: (map['sessionTransactions'] as List?)
                ?.map((t) => Transaction.fromMap(t as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
