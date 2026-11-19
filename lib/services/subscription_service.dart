// lib/services/subscription_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class SubscriptionService {
  final SupabaseClient? client;

  SubscriptionService({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  /// Busca o perfil do usuário autenticado na tabela `public.profiles`.
  /// Se o registro ainda não existir, retorna um fallback seguro sem acesso liberado.
  Future<UserProfile?> fetchCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        return UserProfile.fallback(id: user.id, email: user.email);
      }

      return UserProfile.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      debugPrint('Erro ao carregar perfil em public.profiles: $e');
      return UserProfile.fallback(id: user.id, email: user.email);
    }
  }

  /// Valida e ativa um código promocional via RPC `redeem_promo_code`.
  Future<Map<String, dynamic>> redeemPromoCode(String code) async {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      return {
        'ok': false,
        'error': 'Informe um código de convite válido.',
      };
    }

    try {
      final result = await _supabase.rpc(
        'redeem_promo_code',
        params: {'p_code': normalizedCode},
      );

      if (result is Map) {
        final map = Map<String, dynamic>.from(result);
        return {
          'ok': map['ok'] == true,
          if (map['error'] != null) 'error': map['error'].toString(),
          if (map['message'] != null) 'message': map['message'].toString(),
          ...map,
        };
      }

      if (result is bool) {
        return {
          'ok': result,
          if (!result) 'error': 'Não foi possível ativar o código informado.',
        };
      }

      return {
        'ok': true,
        'message': 'Período gratuito ativado com sucesso!',
      };
    } on PostgrestException catch (e) {
      return {
        'ok': false,
        'error': e.message.isNotEmpty
            ? e.message
            : 'Código inválido ou expirado.',
      };
    } catch (e) {
      return {
        'ok': false,
        'error': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Atualiza o nicho e o plano correspondente (`comercio_49` ou `especializado_97`)
  /// na tabela `public.profiles` do usuário autenticado.
  Future<void> updateNiche(String newNiche) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final normalizedNiche =
        UserProfile.supportedNiches.contains(newNiche.trim())
            ? newNiche.trim()
            : 'simplecrm';
    final newPlanTier =
        normalizedNiche == 'simplecrm' ? 'comercio_49' : 'especializado_97';

    await _supabase.from('profiles').update({
      'niche': normalizedNiche,
      'plan_tier': newPlanTier,
    }).eq('id', user.id);
  }
}
