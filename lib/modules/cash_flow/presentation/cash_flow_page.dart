// lib/modules/cash_flow/presentation/cash_flow_page.dart
import 'package:flutter/material.dart';
import '../controllers/cash_flow_controller.dart';
import '../models/cash_flow_entry_entity.dart';
import '../../auth/controllers/auth_controller.dart';

class CashFlowPage extends StatefulWidget {
  const CashFlowPage({super.key});

  @override
  State<CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<CashFlowPage> {
  final CashFlowController _controller = CashFlowController();
  final AuthController _authController = AuthController();

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

  void _showAddEntryModal() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    CashFlowType selectedType = CashFlowType.income;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Novo Lançamento no Caixa'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Descrição *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Valor (R\$) *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CashFlowType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Tipo de Lançamento'),
                      items: const [
                        DropdownMenuItem(
                          value: CashFlowType.income,
                          child: Text('Entrada (Receita)'),
                        ),
                        DropdownMenuItem(
                          value: CashFlowType.expense,
                          child: Text('Saída (Despesa)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedType = val;
                          });
                        }
                      },
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
                    final parsedAmount = double.tryParse(
                      amountController.text.replaceAll(',', '.').trim(),
                    );
                    if (descriptionController.text.trim().isEmpty ||
                        parsedAmount == null ||
                        parsedAmount <= 0) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Informe uma descrição e um valor válido.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final entry = CashFlowEntryEntity(
                      id: '',
                      description: descriptionController.text.trim(),
                      amount: parsedAmount,
                      type: selectedType,
                      date: DateTime.now(),
                    );

                    Navigator.pop(dialogContext);
                    final ok = await _controller.createEntry(entry);
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
                  child: const Text('Salvar'),
                ),
              ],
            );
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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadEntries(),
            tooltip: 'Atualizar',
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

          if (_controller.errorMessage != null && _controller.entries.isEmpty) {
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

          return Column(
            children: [
              // Dashboard com Resumo Financeiro
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.indigo.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard('Entradas', _controller.totalIncome, Colors.green),
                    _buildSummaryCard('Saídas', _controller.totalExpense, Colors.red),
                    _buildSummaryCard('Saldo', _controller.netBalance, Colors.indigo),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _controller.entries.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum registo financeiro encontrado.\nClique no botão abaixo para lançar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _controller.entries.length,
                        itemBuilder: (context, index) {
                          final entry = _controller.entries[index];
                          final isIncome = entry.type == CashFlowType.income;
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isIncome
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                entry.description,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Data: ${_formatDate(entry.date)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${isIncome ? '+' : '-'} R\$ ${entry.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isIncome ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      final confirmed = await _confirmDeleteEntry(
                                        entry.description,
                                      );
                                      if (!confirmed || !mounted) return;
                                      await _controller.deleteEntry(entry.id);
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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'R\$ ${amount.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
