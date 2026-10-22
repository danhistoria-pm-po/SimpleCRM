// lib/modules/pipeline/repositories/pipeline_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/deal_entity.dart';

class PipelineRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Buscar todas as oportunidades da tabela 'deals' no Supabase
  Future<List<DealEntity>> fetchDeals() async {
    final response = await _supabase
        .from('deals')
        .select('*');

    return (response as List).map((item) {
      final dealId = item['eu ia']?.toString() ?? item['id']?.toString() ?? '';
      return DealEntity(
        id: dealId,
        customerId: item['id_do_cliente']?.toString() ?? '',
        title: item['title'] ?? item['título'] ?? item['titulo'] ?? '',
        customerName: item['customer_name'] ?? item['nome_cliente'] ?? '',
        value: double.tryParse(item['value']?.toString() ?? item['valor']?.toString() ?? '0') ?? 0.0,
        stage: _parseStage(item['stage'] ?? item['estagio']),
        createdAt: item['created_at'] != null ? DateTime.parse(item['created_at']) : DateTime.now(),
      );
    }).toList();
  }

  // Criar uma nova oportunidade na tabela 'deals' no Supabase
  Future<void> createDeal(DealEntity deal) async {
    final Map<String, dynamic> dataToInsert = {
      'title': deal.title,
      'customer_name': deal.customerName,
      'value': deal.value,
      'stage': deal.stage.name,
    };

    if (deal.customerId.isNotEmpty) {
      dataToInsert['id_do_cliente'] = deal.customerId;
    }

    await _supabase.from('deals').insert(dataToInsert);
  }

  // Atualizar o estágio de uma oportunidade na tabela 'deals'
  Future<void> updateDealStage(String id, DealStage newStage) async {
    debugPrint('A atualizar estágio do deal ID: $id para ${newStage.name}');
    
    try {
      // Tenta atualizar utilizando a chave primária real da tabela ('eu ia')
      await _supabase.from('deals').update({
        'stage': newStage.name,
      }).eq('eu ia', id);
      debugPrint('Estágio atualizado com sucesso usando "eu ia"!');
    } catch (e) {
      debugPrint('Falha ao atualizar com "eu ia", a tentar com "id"... Erro: $e');
      // Fallback de segurança caso utilize 'id'
      await _supabase.from('deals').update({
        'stage': newStage.name,
      }).eq('id', id);
    }
  }

  // Conversão segura baseada nos valores disponíveis do enum DealStage
  DealStage _parseStage(String? stageStr) {
    if (stageStr == null) return DealStage.values.first;

    try {
      return DealStage.values.firstWhere(
        (e) => e.name.toLowerCase() == stageStr.toLowerCase() ||
               e.toString().split('.').last.toLowerCase() == stageStr.toLowerCase(),
      );
    } catch (_) {
      return DealStage.values.first;
    }
  }
}