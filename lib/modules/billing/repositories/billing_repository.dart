// lib/modules/billing/repositories/billing_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_entity.dart';

class BillingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Buscar todas as faturas do Supabase
  Future<List<InvoiceEntity>> fetchInvoices() async {
    final response = await _supabase.from('invoices').select();
    
    return (response as List).map((json) => InvoiceEntity(
      id: json['id'],
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'],
      amount: (json['value'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      status: _parseStatus(json['status']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    )).toList();
  }

  // Inserir uma nova fatura
  Future<void> createInvoice(InvoiceEntity invoice) async {
    await _supabase.from('invoices').insert({
      'customer_id': invoice.customerId,
      'customer_name': invoice.customerName,
      'value': invoice.amount,
      'due_date': invoice.dueDate.toIso8601String(),
      'status': invoice.status.name,
    });
  }

  // Atualizar o status da fatura (ex: marcar como paga)
  Future<void> updateInvoiceStatus(String id, InvoiceStatus newStatus) async {
    await _supabase.from('invoices').update({
      'status': newStatus.name,
    }).eq('id', id);
  }

  // Conversão de String para o Enum InvoiceStatus
  InvoiceStatus _parseStatus(String statusStr) {
    switch (statusStr) {
      case 'pending':
        return InvoiceStatus.pending;
      case 'paid':
        return InvoiceStatus.paid;
      case 'cancelled':
        return InvoiceStatus.cancelled;
      default:
        return InvoiceStatus.pending;
    }
  }
}