// lib/modules/billing/models/invoice_entity.dart

enum InvoiceStatus {
  pending,  // Pendente
  paid,     // Pago
  cancelled // Cancelado
}

class InvoiceEntity {
  final String id;
  final String customerId;
  final String customerName;
  final double amount;
  final DateTime dueDate;
  final InvoiceStatus status;
  final DateTime createdAt;

  InvoiceEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.dueDate,
    this.status = InvoiceStatus.pending,
    required this.createdAt,
  });

  // Método copyWith para facilitar atualizações de estado
  InvoiceEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    double? amount,
    DateTime? dueDate,
    InvoiceStatus? status,
    DateTime? createdAt,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}