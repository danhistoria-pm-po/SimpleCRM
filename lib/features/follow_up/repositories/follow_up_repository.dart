import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/follow_up_model.dart';

class FollowUpRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obter todos os follow-ups ordenados por data agendada
  Future<List<FollowUpModel>> getFollowUps() async {
    final response = await _supabase
        .from('follow_ups')
        .select('*')
        .order('scheduled_date', ascending: true);

    return (response as List)
        .map((item) => FollowUpModel.fromMap(item))
        .toList();
  }

  // Adicionar um novo follow-up à base de dados
  Future<void> addFollowUp(FollowUpModel followUp) async {
    await _supabase.from('follow_ups').insert(followUp.toMap());
  }

  // Atualizar um follow-up existente (ex: marcar como concluído ou alterar o recebimento)
  Future<void> updateFollowUp(FollowUpModel followUp) async {
    await _supabase
        .from('follow_ups')
        .update(followUp.toMap())
        .eq('id', followUp.id);
  }

  // Eliminar um follow-up pelo ID
  Future<void> deleteFollowUp(String id) async {
    await _supabase.from('follow_ups').delete().eq('id', id);
  }
}