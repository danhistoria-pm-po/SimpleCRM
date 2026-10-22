// lib/modules/customers/presentation/customer_controller.dart
import 'package:flutter/foundation.dart';
import '../domain/entities/customer_entity.dart';

class CustomerController extends ChangeNotifier {
  // Padrão Singleton para garantir que a lista de clientes nunca se perde ao trocar de abas
  static final CustomerController _instance = CustomerController._internal();

  factory CustomerController() {
    return _instance;
  }

  CustomerController._internal();

  final List<Customer> _customers = [];

  List<Customer> get customers => List.unmodifiable(_customers);

  void addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
    CustomerStatus status = CustomerStatus.potential,
    String? notes,
  }) {
    final now = DateTime.now();
    final newCustomer = Customer(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      email: email,
      address: address,
      status: status,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    _customers.add(newCustomer);
    notifyListeners();
  }

  void removeCustomer(String id) {
    _customers.removeWhere((customer) => customer.id == id);
    notifyListeners();
  }
}