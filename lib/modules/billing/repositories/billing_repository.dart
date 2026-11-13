// lib/modules/billing/repositories/billing_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_entity.dart';

class BillingRepository {
  final SupabaseClient? client;

  BillingRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  // Buscar todas as faturas do Supabase ordenadas por vencimento (due_date)
  Future<List<InvoiceEntity>> fetchInvoices() async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .order('due_date', ascending: true);

      return (response as List).map((json) {
        return InvoiceEntity(
          id: json['id']?.toString() ?? '',
          customerId: json['customer_id']?.toString() ?? '',
          customerName: json['customer_name'] ?? '',
          amount: (json['value'] != null) ? (json['value'] as num).toDouble() : 0.0,
          dueDate: json['due_date'] != null
              ? DateTime.parse(json['due_date']).toLocal()
              : DateTime.now(),
          status: _parseStatus(json['status']?.toString() ?? 'pending'),
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at']).toLocal()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Inserir uma nova fatura (datas salvas em UTC)
  Future<void> createInvoice(InvoiceEntity invoice) async {
    try {
      await _supabase.from('invoices').insert({
        'customer_id': invoice.customerId,
        'customer_name': invoice.customerName,
        'value': invoice.amount,
        'due_date': invoice.dueDate.toUtc().toIso8601String(),
        'status': invoice.status.name,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar o status da fatura (ex: marcar como paga)
  Future<void> updateInvoiceStatus(String id, InvoiceStatus newStatus) async {
    try {
      await _supabase.from('invoices').update({
        'status': newStatus.name,
      }).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Excluir uma fatura
  Future<void> deleteInvoice(String id) async {
    try {
      await _supabase.from('invoices').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

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
