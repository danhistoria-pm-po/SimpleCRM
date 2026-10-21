// lib/modules/pipeline/components/deal_form_modal.dart
import 'package:flutter/material.dart';
import '../models/deal_entity.dart';

class DealFormModal extends StatefulWidget {
  final Function(DealEntity) onSave;

  const DealFormModal({super.key, required this.onSave});

  @override
  State<DealFormModal> createState() => _DealFormModalState();
}

class _DealFormModalState extends State<DealFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _valueController = TextEditingController();
  
  DealStage _selectedStage = DealStage.potential;

  @override
  void dispose() {
    _titleController.dispose();
    _customerNameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newDeal = DealEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: 'c_${DateTime.now().millisecondsSinceEpoch}',
        customerName: _customerNameController.text,
        title: _titleController.text,
        value: double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0,
        stage: _selectedStage,
        createdAt: DateTime.now(),
      );

      widget.onSave(newDeal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nova Oportunidade',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do Negócio (Ex: Implantação)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o título do negócio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente / Empresa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o nome do cliente'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Digite um valor numérico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DealStage>(
                value: _selectedStage,
                decoration: const InputDecoration(
                  labelText: 'Estágio Inicial',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: DealStage.potential, child: Text('Potencial')),
                  DropdownMenuItem(value: DealStage.inNegotiation, child: Text('Em Negociação')),
                  DropdownMenuItem(value: DealStage.proposalSent, child: Text('Proposta Enviada')),
                  DropdownMenuItem(value: DealStage.activeClient, child: Text('Cliente Ativo')),
                  DropdownMenuItem(value: DealStage.lost, child: Text('Perdido')),
                ],
                onChanged: (stage) {
                  if (stage != null) setState(() => _selectedStage = stage);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Oportunidade'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}