// lib/features/follow_up/views/follow_up_view.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/logout_action.dart';
import '../../../core/widgets/tutorial_help_action.dart';
import '../../../widgets/niche_scope.dart';
import '../controllers/follow_up_controller.dart';
import '../models/follow_up_model.dart';
import '../../../modules/customers/domain/entities/customer_entity.dart';
import '../../../modules/customers/presentation/customer_controller.dart';

class FollowUpView extends StatefulWidget {
  final FollowUpController? controller;
  final CustomerController? customerController;

  const FollowUpView({
    super.key,
    this.controller,
    this.customerController,
  });

  @override
  State<FollowUpView> createState() => _FollowUpViewState();
}

class _FollowUpViewState extends State<FollowUpView> {
  late final FollowUpController _controller;
  late final CustomerController _customerController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FollowUpController();
    _customerController = widget.customerController ?? CustomerController();
    _customerController.ensureLoaded();
    _controller.loadFollowUps();
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
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.surface,
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

  void _showAddFollowUpModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _FollowUpFormDialog(
          customerController: _customerController,
          onSave: (newFollowUp) async {
            final ok = await _controller.addFollowUp(newFollowUp);
            if (!mounted) return;
            if (!ok && _controller.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_controller.errorMessage!),
                  backgroundColor: AppColors.danger,
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
    final nicheConfig = NicheScope.configOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${nicheConfig.shortName} - ${nicheConfig.followUpTabLabel}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () async {
              final ok = await _controller.loadFollowUps(silent: true);
              if (!ok && context.mounted && _controller.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_controller.errorMessage!),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
          ),
          const NicheSwitcherAction(),
          const TutorialHelpAction(),
          const LogoutAction(),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _controller.errorMessage!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _controller.loadFollowUps(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_controller.followUps.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum follow-up cadastrado.\nClique no botão abaixo para agendar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
                                      '${nicheConfig.customerSingular}: $customerName',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: nicheConfig.primaryColor,
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
                              color: AppColors.danger,
                              size: 20,
                            ),
                            tooltip: 'Excluir Follow-up',
                            onPressed: () async {
                              final confirmed =
                                  await _confirmDeleteFollowUp(item.title);
                              if (!confirmed || !context.mounted) return;
                              final ok = await _controller.deleteFollowUp(item.id);
                              if (!ok &&
                                  context.mounted &&
                                  _controller.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_controller.errorMessage!),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: const TextStyle(color: AppColors.textSecondary),
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
                                onChanged: (val) async {
                                  if (val != null) {
                                    final ok =
                                        await _controller.toggleReceived(item, val);
                                    if (!ok &&
                                        context.mounted &&
                                        _controller.errorMessage != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(_controller.errorMessage!),
                                          backgroundColor: AppColors.danger,
                                        ),
                                      );
                                    }
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
                            'Agendado: ${formatDate(item.scheduledDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Satisfação:',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int star = 1; star <= 5; star++)
                                IconButton(
                                  key: ValueKey('follow-up-${item.id}-star-$star'),
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  tooltip: 'Nota $star',
                                  icon: Icon(
                                    (item.satisfactionScore ?? 0) >= star
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: (item.satisfactionScore ?? 0) >= star
                                        ? AppColors.warning
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  onPressed: () async {
                                    final ok = await _controller.setSatisfactionScore(
                                      item,
                                      star,
                                    );
                                    if (!ok &&
                                        context.mounted &&
                                        _controller.errorMessage != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(_controller.errorMessage!),
                                          backgroundColor: AppColors.danger,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              const SizedBox(width: 4),
                              Text(
                                item.satisfactionScore != null
                                    ? '${item.satisfactionScore}/5'
                                    : 'Sem nota',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
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
        onPressed: _showAddFollowUpModal,
        icon: const Icon(Icons.add_task),
        label: const Text('Novo Follow-up'),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'concluido':
        color = AppColors.success;
        break;
      case 'cancelado':
        color = AppColors.danger;
        break;
      default:
        color = AppColors.warning;
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
}

class _FollowUpFormDialog extends StatefulWidget {
  final CustomerController customerController;
  final Function(FollowUpModel) onSave;

  const _FollowUpFormDialog({
    required this.customerController,
    required this.onSave,
  });

  @override
  State<_FollowUpFormDialog> createState() => _FollowUpFormDialogState();
}

class _FollowUpFormDialogState extends State<_FollowUpFormDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCustomerId;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
    final nicheConfig = NicheScope.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text('Novo ${nicheConfig.followUpTabLabel}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedBuilder(
                animation: widget.customerController,
                builder: (context, _) {
                  final customers = widget.customerController.customers;
                  if (customers.isEmpty) {
                    return Text(
                      'Nenhum ${nicheConfig.customerSingular.toLowerCase()} cadastrado. Cadastre primeiro na aba ${nicheConfig.customersTabLabel}.',
                      style: const TextStyle(color: AppColors.danger, fontSize: 12),
                    );
                  }

                  final validSelectedId = customers.any((c) => c.id == _selectedCustomerId)
                      ? _selectedCustomerId
                      : null;

                  return DropdownButtonFormField<String>(
                    key: ValueKey(validSelectedId),
                    initialValue: validSelectedId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: '${nicheConfig.customerSingular} *',
                    ),
                    items: customers.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(
                          c.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCustomerId = val;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título / Assunto *',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descrição / Observações',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Agendado p/: ${formatDate(_scheduledDate)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _scheduledDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _scheduledDate = picked;
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedCustomer = _findSelectedCustomer(
              widget.customerController.customers,
            );
            if (selectedCustomer == null || _titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecione o cliente e informe o título do follow-up.'),
                  backgroundColor: AppColors.danger,
                ),
              );
              return;
            }

            final newFollowUp = FollowUpModel(
              id: '',
              customerId: selectedCustomer.id,
              title: _titleController.text.trim(),
              description: _descController.text.trim().isNotEmpty
                  ? _descController.text.trim()
                  : null,
              scheduledDate: _scheduledDate,
              status: 'pendente',
              isReceived: false,
              createdAt: DateTime.now(),
            );

            Navigator.pop(context);
            widget.onSave(newFollowUp);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
