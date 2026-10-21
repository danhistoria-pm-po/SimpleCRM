// lib/modules/cash_flow/models/cash_flow_entry_entity.dart

enum CashFlowType { income, expense }

class CashFlowEntryEntity {
  final String id;
  final String description;
  final double amount;
  final CashFlowType type;
  final DateTime date;

  CashFlowEntryEntity({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  CashFlowEntryEntity copyWith({
    String? id,
    String? description,
    double? amount,
    CashFlowType? type,
    DateTime? date,
  }) {
    return CashFlowEntryEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}