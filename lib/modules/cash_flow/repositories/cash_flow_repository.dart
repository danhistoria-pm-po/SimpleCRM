// lib/modules/cash_flow/repositories/cash_flow_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cash_flow_entry_entity.dart';

class CashFlowRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CashFlowEntryEntity>> fetchEntries() async {
    try {
      final response = await _supabase
          .from('cash_flow')
          .select()
          .order('date', ascending: false);

      return (response as List).map((json) {
        return CashFlowEntryEntity(
          id: json['id']?.toString() ?? '',
          description: json['description'] ?? '',
          amount: (json['value'] != null) ? (json['value'] as num).toDouble() : 0.0,
          type: json['type'] == 'income'
              ? CashFlowType.income
              : CashFlowType.expense,
          date: json['date'] != null
              ? DateTime.parse(json['date'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createEntry(CashFlowEntryEntity entry) async {
    try {
      await _supabase.from('cash_flow').insert({
        'description': entry.description,
        'value': entry.amount,
        'type': entry.type.name,
        'date': entry.date.toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _supabase.from('cash_flow').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
