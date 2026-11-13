// lib/modules/billing/presentation/billing_page.dart
import 'package:flutter/material.dart';
import '../controllers/billing_controller.dart';
import '../models/invoice_entity.dart';
import '../utils/nf_clipboard_helper.dart';
import '../../customers/domain/entities/customer_entity.dart';
import '../../customers/presentation/customer_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final BillingController _controller = BillingController();
  final CustomerController _customerController = CustomerController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _customerController.ensureLoaded();
    _controller.loadInvoices();
  }

  @override
  void dispose() {
    _controller.dispose();
    _authController.dispose();
    super.dispose();
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
                  backgroundColor: Colors.red,
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
        title: const Text('Gestão de Faturamento & Notas Fiscais'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final ok = await _controller.loadInvoices(silent: true);
              if (!ok && context.mounted && _controller.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_controller.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            tooltip: 'Atualizar Faturas',
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
                      style: const TextStyle(color: Colors.red, fontSize: 16),
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
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma fatura registada.\nClique no botão abaixo para emitir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
                                    backgroundColor: Colors.red,
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
                                  style: TextStyle(color: Colors.redAccent),
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
                            'Valor: R\$ ${invoice.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(
                            'Vencimento: ${_formatDate(invoice.dueDate)}',
                            style: const TextStyle(color: Colors.grey),
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
                                    backgroundColor: Colors.green,
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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.post_add),
        label: const Text('Nova Fatura'),
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color color;
    String label;

    switch (status) {
      case InvoiceStatus.pending:
        color = Colors.orange;
        label = 'Pendente';
        break;
      case InvoiceStatus.paid:
        color = Colors.green;
        label = 'Pago';
        break;
      case InvoiceStatus.cancelled:
        color = Colors.red;
        label = 'Cancelado';
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Fatura'),
      content: SingleChildScrollView(
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
                    'Nenhum cliente cadastrado. Cadastre um cliente primeiro na aba Clientes.',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  );
                }

                final validSelectedId = customers.any((c) => c.id == _selectedCustomerId)
                    ? _selectedCustomerId
                    : null;

                return DropdownButtonFormField<String>(
                  key: ValueKey(validSelectedId),
                  initialValue: validSelectedId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Cliente *'),
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
                Text('Vencimento: ${_formatDate(_selectedDueDate)}'),
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
            final parsedAmount = double.tryParse(
              _amountController.text.replaceAll(',', '.').trim(),
            );
            if (selectedCustomer == null || parsedAmount == null || parsedAmount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecione um cliente e informe um valor válido.'),
                  backgroundColor: Colors.red,
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
