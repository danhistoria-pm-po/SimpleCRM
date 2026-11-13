// lib/modules/billing/controllers/billing_controller.dart
import 'package:flutter/foundation.dart';
import '../models/invoice_entity.dart';
import '../repositories/billing_repository.dart';

class BillingController extends ChangeNotifier {
  final BillingRepository _repository;

  BillingController({BillingRepository? repository})
      : _repository = repository ?? BillingRepository();

  List<InvoiceEntity> _invoices = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  List<InvoiceEntity> get invoices => List.unmodifiable(_invoices);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  Future<bool> loadInvoices({bool silent = false}) async {
    if (!silent && _invoices.isEmpty) {
      _isLoading = true;
    } else {
      _isRefreshing = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      _invoices = await _repository.fetchInvoices();
      return true;
    } catch (e) {
      _errorMessage =
          'Erro ao carregar faturas: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> createInvoice(InvoiceEntity invoice) async {
    try {
      _errorMessage = null;
      await _repository.createInvoice(invoice);
      return await loadInvoices(silent: true);
    } catch (e) {
      _errorMessage =
          'Erro ao criar fatura: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  // Atualização otimista de status: não liga isLoading e reverte em caso de falha
  Future<bool> updateInvoiceStatus(String id, InvoiceStatus newStatus) async {
    final previousInvoices = List<InvoiceEntity>.from(_invoices);
    final index = _invoices.indexWhere((inv) => inv.id == id);

    if (index != -1) {
      _invoices[index] = _invoices[index].copyWith(status: newStatus);
      _errorMessage = null;
      notifyListeners();
    }

    try {
      await _repository.updateInvoiceStatus(id, newStatus);
      return true;
    } catch (e) {
      _invoices = previousInvoices;
      _errorMessage =
          'Erro ao atualizar status da fatura: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  // Exclusão otimista com reversão em caso de falha
  Future<bool> deleteInvoice(String id) async {
    final previousInvoices = List<InvoiceEntity>.from(_invoices);
    _invoices.removeWhere((inv) => inv.id == id);
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteInvoice(id);
      return true;
    } catch (e) {
      _invoices = previousInvoices;
      _errorMessage =
          'Erro ao excluir fatura: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }
}
