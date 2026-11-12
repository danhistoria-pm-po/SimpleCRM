// lib/features/follow_up/views/follow_up_view.dart
import 'package:flutter/material.dart';
import '../controllers/follow_up_controller.dart';
import '../models/follow_up_model.dart';
import '../../../modules/customers/domain/entities/customer_entity.dart';
import '../../../modules/customers/presentation/customer_controller.dart';
import '../../../modules/auth/controllers/auth_controller.dart';

class FollowUpView extends StatefulWidget {
  const FollowUpView({super.key});

  @override
  State<FollowUpView> createState() => _FollowUpViewState();
}

class _FollowUpViewState extends State<FollowUpView> {
  final FollowUpController _controller = FollowUpController();
  final CustomerController _customerController = CustomerController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _controller.loadFollowUps();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirmDeleteFollowUp(String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o follow-up "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  String _resolveCustomerName(String customerId) {
    for (final c in _customerController.customers) {
      if (c.id == customerId) {
        return c.name;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pós-Venda & Follow-up'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => _controller.loadFollowUps(),
          ),
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
        animation: Listenable.merge([_controller, _customerController]),
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null && _controller.followUps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _controller.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (_controller.followUps.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum follow-up registado.\nClique no botão abaixo para agendar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.followUps.length,
            itemBuilder: (context, index) {
              final item = _controller.followUps[index];
              final customerName = _resolveCustomerName(item.customerId);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (customerName.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      'Cliente: $customerName',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.indigo.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(item.status),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            tooltip: 'Excluir Follow-up',
                            onPressed: () async {
                              final confirmed = await _confirmDeleteFollowUp(item.title);
                              if (!confirmed || !mounted) return;
                              await _controller.deleteFollowUp(item.id);
                            },
                          ),
                        ],
                      ),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: item.isReceived,
                                onChanged: (val) {
                                  if (val != null) {
                                    _controller.toggleReceived(item, val);
                                  }
                                },
                              ),
                              const Text(
                                'Recebido / Concluído',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Text(
                            'Agendado: ${_formatDate(item.scheduledDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFollowUpModal(context),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('Novo Follow-up'),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'concluido':
        color = Colors.green;
        break;
      case 'cancelado':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showAddFollowUpModal(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    Customer? selectedCustomer;
    DateTime scheduledDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Novo Follow-up'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedBuilder(
                      animation: _customerController,
                      builder: (context, _) {
                        final customers = _customerController.customers;
                        if (customers.isEmpty) {
                          return Text(
                            'Nenhum cliente cadastrado. Cadastre um cliente primeiro na aba Clientes.',
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                          );
                        }
                        return DropdownButtonFormField<Customer>(
                          initialValue: selectedCustomer,
                          decoration: const InputDecoration(labelText: 'Cliente *'),
                          items: customers.map((c) {
                            return DropdownMenuItem<Customer>(
                              value: c,
                              child: Text(c.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedCustomer = val;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título / Assunto *',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição / Observações',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Agendado p/: ${_formatDate(scheduledDate)}'),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: scheduledDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() {
                                scheduledDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Alterar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedCustomer == null || titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecione o cliente e informe o título do follow-up.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newFollowUp = FollowUpModel(
                      id: '',
                      customerId: selectedCustomer!.id,
                      title: titleController.text.trim(),
                      description: descController.text.trim().isNotEmpty
                          ? descController.text.trim()
                          : null,
                      scheduledDate: scheduledDate,
                      status: 'pendente',
                      isReceived: false,
                      createdAt: DateTime.now(),
                    );

                    Navigator.pop(dialogContext);
                    final ok = await _controller.addFollowUp(newFollowUp);
                    if (!mounted) return;
                    if (!ok && _controller.errorMessage != null) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(_controller.errorMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
