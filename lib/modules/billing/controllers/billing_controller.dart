// lib/modules/billing/controllers/billing_controller.dart
import 'package:flutter/foundation.dart';
import '../models/invoice_entity.dart';
import '../repositories/billing_repository.dart';

class BillingController extends ChangeNotifier {
  final BillingRepository _repository = BillingRepository();

  List<InvoiceEntity> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceEntity> get invoices => List.unmodifiable(_invoices);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _invoices = await _repository.fetchInvoices();
    } catch (e) {
      _errorMessage = 'Erro ao carregar faturas: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createInvoice(InvoiceEntity invoice) async {
    try {
      await _repository.createInvoice(invoice);
      await loadInvoices();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao criar fatura: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateInvoiceStatus(String id, InvoiceStatus newStatus) async {
    try {
      await _repository.updateInvoiceStatus(id, newStatus);
      await loadInvoices();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar status da fatura: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    try {
      await _repository.deleteInvoice(id);
      _invoices.removeWhere((inv) => inv.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir fatura: ${e.toString().replaceAll("Exception: ", "")}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }
}
