// lib/modules/pipeline/presentation/pipeline_page.dart
import 'package:flutter/material.dart';
import '../controllers/pipeline_controller.dart';
import '../models/deal_entity.dart';
import '../components/pipeline_column.dart';
import '../components/deal_form_modal.dart';
import '../../customers/presentation/customer_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class PipelinePage extends StatefulWidget {
  const PipelinePage({super.key});

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage> {
  final PipelineController _controller = PipelineController();
  final CustomerController _customerController = CustomerController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _loadDealsComTratamentoDeErro(); // Chama a versão com tratamento de erro
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  // --- MÉTODOS DE TRATAMENTO DE ERRO ---

  Future<void> _loadDealsComTratamentoDeErro() async {
    try {
      await _controller.loadDeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar oportunidades: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAddDeal(DealEntity deal) async {
    try {
      await _controller.addDeal(deal);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar oportunidade: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateStage(String id, DealStage newStage) async {
    try {
      await _controller.updateDealStage(id, newStage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao mover oportunidade: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteDeal(String id) async {
    try {
      await _controller.deleteDeal(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir oportunidade: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ------------------------------------

  void _showAddDealDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DealFormModal(
          customerController: _customerController,
          onSave: (deal) async {
            // Usa a função de tratamento de erro
            await _handleAddDeal(deal); 
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleCRM - Funil de Vendas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Pipeline',
            onPressed: _loadDealsComTratamentoDeErro, // Atualiza com tratamento de erro
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
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PipelineColumn(
                      title: 'Potencial',
                      stage: DealStage.potential,
                      deals: _controller.deals.where((d) => d.stage == DealStage.potential).toList(),
                      headerColor: Colors.blueAccent,
                      onStageChanged: _handleUpdateStage, // Usa o tratamento de erro
                      onDelete: _handleDeleteDeal, // Usa o tratamento de erro
                    ),
                    PipelineColumn(
                      title: 'Em Negociação',
                      stage: DealStage.inNegotiation,
                      deals: _controller.deals.where((d) => d.stage == DealStage.inNegotiation).toList(),
                      headerColor: Colors.orangeAccent,
                      onStageChanged: _handleUpdateStage,
                      onDelete: _handleDeleteDeal,
                    ),
                    PipelineColumn(
                      title: 'Proposta Enviada',
                      stage: DealStage.proposalSent,
                      deals: _controller.deals.where((d) => d.stage == DealStage.proposalSent).toList(),
                      headerColor: Colors.purpleAccent,
                      onStageChanged: _handleUpdateStage,
                      onDelete: _handleDeleteDeal,
                    ),
                    PipelineColumn(
                      title: 'Cliente Ativo',
                      stage: DealStage.activeClient,
                      deals: _controller.deals.where((d) => d.stage == DealStage.activeClient).toList(),
                      headerColor: Colors.green,
                      onStageChanged: _handleUpdateStage,
                      onDelete: _handleDeleteDeal,
                    ),
                    PipelineColumn(
                      title: 'Perdido',
                      stage: DealStage.lost,
                      deals: _controller.deals.where((d) => d.stage == DealStage.lost).toList(),
                      headerColor: Colors.redAccent,
                      onStageChanged: _handleUpdateStage,
                      onDelete: _handleDeleteDeal,
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDealDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Oportunidade'),
      ),
    );
  }
}