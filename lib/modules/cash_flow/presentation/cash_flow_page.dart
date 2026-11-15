// lib/modules/cash_flow/presentation/cash_flow_page.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/logout_action.dart';
import '../../../core/widgets/tutorial_help_action.dart';
import '../controllers/cash_flow_controller.dart';
import '../models/cash_flow_entry_entity.dart';

class CashFlowPage extends StatefulWidget {
  const CashFlowPage({super.key});

  @override
  State<CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<CashFlowPage> {
  final CashFlowController _controller = CashFlowController();

  @override
  void initState() {
    super.initState();
    _controller.loadEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirmDeleteEntry(String description) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o lançamento "$description"?'),
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

  void _showAddEntryModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _CashFlowEntryFormDialog(
          onSave: (entry) async {
            final ok = await _controller.createEntry(entry);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluxo de Caixa Simples'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final ok = await _controller.loadEntries(silent: true);
              if (!ok && context.mounted && _controller.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_controller.errorMessage!),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            tooltip: 'Atualizar',
          ),
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

          if (_controller.errorMessage != null && _controller.entries.isEmpty) {
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
                      onPressed: () => _controller.loadEntries(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Dashboard com Resumo Financeiro
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primaryLight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard('Entradas', _controller.totalIncome, AppColors.success),
                    _buildSummaryCard('Saídas', _controller.totalExpense, AppColors.danger),
                    _buildSummaryCard('Saldo', _controller.netBalance, AppColors.primaryDark),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _controller.entries.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum registro financeiro encontrado.\nClique no botão abaixo para lançar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _controller.entries.length,
                        itemBuilder: (context, index) {
                          final entry = _controller.entries[index];
                          final isIncome = entry.type == CashFlowType.income;
                          final entryColor = isIncome ? AppColors.success : AppColors.danger;
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: entryColor.withValues(alpha: 0.12),
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: entryColor,
                                ),
                              ),
                              title: Text(
                                entry.description,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Data: ${formatDate(entry.date)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${isIncome ? '+' : '-'} ${formatCurrency(entry.amount)}',
                                    style: TextStyle(
                                      color: entryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.danger,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      final confirmed = await _confirmDeleteEntry(
                                        entry.description,
                                      );
                                      if (!confirmed || !context.mounted) return;
                                      final ok = await _controller.deleteEntry(entry.id);
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
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryModal,
        icon: const Icon(Icons.add),
        label: const Text('Novo Lançamento'),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatCurrency(amount),
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _CashFlowEntryFormDialog extends StatefulWidget {
  final Function(CashFlowEntryEntity) onSave;

  const _CashFlowEntryFormDialog({required this.onSave});

  @override
  State<_CashFlowEntryFormDialog> createState() => _CashFlowEntryFormDialogState();
}

class _CashFlowEntryFormDialogState extends State<_CashFlowEntryFormDialog> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  CashFlowType _selectedType = CashFlowType.income;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Novo Lançamento no Caixa'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Valor (R\$) *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CashFlowType>(
                initialValue: _selectedType,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tipo de Lançamento'),
                items: const [
                  DropdownMenuItem(
                    value: CashFlowType.income,
                    child: Text(
                      'Entrada (Receita)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: CashFlowType.expense,
                    child: Text(
                      'Saída (Despesa)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
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
            final parsedAmount = parseCurrency(_amountController.text);
            if (_descriptionController.text.trim().isEmpty ||
                parsedAmount == null ||
                parsedAmount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Informe uma descrição e um valor válido.'),
                  backgroundColor: AppColors.danger,
                ),
              );
              return;
            }

            final entry = CashFlowEntryEntity(
              id: '',
              description: _descriptionController.text.trim(),
              amount: parsedAmount,
              type: _selectedType,
              date: DateTime.now(),
            );

            Navigator.pop(context);
            widget.onSave(entry);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
