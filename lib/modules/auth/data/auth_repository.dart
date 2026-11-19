// lib/modules/auth/data/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient? client;

  AuthRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // ATENÇÃO: Removemos o .trim() da senha. 
      // O e-mail pode ser limpo, mas a senha tem que ser enviada exatamente como digitada.
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password, 
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(_translateError(e));
    } catch (e) {
      throw Exception('Erro inesperado ao fazer login: $e');
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    bool lgpdConsent = true,
    String niche = 'simplecrm',
  }) async {
    final normalizedNiche =
        niche.trim().isNotEmpty ? niche.trim() : 'simplecrm';
    final planTier =
        normalizedNiche == 'simplecrm' ? 'comercio_49' : 'especializado_97';
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'lgpd_consent': lgpdConsent,
          'lgpd_consent_at': DateTime.now().toUtc().toIso8601String(),
          'niche': normalizedNiche,
          'plan_tier': planTier,
        },
      );

      final userId = response.user?.id;
      if (userId != null && userId.isNotEmpty) {
        try {
          await _supabase.from('profiles').upsert({
            'id': userId,
            'email': email.trim(),
            'niche': normalizedNiche,
            'plan_tier': planTier,
          });
        } catch (_) {
          // Se o e-mail exigir confirmação prévia (sem sessão ativa no RLS),
          // os metadados 'niche' e 'plan_tier' já ficam gravados no usuário.
        }
      }

      return response;
    } on AuthException catch (e) {
      throw Exception(_translateError(e));
    } catch (e) {
      throw Exception('Erro inesperado ao criar conta: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao sair da conta: $e');
    }
  }

  // NOVO: Tradutor de erros do Supabase para português claro (pt-BR)
  String _translateError(AuthException e) {
    final message = e.message.toLowerCase();
    
    if (message.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (message.contains('email not confirmed')) {
      return 'Por favor, confirme o seu e-mail antes de entrar.';
    }
    if (message.contains('user already registered')) {
      return 'Este e-mail já está cadastrado. Tente fazer login.';
    }
    if (message.contains('password should be at least 6 characters')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (message.contains('rate limit')) {
      return 'Muitas tentativas. Aguarde um momento e tente novamente.';
    }
    
    // Se for um erro que não mapeamos, devolve a mensagem original do Supabase
    return e.message; 
  }
}