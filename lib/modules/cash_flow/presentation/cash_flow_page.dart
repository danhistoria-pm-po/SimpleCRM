// lib/modules/cash_flow/presentation/cash_flow_page.dart
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluxo de Caixa Simples'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadEntries(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null) {
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
                          'Nenhum registo financeiro encontrado.',
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
                                backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(entry.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Data: ${_formatDate(entry.date)}'),
                              trailing: Text(
                                '${isIncome ? '+' : '-'} R\$ ${entry.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isIncome ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
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
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
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