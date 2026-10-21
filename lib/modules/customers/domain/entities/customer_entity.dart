// lib/modules/customers/domain/entities/customer_entity.dart

enum CustomerStatus {
  potential,
  prospect,
  negotiation,
  active,
  inactive,
  afterSales,
}

class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address; // Campo de endereço adicionado
  final CustomerStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.status = CustomerStatus.potential,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    CustomerStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}