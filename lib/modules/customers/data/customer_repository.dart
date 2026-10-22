// lib/modules/customers/data/customer_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/customer_entity.dart';

class CustomerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obter todos os clientes da tabela 'clientes' no Supabase
  Future<List<Customer>> getCustomers() async {
    final response = await _supabase
        .from('clientes')
        .select('*');

    return (response as List).map((item) {
      return Customer(
        id: item['eu ia']?.toString() ?? '', // Mapeado para a chave primária 'eu ia'
        name: item['nome'] ?? '',            // Mapeado para a coluna 'nome'
        phone: item['telefone'],             // Mapeado para a coluna 'telefone'
        email: item['e-mail'],               // Mapeado para a coluna 'e-mail'
        address: item['endereco'],           // Caso exista na tabela
        status: CustomerStatus.potential,
        notes: item['notas'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  // Inserir um novo cliente na tabela 'clientes' do Supabase
  Future<void> addCustomer(Customer customer) async {
    await _supabase.from('clientes').insert({
      'nome': customer.name,
      'telefone': customer.phone,
      'e-mail': customer.email,
      'endereco': customer.address,
      'notas': customer.notes,
    });
  }

  // Eliminar um cliente pelo ID ('eu ia') no Supabase
  Future<void> deleteCustomer(String id) async {
    await _supabase.from('clientes').delete().eq('eu ia', id);
  }
}