// lib/modules/pipeline/presentation/pipeline_page.dart
import 'package:flutter/material.dart';
import '../controllers/pipeline_controller.dart';
import '../models/deal_entity.dart';
import '../components/pipeline_column.dart';
import '../components/deal_form_modal.dart';

class PipelinePage extends StatefulWidget {
  const PipelinePage({super.key});

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage> {
  final PipelineController _controller = PipelineController();

  void _openNewDealModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DealFormModal(
        onSave: (newDeal) {
          _controller.addDeal(newDeal);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funil de Vendas (Pipeline)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova Oportunidade',
            onPressed: () => _openNewDealModal(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              // 🔍 Barra de Filtros Avançados
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: _controller.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Buscar por cliente ou título...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<DealStage?>(
                        value: _controller.filterStage,
                        decoration: InputDecoration(
                          labelText: 'Filtrar Estágio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: DealStage.potential, child: Text('Potencial')),
                          DropdownMenuItem(value: DealStage.inNegotiation, child: Text('Em Negociação')),
                          DropdownMenuItem(value: DealStage.proposalSent, child: Text('Proposta Enviada')),
                          DropdownMenuItem(value: DealStage.activeClient, child: Text('Cliente Ativo')),
                          DropdownMenuItem(value: DealStage.lost, child: Text('Perdido')),
                        ],
                        onChanged: _controller.setFilterStage,
                      ),
                    ),
                  ],
                ),
              ),

              // 📊 Painel Kanban (5 Colunas de Estágios)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PipelineColumn(
                        title: 'Potencial',
                        stage: DealStage.potential,
                        deals: _controller.getDealsByStage(DealStage.potential),
                        headerColor: Colors.blueAccent,
                        onStageChanged: _controller.updateDealStage,
                      ),
                      PipelineColumn(
                        title: 'Em Negociação',
                        stage: DealStage.inNegotiation,
                        deals: _controller.getDealsByStage(DealStage.inNegotiation),
                        headerColor: Colors.orangeAccent,
                        onStageChanged: _controller.updateDealStage,
                      ),
                      PipelineColumn(
                        title: 'Proposta Enviada',
                        stage: DealStage.proposalSent,
                        deals: _controller.getDealsByStage(DealStage.proposalSent),
                        headerColor: Colors.purpleAccent,
                        onStageChanged: _controller.updateDealStage,
                      ),
                      PipelineColumn(
                        title: 'Cliente Ativo',
                        stage: DealStage.activeClient,
                        deals: _controller.getDealsByStage(DealStage.activeClient),
                        headerColor: Colors.green,
                        onStageChanged: _controller.updateDealStage,
                      ),
                      PipelineColumn(
                        title: 'Perdido',
                        stage: DealStage.lost,
                        deals: _controller.getDealsByStage(DealStage.lost),
                        headerColor: Colors.redAccent,
                        onStageChanged: _controller.updateDealStage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}