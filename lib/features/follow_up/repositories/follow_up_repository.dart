// lib/features/follow_up/repositories/follow_up_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/follow_up_model.dart';

class FollowUpRepository {
  final SupabaseClient? client;

  FollowUpRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  Future<List<FollowUpModel>> getFollowUps() async {
    try {
      final response = await _supabase
          .from('follow_ups')
          .select('*')
          .order('scheduled_date', ascending: true);

      return (response as List)
          .map((item) => FollowUpModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFollowUp(FollowUpModel followUp) async {
    try {
      await _supabase.from('follow_ups').insert(followUp.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFollowUp(FollowUpModel followUp) async {
    try {
      await _supabase
          .from('follow_ups')
          .update(followUp.toMap())
          .eq('id', followUp.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFollowUp(String id) async {
    try {
      await _supabase.from('follow_ups').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
