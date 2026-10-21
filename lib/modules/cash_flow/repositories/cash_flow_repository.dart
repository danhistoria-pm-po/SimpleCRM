// lib/modules/cash_flow/repositories/cash_flow_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cash_flow_entry_entity.dart';

class CashFlowRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CashFlowEntryEntity>> fetchEntries() async {
    final response = await _supabase.from('cash_flow').select();
    
    return (response as List).map((json) => CashFlowEntryEntity(
      id: json['id'],
      description: json['description'],
      amount: (json['value'] as num).toDouble(),
      type: json['type'] == 'income' ? CashFlowType.income : CashFlowType.expense,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    )).toList();
  }

  Future<void> createEntry(CashFlowEntryEntity entry) async {
    await _supabase.from('cash_flow').insert({
      'description': entry.description,
      'value': entry.amount,
      'type': entry.type.name,
      'date': entry.date.toIso8601String(),
    });
  }
}