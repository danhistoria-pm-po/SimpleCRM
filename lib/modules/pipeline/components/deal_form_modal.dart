// lib/modules/pipeline/components/deal_form_modal.dart
import 'package:flutter/material.dart';
import '../../customers/presentation/customer_controller.dart';
import '../models/deal_entity.dart';

class DealFormModal extends StatefulWidget {
  final Function(DealEntity) onSave;
  final CustomerController customerController;

  const DealFormModal({
    super.key,
    required this.onSave,
    required this.customerController,
  });

  @override
  State<DealFormModal> createState() => _DealFormModalState();
}

class _DealFormModalState extends State<DealFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  
  dynamic _selectedCustomer;
  DealStage _selectedStage = DealStage.potential;

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nova Oportunidade',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título da Oportunidade'),
                  validator: (value) => value == null || value.isEmpty ? 'Informe o título' : null,
                ),
                const SizedBox(height: 12),
                
                // Seletor Dinâmico de Clientes Cadastrados
                AnimatedBuilder(
                  animation: widget.customerController,
                  builder: (context, child) {
                    final customers = widget.customerController.customers;

                    if (customers.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Nenhum cliente cadastrado. Cadastre um cliente primeiro na aba Clientes.',
                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        ),
                      );
                    }

                    return DropdownButtonFormField<dynamic>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(labelText: 'Selecione o Cliente'),
                      items: customers.map((customer) {
                        return DropdownMenuItem<dynamic>(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (customer) {
                        setState(() {
                          _selectedCustomer = customer;
                        });
                      },
                      validator: (value) => value == null ? 'Selecione um cliente' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(labelText: 'Valor (R\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Informe um valor válido' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DealStage>(
                  value: _selectedStage,
                  decoration: const InputDecoration(labelText: 'Etapa Inicial'),
                  items: DealStage.values.map((stage) {
                    return DropdownMenuItem(
                      value: stage,
                      child: Text(_getStageLabel(stage)),
                    );
                  }).toList(),
                  onChanged: (stage) {
                    if (stage != null) {
                      setState(() {
                        _selectedStage = stage;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && _selectedCustomer != null) {
                          final newDeal = DealEntity(
                            id: '',
                            customerId: _selectedCustomer.id,
                            customerName: _selectedCustomer.name,
                            title: _titleController.text,
                            value: double.tryParse(_valueController.text) ?? 0.0,
                            stage: _selectedStage,
                            createdAt: DateTime.now(),
                          );

                          widget.onSave(newDeal);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStageLabel(DealStage stage) {
    switch (stage) {
      case DealStage.potential:
        return 'Potencial';
      case DealStage.inNegotiation:
        return 'Em Negociação';
      case DealStage.proposalSent:
        return 'Proposta Enviada';
      case DealStage.activeClient:
        return 'Cliente Ativo';
      case DealStage.lost:
        return 'Perdido';
    }
  }
}