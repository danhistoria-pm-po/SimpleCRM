import 'package:flutter/material.dart';
import '../controllers/follow_up_controller.dart';
import '../models/follow_up_model.dart';

class FollowUpView extends StatefulWidget {
  const FollowUpView({Key? key}) : super(key: key);

  @override
  State<FollowUpView> createState() => _FollowUpViewState();
}

class _FollowUpViewState extends State<FollowUpView> {
  final FollowUpController _controller = FollowUpController();

  @override
  void initState() {
    super.initState();
    _controller.loadFollowUps();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pós-Venda & Follow-up'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadFollowUps(),
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.followUps.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum follow-up registado.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _controller.followUps.length,
                  itemBuilder: (context, index) {
                    final item = _controller.followUps[index];
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
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _buildStatusBadge(item.status),
                              ],
                            ),
                            if (item.description != null &&
                                item.description!.isNotEmpty) ...[
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
                                // Checkbox de Recebido
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
                                      'Recebido',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                // Data agendada
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
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFollowUpModal(context),
        child: const Icon(Icons.add),
        tooltip: 'Novo Follow-up',
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
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
    final customerIdController = TextEditingController(); // Em breve podemos ligar à lista de clientes

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Follow-up'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customerIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID do Cliente (UUID)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título / Assunto',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição / Observações',
                  ),
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
              onPressed: () async {
                if (titleController.text.isNotEmpty && customerIdController.text.isNotEmpty) {
                  final newFollowUp = FollowUpModel(
                    id: '',
                    customerId: customerIdController.text.trim(),
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    scheduledDate: DateTime.now().add(const Duration(days: 7)),
                    status: 'pendente',
                    isReceived: false,
                    createdAt: DateTime.now(),
                  );
                  await _controller.addFollowUp(newFollowUp);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}