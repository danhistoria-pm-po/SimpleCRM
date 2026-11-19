// lib/models/user_profile.dart
import '../config/niche_config.dart';

class UserProfile {
  static const List<String> supportedNiches = [
    'simplecrm',
    'clinica',
    'vet_pet',
    'imobiliaria',
    'curso',
  ];

  final String id;
  final String? email;
  final String niche;
  final String? promoCodeUsed;
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final bool isSubscribed;
  final DateTime? subscriptionEndsAt;
  final String planTier;
  final bool hasAiWhatsapp;

  const UserProfile({
    required this.id,
    this.email,
    this.niche = 'simplecrm',
    this.promoCodeUsed,
    this.trialStartedAt,
    this.trialEndsAt,
    this.isSubscribed = false,
    this.subscriptionEndsAt,
    this.planTier = 'comercio_49',
    this.hasAiWhatsapp = false,
  });

  factory UserProfile.fallback({
    required String id,
    String? email,
  }) {
    return UserProfile(
      id: id,
      email: email,
      niche: 'simplecrm',
      isSubscribed: false,
      planTier: 'comercio_49',
      hasAiWhatsapp: false,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final rawNiche = map['niche']?.toString().trim();
    final normalizedNiche =
        (rawNiche != null && supportedNiches.contains(rawNiche))
            ? rawNiche
            : 'simplecrm';

    final rawPlanTier = map['plan_tier']?.toString().trim();
    final normalizedPlanTier =
        (rawPlanTier != null && rawPlanTier.isNotEmpty)
            ? rawPlanTier
            : 'comercio_49';

    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString(),
      niche: normalizedNiche,
      promoCodeUsed: map['promo_code_used']?.toString(),
      trialStartedAt: _parseUtcDate(map['trial_started_at']),
      trialEndsAt: _parseUtcDate(map['trial_ends_at']),
      isSubscribed: map['is_subscribed'] == true,
      subscriptionEndsAt: _parseUtcDate(map['subscription_ends_at']),
      planTier: normalizedPlanTier,
      hasAiWhatsapp: map['has_ai_whatsapp'] == true,
    );
  }

  static DateTime? _parseUtcDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  /// Retorna `true` se o usuário possui assinatura ativa ou período gratuito vigente.
  bool get hasActiveAccess {
    final nowUtc = DateTime.now().toUtc();

    if (isSubscribed &&
        (subscriptionEndsAt == null ||
            subscriptionEndsAt!.toUtc().isAfter(nowUtc))) {
      return true;
    }

    if (trialEndsAt != null && trialEndsAt!.toUtc().isAfter(nowUtc)) {
      return true;
    }

    return false;
  }

  /// Calcula os dias restantes do período gratuito (arredondando para cima).
  int get remainingTrialDays {
    if (isSubscribed || trialEndsAt == null) return 0;

    final nowUtc = DateTime.now().toUtc();
    final endsUtc = trialEndsAt!.toUtc();
    if (!endsUtc.isAfter(nowUtc)) return 0;

    final diffHours = endsUtc.difference(nowUtc).inMinutes / 60.0;
    return (diffHours / 24.0).ceil();
  }

  /// Identifica se o perfil pertence ao plano Comércio (R$ 49,00/mês).
  bool get isComercioPlan => niche == 'simplecrm' && planTier == 'comercio_49';

  /// Retorna a configuração visual e terminológica do nicho ativo.
  NicheConfig get nicheConfig => NicheConfig.fromKey(niche);

  UserProfile copyWith({
    String? id,
    String? email,
    String? niche,
    String? promoCodeUsed,
    DateTime? trialStartedAt,
    DateTime? trialEndsAt,
    bool? isSubscribed,
    DateTime? subscriptionEndsAt,
    String? planTier,
    bool? hasAiWhatsapp,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      niche: niche ?? this.niche,
      promoCodeUsed: promoCodeUsed ?? this.promoCodeUsed,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionEndsAt: subscriptionEndsAt ?? this.subscriptionEndsAt,
      planTier: planTier ?? this.planTier,
      hasAiWhatsapp: hasAiWhatsapp ?? this.hasAiWhatsapp,
    );
  }
}
