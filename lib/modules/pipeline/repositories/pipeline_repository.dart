// lib/modules/pipeline/repositories/pipeline_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deal_entity.dart';

class PipelineRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Buscar todas as oportunidades do Supabase
  Future<List<DealEntity>> fetchDeals() async {
    final response = await _supabase.from('deals').select();
    
    return (response as List).map((json) => DealEntity(
      id: json['id'],
      title: json['title'],
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'],
      value: (json['value'] as num).toDouble(),
      stage: _parseStage(json['stage']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    )).toList();
  }

  // Inserir uma nova oportunidade no Supabase
  Future<void> createDeal(DealEntity deal) async {
    await _supabase.from('deals').insert({
      'customer_id': deal.customerId.isNotEmpty ? deal.customerId : null,
      'title': deal.title,
      'customer_name': deal.customerName,
      'value': deal.value,
      'stage': deal.stage.name,
    });
  }

  // Atualizar o estágio de uma oportunidade
  Future<void> updateDealStage(String id, DealStage newStage) async {
    await _supabase.from('deals').update({
      'stage': newStage.name,
    }).eq('id', id);
  }

  // Conversão de String para o Enum DealStage
  DealStage _parseStage(String stageStr) {
    switch (stageStr) {
      case 'potential':
        return DealStage.potential;
      case 'inNegotiation':
        return DealStage.inNegotiation;
      case 'proposalSent':
        return DealStage.proposalSent;
      case 'activeClient':
        return DealStage.activeClient;
      case 'lost':
        return DealStage.lost;
      default:
        return DealStage.potential;
    }
  }
}