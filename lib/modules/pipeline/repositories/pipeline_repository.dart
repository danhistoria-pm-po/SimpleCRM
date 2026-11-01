// lib/modules/pipeline/repositories/pipeline_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deal_entity.dart';

class PipelineRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Buscar todas as oportunidades da tabela 'deals'
  Future<List<DealEntity>> fetchDeals() async {
    try {
      final response = await _supabase.from('deals').select();

      return (response as List).map((data) {
        // Mapeia a string do banco para o enum DealStage corretamente
        DealStage stageVal = DealStage.potential;
        final stageStr = data['stage'] as String?;
        if (stageStr == 'inNegotiation') stageVal = DealStage.inNegotiation;
        if (stageStr == 'proposalSent') stageVal = DealStage.proposalSent;
        if (stageStr == 'activeClient') stageVal = DealStage.activeClient;
        if (stageStr == 'lost') stageVal = DealStage.lost;

        return DealEntity(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          customerId: data['customer_id'] ?? '',
          customerName: data['customer_name'] ?? '',
          value: (data['value'] != null) ? (data['value'] as num).toDouble() : 0.0,
          stage: stageVal,
          createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      // CORRIGIDO: Repassa o erro para o Controller avisar a tela
      rethrow;
    }
  }

  // Criar uma nova oportunidade na tabela 'deals'
  Future<void> createDeal(DealEntity deal) async {
    try {
      await _supabase.from('deals').insert({
        'title': deal.title,
        'customer_id': deal.customerId,
        'customer_name': deal.customerName,
        'value': deal.value,
        'stage': deal.stage.name,
        // O user_id é preenchido automaticamente pelo Supabase (default auth.uid())
      });
    } catch (e) {
      // CORRIGIDO: Repassa o erro
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
      // CORRIGIDO: Repassa o erro
      rethrow;
    }
  }

  // Deletar uma oportunidade diretamente pelo ID no Kanban
  Future<void> deleteDeal(String id) async {
    try {
      await _supabase.from('deals').delete().eq('id', id);
    } catch (e) {
      // CORRIGIDO: Repassa o erro
      rethrow;
    }
  }
}