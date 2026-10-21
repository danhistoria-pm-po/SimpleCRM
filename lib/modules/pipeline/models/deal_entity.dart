// lib/modules/pipeline/models/deal_entity.dart
enum DealStage { 
  potential,       // Potencial / Lead
  inNegotiation,   // Em Negociação
  proposalSent,    // Proposta Enviada
  activeClient,    // Cliente Ativo (Ganho)
  lost             // Perdido
}

class DealEntity {
  final String id;
  final String customerId;
  final String customerName;
  final String title;
  final double value;
  final DealStage stage;
  final DateTime createdAt;

  DealEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.value,
    required this.stage,
    required this.createdAt,
  });

  DealEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? title,
    double? value,
    DealStage? stage,
    DateTime? createdAt,
  }) {
    return DealEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      value: value ?? this.value,
      stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}