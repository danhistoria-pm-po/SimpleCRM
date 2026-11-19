// lib/modules/pipeline/repositories/pipeline_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/niche_config.dart';
import '../models/deal_entity.dart';

class PipelineRepository {
  final SupabaseClient? client;

  PipelineRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  // Buscar todas as oportunidades do nicho ativo da tabela 'deals' ordenadas por created_at desc
  Future<List<DealEntity>> fetchDeals({String? niche}) async {
    final activeNiche = niche ?? ActiveNicheContext.current;
    try {
      final response = await _supabase
          .from('deals')
          .select()
          .eq('niche', activeNiche)
          .order('created_at', ascending: false);

      return (response as List).map((data) {
        DealStage stageVal = DealStage.potential;
        final stageStr = data['stage'] as String?;
        if (stageStr == 'inNegotiation') stageVal = DealStage.inNegotiation;
        if (stageStr == 'proposalSent') stageVal = DealStage.proposalSent;
        if (stageStr == 'activeClient') stageVal = DealStage.activeClient;
        if (stageStr == 'lost') stageVal = DealStage.lost;

        return DealEntity(
          id: data['id']?.toString() ?? '',
          title: data['title'] ?? '',
          customerId: data['customer_id']?.toString() ?? '',
          customerName: data['customer_name'] ?? '',
          value: (data['value'] != null) ? (data['value'] as num).toDouble() : 0.0,
          stage: stageVal,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at']).toLocal()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Criar uma nova oportunidade na tabela 'deals' vinculada ao nicho ativo
  Future<void> createDeal(DealEntity deal, {String? niche}) async {
    final activeNiche = niche ?? ActiveNicheContext.current;
    try {
      await _supabase.from('deals').insert({
        'title': deal.title,
        'customer_id': deal.customerId,
        'customer_name': deal.customerName,
        'value': deal.value,
        'stage': deal.stage.name,
        'niche': activeNiche,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar o estágio de uma oportunidade
  Future<void> updateDealStage(String id, DealStage newStage) async {
    try {
      await _supabase.from('deals').update({
        'stage': newStage.name,
      }).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Deletar uma oportunidade diretamente pelo ID no Kanban
  Future<void> deleteDeal(String id) async {
    try {
      await _supabase.from('deals').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
