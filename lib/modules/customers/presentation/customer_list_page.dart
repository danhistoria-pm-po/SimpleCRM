// lib/modules/customers/presentation/customer_list_page.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/logout_action.dart';
import '../../../core/widgets/tutorial_help_action.dart';
import '../../../widgets/niche_scope.dart';
import '../domain/entities/customer_entity.dart';
import 'customer_controller.dart';
import 'customer_form_modal.dart';

class CustomerListPage extends StatefulWidget {
  final CustomerController? controller;

  const CustomerListPage({super.key, this.controller});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late final CustomerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CustomerController();
    _controller.ensureLoaded();
  }

  Future<bool> _confirmDeleteCustomer(String customerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o cliente "$customerName"? As oportunidades (deals) deste cliente no funil também serão removidas.',
        ),
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

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CustomerFormModal(
          onSave: ({required name, phone, email, address, notes}) async {
            final ok = await _controller.addCustomer(
              name: name,
              phone: phone,
              email: email,
              address: address,
              notes: notes,
            );
            if (!ok && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Erro ao salvar cliente: ${_controller.errorMessage ?? "Erro desconhecido"}',
                  ),
                  backgroundColor: AppColors.danger,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CustomerFormModal(
          initialCustomer: customer,
          onSave: ({required name, phone, email, address, notes}) async {
            final ok = await _controller.updateCustomer(
              id: customer.id,
              name: name,
              phone: phone,
              email: email,
              address: address,
              status: customer.status,
              notes: notes,
            );
            if (!ok && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Erro ao atualizar cliente: ${_controller.errorMessage ?? "Erro desconhecido"}',
                  ),
                  backgroundColor: AppColors.danger,
                  duration: const Duration(seconds: 5),
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
        title: Text('${nicheConfig.appName} - ${nicheConfig.customersTabLabel}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar ${nicheConfig.customersTabLabel}',
            onPressed: () async {
              final ok = await _controller.loadCustomers(silent: true);
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
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = _controller.customers;

          if (_controller.errorMessage != null && customers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.danger, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _controller.loadCustomers(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (customers.isEmpty) {
            return Center(
              child: Text(
                'Nenhum ${nicheConfig.customerSingular.toLowerCase()} cadastrado ainda.\nClique no botão abaixo para adicionar.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              final contactInfo = [
                customer.phone,
                customer.email,
                customer.address,
              ].where((item) => item != null && item.isNotEmpty).join(' • ');
              final hasNotes =
                  customer.notes != null && customer.notes!.trim().isNotEmpty;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  onTap: () => _showEditCustomerDialog(customer),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (contactInfo.isNotEmpty) Text(contactInfo),
                      if (hasNotes)
                        Padding(
                          padding: EdgeInsets.only(
                            top: contactInfo.isNotEmpty ? 4 : 0,
                          ),
                          child: Text(
                            customer.notes!.trim(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: nicheConfig.primaryColor,
                        ),
                        tooltip: 'Editar ${nicheConfig.customerSingular}',
                        onPressed: () => _showEditCustomerDialog(customer),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.danger),
                        tooltip: 'Excluir ${nicheConfig.customerSingular}',
                        onPressed: () async {
                          final confirmed =
                              await _confirmDeleteCustomer(customer.name);
                          if (!confirmed || !context.mounted) return;
                          final ok =
                              await _controller.removeCustomer(customer.id);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _controller.errorMessage ??
                                      'Erro ao excluir ${nicheConfig.customerSingular.toLowerCase()}.',
                                ),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        },
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
        onPressed: _showAddCustomerDialog,
        icon: const Icon(Icons.person_add),
        label: Text(nicheConfig.newCustomerLabel),
      ),
    );
  }
}
