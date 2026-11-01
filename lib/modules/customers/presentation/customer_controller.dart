// lib/modules/customers/presentation/customer_controller.dart
import 'package:flutter/foundation.dart';
import '../domain/entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class CustomerController extends ChangeNotifier {
  // Padrão Singleton: Garante uma única instância partilhada em todo o app
  static final CustomerController _instance = CustomerController._internal();
  factory CustomerController() => _instance;
  
  CustomerController._internal() {
    loadCustomers(); // Carrega automaticamente os clientes do Supabase assim que o controller inicializa
  }

  final CustomerRepository _repository = CustomerRepository();

  List<Customer> _customers = [];
  List<Customer> get customers => List.unmodifiable(_customers);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Limpa a memória do app ao fazer logout
  void reset() {
    _customers = [];
    notifyListeners();
  }

  // Carrega os clientes do Supabase
  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _repository.getCustomers();
    } catch (e) {
      debugPrint('Erro no controller ao carregar clientes: $e');
      rethrow; // Repassa o erro para a tela avisar o usuário
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adiciona um cliente e persiste no Supabase
  Future<void> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
    CustomerStatus status = CustomerStatus.potential,
    String? notes,
  }) async {
    final now = DateTime.now();
    final newCustomer = Customer(
      id: '', // Gerado pelo Supabase
      name: name,
      phone: phone,
      email: email,
      address: address,
      status: status,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.addCustomer(newCustomer);
      await loadCustomers(); // Atualiza a lista unificada direto da base de dados
    } catch (e) {
      debugPrint('Erro ao adicionar cliente: $e');
      rethrow; // Repassa o erro para a tela avisar o usuário
    }
  }

  // Remove o cliente do Supabase
  Future<void> removeCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      _customers.removeWhere((customer) => customer.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao remover cliente: $e');
      rethrow; // Repassa o erro para a tela avisar o usuário
    }
  }
}