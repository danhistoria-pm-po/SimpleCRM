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

  @override
  void initState() {
    super.initState();
    _controller.loadDeals(); // Carrega os dados do Supabase ao iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleCRM - Funil de Vendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadDeals(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Barra de Pesquisa e Filtros
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => _controller.setSearchQuery(value),
                        decoration: const InputDecoration(
                          hintText: 'Pesquisar por título ou cliente...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<DealStage?>(
                      value: _controller.selectedStageFilter,
                      hint: const Text('Filtrar Etapa'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas as Etapas'),
                        ),
                        ...DealStage.values.map((stage) {
                          return DropdownMenuItem(
                            value: stage,
                            child: Text(_getStageLabel(stage)),
                          );
                        }),
                      ],
                      onChanged: (stage) => _controller.setStageFilter(stage),
                    ),
                  ],
                ),
              ),

              // Visualização Kanban das Colunas do Funil
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PipelineColumn(
                        title: 'Potencial',
                        stage: DealStage.potential,
                        deals: _controller.deals.where((d) => d.stage == DealStage.potential).toList(),
                        headerColor: Colors.blueAccent,
                        onStageChanged: (id, newStage) => _controller.updateDealStage(id, newStage),
                      ),
                      PipelineColumn(
                        title: 'Em Negociação',
                        stage: DealStage.inNegotiation,
                        deals: _controller.deals.where((d) => d.stage == DealStage.inNegotiation).toList(),
                        headerColor: Colors.orangeAccent,
                        onStageChanged: (id, newStage) => _controller.updateDealStage(id, newStage),
                      ),
                      PipelineColumn(
                        title: 'Proposta Enviada',
                        stage: DealStage.proposalSent,
                        deals: _controller.deals.where((d) => d.stage == DealStage.proposalSent).toList(),
                        headerColor: Colors.purpleAccent,
                        onStageChanged: (id, newStage) => _controller.updateDealStage(id, newStage),
                      ),
                      PipelineColumn(
                        title: 'Cliente Ativo',
                        stage: DealStage.activeClient,
                        deals: _controller.deals.where((d) => d.stage == DealStage.activeClient).toList(),
                        headerColor: Colors.green,
                        onStageChanged: (id, newStage) => _controller.updateDealStage(id, newStage),
                      ),
                      PipelineColumn(
                        title: 'Perdido',
                        stage: DealStage.lost,
                        deals: _controller.deals.where((d) => d.stage == DealStage.lost).toList(),
                        headerColor: Colors.redAccent,
                        onStageChanged: (id, newStage) => _controller.updateDealStage(id, newStage),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => DealFormModal(
              onSave: (newDeal) async {
                await _controller.addDeal(newDeal);
              },
            ),
          );
        },
        label: const Text('Nova Oportunidade'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  String _getStageLabel(DealStage stage) {
    switch (stage) {
      case DealStage.potential:
        return 'Potencial';
      case DealStage.inNegotiation:
        return 'Em Negociação';
      case DealStage.proposalSent:
        return 'Proposta Enviada';
      case DealStage.activeClient:
        return 'Cliente Ativo';
      case DealStage.lost:
        return 'Perdido';
    }
  }
}