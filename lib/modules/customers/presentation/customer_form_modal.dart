// lib/modules/customers/presentation/customer_form_modal.dart
import 'package:flutter/material.dart';

class CustomerFormModal extends StatefulWidget {
  final Function({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) onSave;

  const CustomerFormModal({super.key, required this.onSave});

  @override
  State<CustomerFormModal> createState() => _CustomerFormModalState();
}

class _CustomerFormModalState extends State<CustomerFormModal> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Novo Cliente'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone / WhatsApp'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Observações'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              widget.onSave(
                name: name,
                phone: _phoneController.text.trim().isNotEmpty
                    ? _phoneController.text.trim()
                    : null,
                email: _emailController.text.trim().isNotEmpty
                    ? _emailController.text.trim()
                    : null,
                address: _addressController.text.trim().isNotEmpty
                    ? _addressController.text.trim()
                    : null,
                notes: _notesController.text.trim().isNotEmpty
                    ? _notesController.text.trim()
                    : null,
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
