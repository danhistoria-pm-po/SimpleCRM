// lib/modules/customers/presentation/customer_controller.dart

import 'package:flutter/foundation.dart';
import '../domain/entities/customer_entity.dart';

class CustomerController extends ChangeNotifier {
  final List<Customer> _customers = [];

  List<Customer> get customers => List.unmodifiable(_customers);

  void addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address, // <-- Certifique-se que esta linha existe aqui
    CustomerStatus status = CustomerStatus.potential,
    String? notes,
  }) {
    final now = DateTime.now();
    final newCustomer = Customer(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      email: email,
      address: address, // <-- E esta linha aqui
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