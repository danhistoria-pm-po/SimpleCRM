class FollowUpModel {
  final String id;
  final String customerId; // Mapeado para a tabela customers
  final String? dealId;
  final String title;
  final String? description;
  final DateTime scheduledDate;
  final String status; // 'pendente', 'concluido', 'cancelado'
  final int? satisfactionScore; // 1 a 5 (NPS/Feedback)
  final bool isReceived; // Confirmação de recebimento
  final DateTime? receivedDate; // Data da confirmação do recebimento
  final DateTime createdAt;

  FollowUpModel({
    required this.id,
    required this.customerId,
    this.dealId,
    required this.title,
    this.description,
    required this.scheduledDate,
    required this.status,
    this.satisfactionScore,
    required this.isReceived,
    this.receivedDate,
    required this.createdAt,
  });

  // Construtor para converter dados vindos do Supabase (Map) em Objeto Dart
  factory FollowUpModel.fromMap(Map<String, dynamic> map) {
    return FollowUpModel(
      id: map['id'] ?? '',
      customerId: map['customer_id'] ?? '',
      dealId: map['deal_id'],
      title: map['title'] ?? '',
      description: map['description'],
      scheduledDate: DateTime.parse(map['scheduled_date']),
      status: map['status'] ?? 'pendente',
      satisfactionScore: map['satisfaction_score'],
      isReceived: map['is_received'] ?? false,
      receivedDate: map['received_date'] != null 
          ? DateTime.parse(map['received_date']) 
          : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Método para converter o Objeto Dart em Map para enviar ao Supabase
  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'deal_id': dealId,
      'title': title,
      'description': description,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status,
      'satisfaction_score': satisfactionScore,
      'is_received': isReceived,
      'received_date': receivedDate?.toIso8601String(),
    };
  }

  // Método copyWith para facilitar atualizações parciais de estado
  FollowUpModel copyWith({
    String? id,
    String? customerId,
    String? dealId,
    String? title,
    String? description,
    DateTime? scheduledDate,
    String? status,
    int? satisfactionScore,
    bool? isReceived,
    DateTime? receivedDate,
    DateTime? createdAt,
  }) {
    return FollowUpModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      dealId: dealId ?? this.dealId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      satisfactionScore: satisfactionScore ?? this.satisfactionScore,
      isReceived: isReceived ?? this.isReceived,
      receivedDate: receivedDate ?? this.receivedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}