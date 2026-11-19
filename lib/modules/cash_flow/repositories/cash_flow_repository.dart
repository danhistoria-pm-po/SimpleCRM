// lib/modules/cash_flow/repositories/cash_flow_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/niche_config.dart';
import '../models/cash_flow_entry_entity.dart';

class CashFlowRepository {
  final SupabaseClient? client;

  CashFlowRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  Future<List<CashFlowEntryEntity>> fetchEntries({String? niche}) async {
    final activeNiche = niche ?? ActiveNicheContext.current;
    try {
      final response = await _supabase
          .from('cash_flow')
          .select()
          .eq('niche', activeNiche)
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
              ? DateTime.parse(json['date']).toLocal()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createEntry(CashFlowEntryEntity entry, {String? niche}) async {
    final activeNiche = niche ?? ActiveNicheContext.current;
    try {
      await _supabase.from('cash_flow').insert({
        'description': entry.description,
        'value': entry.amount,
        'type': entry.type.name,
        'date': entry.date.toUtc().toIso8601String(),
        'niche': activeNiche,
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
