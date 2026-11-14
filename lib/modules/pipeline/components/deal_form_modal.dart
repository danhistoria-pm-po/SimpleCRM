// lib/modules/pipeline/components/deal_form_modal.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../customers/domain/entities/customer_entity.dart';
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

  String? _selectedCustomerId;
  DealStage _selectedStage = DealStage.potential;

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Customer? _findSelectedCustomer(List<Customer> customers) {
    if (_selectedCustomerId == null) return null;
    for (final c in customers) {
      if (c.id == _selectedCustomerId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Nova Oportunidade'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título da Oportunidade'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Informe o título' : null,
                ),
                const SizedBox(height: 12),

                // Seletor Dinâmico de Clientes Cadastrados por ID (String)
                AnimatedBuilder(
                  animation: widget.customerController,
                  builder: (context, child) {
                    final customers = widget.customerController.customers;

                    if (customers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Nenhum cliente cadastrado. Cadastre um cliente primeiro na aba Clientes.',
                          style: TextStyle(color: AppColors.danger, fontSize: 12),
                        ),
                      );
                    }

                    final validSelectedId = customers.any((c) => c.id == _selectedCustomerId)
                        ? _selectedCustomerId
                        : null;

                    return DropdownButtonFormField<String>(
                      key: ValueKey(validSelectedId),
                      initialValue: validSelectedId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Selecione o Cliente'),
                      items: customers.map((customer) {
                        return DropdownMenuItem<String>(
                          value: customer.id,
                          child: Text(
                            customer.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (customerId) {
                        setState(() {
                          _selectedCustomerId = customerId;
                        });
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Selecione um cliente' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final parsed = parseCurrency(value ?? '');
                    return parsed == null || parsed <= 0
                        ? 'Informe um valor válido'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DealStage>(
                  initialValue: _selectedStage,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Etapa Inicial'),
                  items: DealStage.values.map((stage) {
                    return DropdownMenuItem(
                      value: stage,
                      child: Text(
                        _getStageLabel(stage),
                        overflow: TextOverflow.ellipsis,
                      ),
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedCustomer = _findSelectedCustomer(
              widget.customerController.customers,
            );
            if (_formKey.currentState!.validate() && selectedCustomer != null) {
              final parsedValue = parseCurrency(_valueController.text) ?? 0.0;
              final newDeal = DealEntity(
                id: '',
                customerId: selectedCustomer.id,
                customerName: selectedCustomer.name,
                title: _titleController.text.trim(),
                value: parsedValue,
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
