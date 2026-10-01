import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_models.dart';

class StorageService {
  static const String keyActiveSession = 'flowbiz_active_session';
  static const String keyPastSessions = 'flowbiz_past_sessions';
  static const String keyTransactions = 'flowbiz_transactions';
  static const String keyAppointments = 'flowbiz_appointments';
  static const String keyCatalog = 'flowbiz_catalog';
  static const String keyCategories = 'flowbiz_categories';
  static const String keyCustomers = 'flowbiz_customers';

  final SharedPreferences prefs;

  StorageService(this.prefs);

  static Future<StorageService> init() async {
    final sp = await SharedPreferences.getInstance();
    return StorageService(sp);
  }

  // Active Cash Register Session
  CashRegisterSession? getActiveSession() {
    final raw = prefs.getString(keyActiveSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      return CashRegisterSession.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveSession(CashRegisterSession? session) async {
    if (session == null) {
      await prefs.remove(keyActiveSession);
    } else {
      await prefs.setString(keyActiveSession, jsonEncode(session.toMap()));
    }
  }

  // Transactions
  List<Transaction> getTransactions() {
    final rawList = prefs.getStringList(keyTransactions) ?? [];
    return rawList
        .map((e) {
          try {
            return Transaction.fromMap(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<Transaction>()
        .toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final rawList = transactions.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(keyTransactions, rawList);
  }

  // Appointments
  List<Appointment> getAppointments() {
    final rawList = prefs.getStringList(keyAppointments);
    if (rawList == null) {
      return _getInitialAppointments();
    }
    return rawList
        .map((e) {
          try {
            return Appointment.fromMap(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<Appointment>()
        .toList();
  }

  Future<void> saveAppointments(List<Appointment> appointments) async {
    final rawList = appointments.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(keyAppointments, rawList);
  }

  // Catalog
  List<ProductService> getCatalog() {
    final rawList = prefs.getStringList(keyCatalog);
    if (rawList == null) {
      return _getInitialCatalog();
    }
    return rawList
        .map((e) {
          try {
            return ProductService.fromMap(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<ProductService>()
        .toList();
  }

  Future<void> saveCatalog(List<ProductService> catalog) async {
    final rawList = catalog.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(keyCatalog, rawList);
  }

  // Past Sessions (Historial de Arqueos)
  List<CashRegisterSession> getPastSessions() {
    final rawList = prefs.getStringList(keyPastSessions) ?? [];
    return rawList
        .map((e) {
          try {
            return CashRegisterSession.fromMap(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<CashRegisterSession>()
        .toList();
  }

  Future<void> savePastSessions(List<CashRegisterSession> sessions) async {
    final rawList = sessions.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(keyPastSessions, rawList);
  }

  // Categories
  List<String> getCategories() {
    final rawList = prefs.getStringList(keyCategories);
    if (rawList != null && rawList.isNotEmpty) {
      return rawList;
    }
    return ['Servicios', 'Combos', 'Estética', 'Productos', 'Bebidas'];
  }

  Future<void> saveCategories(List<String> categories) async {
    await prefs.setStringList(keyCategories, categories);
  }

  // Customers (Base de datos de Clientes)
  List<Customer> getCustomers() {
    final rawList = prefs.getStringList(keyCustomers);
    if (rawList == null) {
      return _getInitialCustomers();
    }
    return rawList
        .map((e) {
          try {
            return Customer.fromMap(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<Customer>()
        .toList();
  }

  Future<void> saveCustomers(List<Customer> customers) async {
    final rawList = customers.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(keyCustomers, rawList);
  }

  List<Customer> _getInitialCustomers() {
    return [
      Customer(
        id: 'cli-1',
        name: 'Carlos Mendoza',
        phone: '312 456 7890',
        birthDate: DateTime(1993, 9, 22),
        isMother: false,
        profession: 'Ingeniero',
        notes: 'Cliente puntual, prefiere fade medio',
      ),
      Customer(
        id: 'cli-2',
        name: 'Camila Restrepo',
        phone: '310 444 8899',
        birthDate: DateTime(1991, 5, 12),
        isMother: true,
        profession: 'Abogada',
        notes: 'Le gustan los tratamientos capilares orgánicos',
      ),
      Customer(
        id: 'cli-3',
        name: 'Alejandro Gómez',
        phone: '315 987 6543',
        birthDate: DateTime(1988, 12, 3),
        isMother: false,
        profession: 'Médico',
        notes: 'Atención preferente en las mañanas',
      ),
      Customer(
        id: 'cli-4',
        name: 'Diana Marcela Torres',
        phone: '318 777 6655',
        birthDate: DateTime(1994, 9, 24),
        isMother: true,
        profession: 'Docente',
        notes: 'Mamá de 2 niños, prefiere citas los sábados',
      ),
      Customer(
        id: 'cli-5',
        name: 'Felipe Duarte',
        phone: '320 111 2233',
        birthDate: DateTime(1996, 3, 1),
        isMother: false,
        profession: 'Contador',
        notes: 'Requiere prueba de sensibilidad en piel',
      ),
    ];
  }

  List<ProductService> _getInitialCatalog() {
    return [
      const ProductService(
        id: 'srv-1',
        name: 'Corte de Cabello Clásico',
        price: 25000,
        category: 'Servicios',
        isService: true,
        description: 'Corte tradicional o fade con lavado ligero',
      ),
      const ProductService(
        id: 'srv-2',
        name: 'Arreglo de Barba & Toalla',
        price: 18000,
        category: 'Servicios',
        isService: true,
        description: 'Perfilado con navaja y tratamiento de toalla caliente',
      ),
      const ProductService(
        id: 'srv-3',
        name: 'Combo Ejecutivo (Corte + Barba)',
        price: 38000,
        category: 'Combos',
        isService: true,
        description: 'Servicio integral con exfoliación facial',
      ),
      const ProductService(
        id: 'srv-4',
        name: 'Limpieza Facial Profunda',
        price: 45000,
        category: 'Estética',
        isService: true,
        description: 'Vapor de ozono, extracción y mascarilla revitalizante',
      ),
      const ProductService(
        id: 'prd-1',
        name: 'Cera Fijadora Mate 100g',
        price: 28000,
        category: 'Productos',
        isService: false,
        description: 'Fijación media-alta con acabado natural',
      ),
      const ProductService(
        id: 'prd-2',
        name: 'Óleo Nutritivo para Barba 30ml',
        price: 32000,
        category: 'Productos',
        isService: false,
        description: 'Aceite de argán y jojoba para hidratación diaria',
      ),
      const ProductService(
        id: 'prd-3',
        name: 'Bebida Energizante / Refresco',
        price: 6000,
        category: 'Bebidas',
        isService: false,
        description: 'Consumo durante la espera o atención',
      ),
    ];
  }

  List<Appointment> _getInitialAppointments() {
    final now = DateTime.now();
    return [
      Appointment(
        id: 'apt-1',
        clientId: 'cli-1',
        clientName: 'Carlos Mendoza',
        clientPhone: '312 456 7890',
        serviceName: 'Combo Ejecutivo (Corte + Barba)',
        estimatedAmount: 38000,
        scheduledAt: DateTime(now.year, now.month, now.day, 10, 0),
        status: AppointmentStatus.pending,
        notes: 'Cliente puntual, prefiere fade medio',
      ),
      Appointment(
        id: 'apt-2',
        clientId: 'cli-2',
        clientName: 'Alejandro Gómez',
        clientPhone: '315 987 6543',
        serviceName: 'Corte de Cabello Clásico',
        estimatedAmount: 25000,
        scheduledAt: DateTime(now.year, now.month, now.day, 11, 30),
        status: AppointmentStatus.pending,
        notes: '',
      ),
      Appointment(
        id: 'apt-3',
        clientId: 'cli-3',
        clientName: 'Felipe Duarte',
        clientPhone: '320 111 2233',
        serviceName: 'Limpieza Facial Profunda',
        estimatedAmount: 45000,
        scheduledAt: DateTime(now.year, now.month, now.day, 14, 0),
        status: AppointmentStatus.pending,
        notes: 'Requiere prueba de sensibilidad en piel',
      ),
    ];
  }
}
