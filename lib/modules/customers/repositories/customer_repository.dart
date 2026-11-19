// lib/modules/customers/repositories/customer_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/niche_config.dart';
import '../domain/entities/customer_entity.dart';

class CustomerRepository {
  final SupabaseClient? client;

  CustomerRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  // Buscar todos os clientes do nicho ativo ordenados deterministicamente por nome
  Future<List<Customer>> getCustomers({String? niche}) async {
    final activeNiche = niche ?? ActiveNicheContext.current;
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('niche', activeNiche)
          .order('name', ascending: true);

      return (response as List).map((data) {
        return Customer(
          id: data['id']?.toString() ?? '',
          name: data['name'] ?? '',
          phone: data['phone'],
          email: data['email'],
          address: data['address'],
          status: CustomerStatus.potential,
          notes: data['notes'],
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at']).toLocal()
              : DateTime.now(),
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at']).toLocal()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Inserir um novo cliente na tabela 'customers' vinculado ao nicho ativo
  Future<void> addCustomer(Customer customer, {String? niche}) async {
    final activeNiche = niche ?? ActiveNicheContext.current;
    try {
      await _supabase.from('customers').insert({
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'notes': customer.notes,
        'niche': activeNiche,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar os dados de um cliente existente na tabela 'customers'
  // e manter customer_name sincronizado em deals e invoices vinculados.
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _supabase.from('customers').update({
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'notes': customer.notes,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', customer.id);

      await _supabase
          .from('deals')
          .update({'customer_name': customer.name})
          .eq('customer_id', customer.id);

      await _supabase
          .from('invoices')
          .update({'customer_name': customer.name})
          .eq('customer_id', customer.id);
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
