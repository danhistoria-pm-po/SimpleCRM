// lib/modules/customers/presentation/customer_form_modal.dart

import 'package:flutter/material.dart';

class CustomerFormModal extends StatelessWidget {
  final Function({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) onSave;

  const CustomerFormModal({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    return AlertDialog(
      title: const Text('Novo Cliente'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome *'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefone / WhatsApp'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Observações'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              onSave(
                name: nameController.text,
                phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                email: emailController.text.isNotEmpty ? emailController.text : null,
                address: addressController.text.isNotEmpty ? addressController.text : null,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}