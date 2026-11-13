// lib/modules/customers/presentation/customer_controller.dart
import 'package:flutter/foundation.dart';
import '../domain/entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class CustomerController extends ChangeNotifier {
  static final CustomerController _instance = CustomerController._internal();

  factory CustomerController({CustomerRepository? repository}) {
    if (repository != null) {
      return CustomerController._internal(repository: repository);
    }
    return _instance;
  }

  CustomerController._internal({CustomerRepository? repository})
      : _repository = repository ?? CustomerRepository();

  final CustomerRepository _repository;

  List<Customer> _customers = [];
  List<Customer> get customers => List.unmodifiable(_customers);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasLoadedOnce = false;
  int _generation = 0;

  // Limpa a memória do app ao fazer logout e invalida requisições em andamento da sessão anterior
  void reset() {
    _generation++;
    _customers = [];
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    _hasLoadedOnce = false;
    notifyListeners();
  }

  // Evita carga duplicada na montagem inicial das abas
  Future<bool> ensureLoaded() async {
    if (_hasLoadedOnce || _isLoading || _isRefreshing) {
      return _errorMessage == null;
    }
    return loadCustomers();
  }

  // Carrega os clientes do Supabase sem lançar exceção não capturada
  Future<bool> loadCustomers({bool silent = false}) async {
    final int requestGen = _generation;

    if (!silent && _customers.isEmpty) {
      _isLoading = true;
    } else {
      _isRefreshing = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getCustomers();
      if (requestGen != _generation) {
        return false; // Sessão foi resetada durante o await; descarta resultado antigo
      }
      _customers = result;
      _hasLoadedOnce = true;
      return true;
    } catch (e) {
      if (requestGen != _generation) {
        return false;
      }
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Erro no controller ao carregar clientes: $_errorMessage');
      return false;
    } finally {
      if (requestGen == _generation) {
        _isLoading = false;
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  // Adiciona um cliente e persiste no Supabase
  Future<bool> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
    CustomerStatus status = CustomerStatus.potential,
    String? notes,
  }) async {
    final now = DateTime.now();
    final newCustomer = Customer(
      id: '',
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
      _errorMessage = null;
      await _repository.addCustomer(newCustomer);
      await loadCustomers(silent: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Erro ao adicionar cliente: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // Remove o cliente do Supabase via RPC delete_customer_safe
  Future<bool> removeCustomer(String id) async {
    try {
      _errorMessage = null;
      await _repository.deleteCustomer(id);
      _customers.removeWhere((customer) => customer.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Erro ao remover cliente: $_errorMessage');
      notifyListeners();
      return false;
    }
  }
}
