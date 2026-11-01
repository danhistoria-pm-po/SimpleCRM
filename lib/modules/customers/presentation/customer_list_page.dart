// lib/modules/customers/presentation/customer_list_page.dart

import 'package:flutter/material.dart';
import 'customer_controller.dart';
import 'customer_form_modal.dart'; 
import '../../auth/controllers/auth_controller.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final CustomerController _controller = CustomerController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    // CORREÇÃO: Força a busca de dados toda vez que a aba é montada
    _controller.loadCustomers();
  }

  // ⚠️ O método dispose() foi REMOVIDO daqui para não destruir o Singleton.

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CustomerFormModal(
          onSave: ({required name, phone, email, address, notes}) async {
            try {
              await _controller.addCustomer(
                name: name,
                phone: phone,
                email: email,
                address: address,
                notes: notes,
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao salvar cliente: ${e.toString().replaceAll("Exception: ", "")}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleCRM - Clientes'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await _authController.logout(); 
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // CORREÇÃO: Mostra o loading enquanto o banco responde
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = _controller.customers;

          if (customers.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum cliente cadastrado ainda.\nClique no botão abaixo para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    [
                      customer.phone,
                      customer.email,
                      customer.address,
                    ].where((item) => item != null && item.isNotEmpty).join(' • '),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      // Adicionando tratamento de erro também no delete
                      try {
                        await _controller.removeCustomer(customer.id);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao excluir: ${e.toString().replaceAll("Exception: ", "")}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Cliente'),
      ),
    );
  }
}