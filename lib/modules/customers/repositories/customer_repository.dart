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
      // CORRIGIDO: Em vez de esconder o erro e retornar uma lista vazia,
      // nós avisamos o Controller para que ele possa mostrar na tela.
      rethrow; 
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
        // O user_id é preenchido automaticamente pelo Supabase (default auth.uid())
      });
    } catch (e) {
      rethrow;
    }
  }

  // Deletar um cliente de forma atômica via RPC delete_customer_safe
  // Bloqueia se houver faturas (invoices) ou follow-ups vinculados; caso contrário, remove deals e o cliente.
  Future<void> deleteCustomer(String id) async {
    try {
      await _supabase.rpc(
        'delete_customer_safe',
        params: {'p_customer_id': id},
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('CLIENTE_COM_VINCULOS') || e.code == '23503') {
        throw Exception(
          'Este cliente possui faturas ou follow-ups. Exclua-os antes de remover o cliente.',
        );
      }
      rethrow;
    } catch (e) {
      if (e.toString().contains('CLIENTE_COM_VINCULOS')) {
        throw Exception(
          'Este cliente possui faturas ou follow-ups. Exclua-os antes de remover o cliente.',
        );
      }
      rethrow;
    }
  }
}