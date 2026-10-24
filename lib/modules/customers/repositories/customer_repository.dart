// lib/modules/customers/repositories/customer_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/customer_entity.dart';

class CustomerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Buscar todos os clientes da tabela correta 'customers'
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _supabase.from('customers').select();
      
      return (response as List).map((data) {
        return Customer(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          phone: data['phone'],
          email: data['email'],
          address: data['address'],
          status: CustomerStatus.potential,
          notes: data['notes'],
          createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
          updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Erro ao carregar clientes do Supabase: $e');
      return [];
    }
  }

  // Inserir um novo cliente na tabela 'customers'
  Future<void> addCustomer(Customer customer) async {
    try {
      await _supabase.from('customers').insert({
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'notes': customer.notes,
      });
    } catch (e) {
      print('Erro ao salvar cliente no Supabase: $e');
      rethrow;
    }
  }

  // Deletar um cliente na tabela 'customers'
  Future<void> deleteCustomer(String id) async {
    try {
      await _supabase.from('customers').delete().eq('id', id);
    } catch (e) {
      print('Erro ao deletar cliente no Supabase: $e');
      rethrow;
    }
  }
}