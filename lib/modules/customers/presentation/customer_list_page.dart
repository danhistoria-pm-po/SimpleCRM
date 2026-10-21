// lib/modules/customers/presentation/customer_list_page.dart

import 'package:flutter/material.dart';
import 'customer_controller.dart';
import 'customer_form_modal.dart'; // <--- Importamos o nosso novo modal

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final CustomerController _controller = CustomerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomerFormModal(
          onSave: ({required name, phone, email, address, notes}) {
            _controller.addCustomer(
              name: name,
              phone: phone,
              email: email,
              address: address,
              notes: notes,
            );
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
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
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
                    onPressed: () => _controller.removeCustomer(customer.id),
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