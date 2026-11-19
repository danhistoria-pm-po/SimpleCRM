// lib/modules/billing/presentation/billing_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/logout_action.dart';
import '../../../core/widgets/tutorial_help_action.dart';
import '../../../widgets/niche_scope.dart';
import '../controllers/billing_controller.dart';
import '../models/invoice_entity.dart';
import '../utils/nf_clipboard_helper.dart';
import '../../customers/domain/entities/customer_entity.dart';
import '../../customers/presentation/customer_controller.dart';

class BillingPage extends StatefulWidget {
  final BillingController? controller;

  const BillingPage({super.key, this.controller});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  late final BillingController _controller;
  final CustomerController _customerController = CustomerController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? BillingController();
    _customerController.ensureLoaded();
    _controller.loadInvoices();
  }

  Future<bool> _confirmDeleteInvoice(String customerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir a fatura de "$customerName"?'),
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

  Customer _resolveCustomer(InvoiceEntity invoice) {
    for (final c in _customerController.customers) {
      if (c.id == invoice.customerId || c.name == invoice.customerName) {
        return c;
      }
    }
    return Customer(
      id: invoice.customerId,
      name: invoice.customerName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _showAddInvoiceModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _InvoiceFormDialog(
          customerController: _customerController,
          onSave: (newInvoice) async {
            final ok = await _controller.createInvoice(newInvoice);
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
        title: Text('${nicheConfig.shortName} - ${nicheConfig.billingTabLabel}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final ok = await _controller.loadInvoices(silent: true);
              if (!ok && context.mounted && _controller.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_controller.errorMessage!),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            tooltip: 'Atualizar Faturas',
          ),
          const NicheSwitcherAction(),
          const TutorialHelpAction(),
          const LogoutAction(),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null && _controller.invoices.isEmpty) {
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
                      onPressed: () => _controller.loadInvoices(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_controller.invoices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma fatura cadastrada.\nClique no botão abaixo para emitir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.invoices.length,
            itemBuilder: (context, index) {
              final invoice = _controller.invoices[index];
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
                            child: Text(
                              invoice.customerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusBadge(invoice.status),
                          IconButton(
                            key: ValueKey('btn-copy-invoice-summary-${invoice.id}'),
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 20,
                              color: nicheConfig.primaryColor,
                            ),
                            tooltip: 'Copiar resumo para Recibo/NF',
                            onPressed: () async {
                              final customer = _resolveCustomer(invoice);
                              final summary = [
                                '${nicheConfig.customerSingular}: ${customer.name}',
                                'Descrição: ${invoice.customerName}',
                                'Valor: ${formatCurrency(invoice.amount)}',
                                'Status: ${_statusLabel(invoice.status)}',
                                'Vencimento: ${formatDate(invoice.dueDate)}',
                              ].join('\n');
                              await Clipboard.setData(
                                ClipboardData(text: summary),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Dados copiados para emissão de recibo/NF!',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Opções da Fatura',
                            onSelected: (value) async {
                              bool ok = true;
                              if (value == 'delete') {
                                final confirmed = await _confirmDeleteInvoice(
                                  invoice.customerName,
                                );
                                if (!confirmed || !mounted) return;
                                ok = await _controller.deleteInvoice(invoice.id);
                              } else if (value == 'paid') {
                                ok = await _controller.updateInvoiceStatus(
                                  invoice.id,
                                  InvoiceStatus.paid,
                                );
                              } else if (value == 'pending') {
                                ok = await _controller.updateInvoiceStatus(
                                  invoice.id,
                                  InvoiceStatus.pending,
                                );
                              } else if (value == 'cancelled') {
                                ok = await _controller.updateInvoiceStatus(
                                  invoice.id,
                                  InvoiceStatus.cancelled,
                                );
                              }

                              if (!ok && context.mounted && _controller.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_controller.errorMessage!),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'paid',
                                child: Text('Marcar como Pago'),
                              ),
                              PopupMenuItem(
                                value: 'pending',
                                child: Text('Marcar como Pendente'),
                              ),
                              PopupMenuItem(
                                value: 'cancelled',
                                child: Text('Marcar como Cancelado'),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Excluir Fatura',
                                  style: TextStyle(color: AppColors.danger),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Valor: ${formatCurrency(invoice.amount)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Vencimento: ${formatDate(invoice.dueDate)}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final customer = _resolveCustomer(invoice);
                              await NfClipboardHelper.copyCustomerDataForNF(customer);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Dados copiados para a área de transferência para emissão de NF!',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copiar Dados p/ NF'),
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
        onPressed: _showAddInvoiceModal,
        icon: const Icon(Icons.add),
        label: Text(nicheConfig.newInvoiceLabel),
      ),
    );
  }

  String _statusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return 'Pendente';
      case InvoiceStatus.paid:
        return 'Pago';
      case InvoiceStatus.cancelled:
        return 'Cancelado';
    }
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color color;
    final label = _statusLabel(status);

    switch (status) {
      case InvoiceStatus.pending:
        color = AppColors.warning;
        break;
      case InvoiceStatus.paid:
        color = AppColors.success;
        break;
      case InvoiceStatus.cancelled:
        color = AppColors.danger;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _InvoiceFormDialog extends StatefulWidget {
  final CustomerController customerController;
  final Function(InvoiceEntity) onSave;

  const _InvoiceFormDialog({
    required this.customerController,
    required this.onSave,
  });

  @override
  State<_InvoiceFormDialog> createState() => _InvoiceFormDialogState();
}

class _InvoiceFormDialogState extends State<_InvoiceFormDialog> {
  final _amountController = TextEditingController();
  String? _selectedCustomerId;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _amountController.dispose();
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
      title: Text(nicheConfig.newInvoiceLabel),
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
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Valor (R\$) *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Vencimento: ${formatDate(_selectedDueDate)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _selectedDueDate = picked;
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
            final parsedAmount = parseCurrency(_amountController.text);
            if (selectedCustomer == null || parsedAmount == null || parsedAmount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecione um cliente e informe um valor válido.'),
                  backgroundColor: AppColors.danger,
                ),
              );
              return;
            }

            final newInvoice = InvoiceEntity(
              id: '',
              customerId: selectedCustomer.id,
              customerName: selectedCustomer.name,
              amount: parsedAmount,
              dueDate: _selectedDueDate,
              status: InvoiceStatus.pending,
              createdAt: DateTime.now(),
            );

            Navigator.pop(context);
            widget.onSave(newInvoice);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
