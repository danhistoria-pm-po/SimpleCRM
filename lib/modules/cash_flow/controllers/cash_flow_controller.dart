// lib/modules/cash_flow/controllers/cash_flow_controller.dart
import 'package:flutter/foundation.dart';
import '../models/cash_flow_entry_entity.dart';
import '../repositories/cash_flow_repository.dart';

class CashFlowController extends ChangeNotifier {
  static final CashFlowController _instance = CashFlowController._internal();

  factory CashFlowController({CashFlowRepository? repository}) {
    if (repository != null) {
      return CashFlowController._internal(repository: repository);
    }
    return _instance;
  }

  CashFlowController._internal({CashFlowRepository? repository})
      : _repository = repository ?? CashFlowRepository();

  final CashFlowRepository _repository;

  List<CashFlowEntryEntity> _entries = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  List<CashFlowEntryEntity> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  void reset() {
    _entries = [];
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    notifyListeners();
  }

  double get totalIncome {
    return _entries
        .where((e) => e.type == CashFlowType.income)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalExpense {
    return _entries
        .where((e) => e.type == CashFlowType.expense)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get netBalance => totalIncome - totalExpense;

  Future<bool> loadEntries({bool silent = false}) async {
    if (!silent && _entries.isEmpty) {
      _isLoading = true;
    } else {
      _isRefreshing = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _repository.fetchEntries();
      return true;
    } catch (e) {
      _errorMessage =
          'Erro ao carregar fluxo de caixa: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> createEntry(CashFlowEntryEntity entry) async {
    try {
      _errorMessage = null;
      await _repository.createEntry(entry);
      return await loadEntries(silent: true);
    } catch (e) {
      _errorMessage =
          'Erro ao criar lançamento: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    final previousEntries = List<CashFlowEntryEntity>.from(_entries);
    _entries.removeWhere((e) => e.id == id);
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteEntry(id);
      return true;
    } catch (e) {
      _entries = previousEntries;
      _errorMessage =
          'Erro ao excluir lançamento: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }
}
