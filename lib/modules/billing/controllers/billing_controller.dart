// lib/modules/billing/controllers/billing_controller.dart
import 'package:flutter/foundation.dart';
import '../models/invoice_entity.dart';
import '../repositories/billing_repository.dart';

class BillingController extends ChangeNotifier {
  final BillingRepository _repository = BillingRepository();

  List<InvoiceEntity> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceEntity> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carregar todas as faturas do Supabase
  Future<void> loadInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _invoices = await _repository.fetchInvoices();
    } catch (e) {
      _errorMessage = 'Erro ao carregar faturas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar uma nova fatura
  Future<bool> createInvoice(InvoiceEntity invoice) async {
    try {
      await _repository.createInvoice(invoice);
      await loadInvoices(); // Recarrega a lista após criar
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao criar fatura: $e';
      notifyListeners();
      return false;
    }
  }

  // Atualizar o status da fatura (ex: marcar como paga)
  Future<bool> updateInvoiceStatus(String id, InvoiceStatus newStatus) async {
    try {
      await _repository.updateInvoiceStatus(id, newStatus);
      await loadInvoices(); // Recarrega a lista após atualizar
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar status da fatura: $e';
      notifyListeners();
      return false;
    }
  }
}