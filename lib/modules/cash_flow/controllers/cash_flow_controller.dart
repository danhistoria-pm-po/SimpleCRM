// lib/modules/cash_flow/controllers/cash_flow_controller.dart
import 'package:flutter/foundation.dart';
import '../models/cash_flow_entry_entity.dart';
import '../repositories/cash_flow_repository.dart';

class CashFlowController extends ChangeNotifier {
  final CashFlowRepository _repository = CashFlowRepository();

  List<CashFlowEntryEntity> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CashFlowEntryEntity> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> loadEntries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _repository.fetchEntries();
    } catch (e) {
      _errorMessage = 'Erro ao carregar fluxo de caixa: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEntry(CashFlowEntryEntity entry) async {
    try {
      await _repository.createEntry(entry);
      await loadEntries();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao criar lançamento: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    try {
      await _repository.deleteEntry(id);
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir lançamento: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }
}
