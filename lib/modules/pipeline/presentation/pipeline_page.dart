// lib/modules/pipeline/presentation/pipeline_page.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/logout_action.dart';
import '../controllers/pipeline_controller.dart';
import '../models/deal_entity.dart';
import '../components/pipeline_column.dart';
import '../components/deal_form_modal.dart';
import '../../customers/presentation/customer_controller.dart';

class PipelinePage extends StatefulWidget {
  final PipelineController? controller;
  final CustomerController? customerController;

  const PipelinePage({
    super.key,
    this.controller,
    this.customerController,
  });

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage> {
  late final PipelineController _controller;
  late final CustomerController _customerController;
  late final bool _ownsController;
  final ScrollController _horizontalScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? PipelineController();
    _customerController = widget.customerController ?? CustomerController();
    _controller.addListener(_onControllerChanged);
    _customerController.ensureLoaded();
    _loadDealsComTratamentoDeErro();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _horizontalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDealsComTratamentoDeErro({bool silent = false}) async {
    final ok = await _controller.loadDeals(silent: silent);
    if (!ok && mounted && _controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar oportunidades: ${_controller.errorMessage}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleAddDeal(DealEntity deal) async {
    final ok = await _controller.addDeal(deal);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao criar oportunidade: ${_controller.errorMessage ?? "Erro desconhecido"}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleUpdateStage(String id, DealStage newStage) async {
    final ok = await _controller.updateDealStage(id, newStage);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao mover oportunidade: ${_controller.errorMessage ?? "Erro desconhecido"}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<bool> _confirmDeleteDeal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Deseja realmente excluir esta oportunidade do funil de vendas?',
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

  Future<void> _handleDeleteDeal(String id) async {
    final confirmed = await _confirmDeleteDeal();
    if (!confirmed || !mounted) return;
    final ok = await _controller.deleteDeal(id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao excluir oportunidade: ${_controller.errorMessage ?? "Erro desconhecido"}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showAddDealDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DealFormModal(
          customerController: _customerController,
          onSave: (deal) async {
            await _handleAddDeal(deal);
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleCRM - Funil de Vendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Pipeline',
            onPressed: () => _loadDealsComTratamentoDeErro(silent: true),
          ),
          const LogoutAction(),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_controller.errorMessage != null &&
                  _controller.deals.isEmpty &&
                  _controller.searchQuery.isEmpty &&
                  _controller.selectedStageFilter == null)
              ? Center(
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
                          onPressed: () => _loadDealsComTratamentoDeErro(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _controller.setSearchQuery,
                              decoration: InputDecoration(
                                hintText: 'Buscar por título ou cliente...',
                                prefixIcon: const Icon(Icons.search),
                                isDense: true,
                                suffixIcon: _controller.searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        tooltip: 'Limpar busca',
                                        onPressed: () {
                                          _searchController.clear();
                                          _controller.setSearchQuery('');
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<DealStage?>(
                                value: _controller.selectedStageFilter,
                                hint: const Text('Todas as etapas'),
                                items: [
                                  const DropdownMenuItem<DealStage?>(
                                    value: null,
                                    child: Text('Todas as etapas'),
                                  ),
                                  ...DealStage.values.map(
                                    (stage) => DropdownMenuItem<DealStage?>(
                                      value: stage,
                                      child: Text(_getStageLabel(stage)),
                                    ),
                                  ),
                                ],
                                onChanged: _controller.setStageFilter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PipelineColumn(
                                title: 'Potencial',
                                stage: DealStage.potential,
                                deals: _controller.deals
                                    .where((d) => d.stage == DealStage.potential)
                                    .toList(),
                                headerColor: AppColors.stagePotential,
                                onStageChanged: _handleUpdateStage,
                                onDelete: _handleDeleteDeal,
                              ),
                              PipelineColumn(
                                title: 'Em Negociação',
                                stage: DealStage.inNegotiation,
                                deals: _controller.deals
                                    .where((d) => d.stage == DealStage.inNegotiation)
                                    .toList(),
                                headerColor: AppColors.stageNegotiation,
                                onStageChanged: _handleUpdateStage,
                                onDelete: _handleDeleteDeal,
                              ),
                              PipelineColumn(
                                title: 'Proposta Enviada',
                                stage: DealStage.proposalSent,
                                deals: _controller.deals
                                    .where((d) => d.stage == DealStage.proposalSent)
                                    .toList(),
                                headerColor: AppColors.stageProposal,
                                onStageChanged: _handleUpdateStage,
                                onDelete: _handleDeleteDeal,
                              ),
                              PipelineColumn(
                                title: 'Cliente Ativo',
                                stage: DealStage.activeClient,
                                deals: _controller.deals
                                    .where((d) => d.stage == DealStage.activeClient)
                                    .toList(),
                                headerColor: AppColors.stageActive,
                                onStageChanged: _handleUpdateStage,
                                onDelete: _handleDeleteDeal,
                              ),
                              PipelineColumn(
                                title: 'Perdido',
                                stage: DealStage.lost,
                                deals: _controller.deals
                                    .where((d) => d.stage == DealStage.lost)
                                    .toList(),
                                headerColor: AppColors.stageLost,
                                onStageChanged: _handleUpdateStage,
                                onDelete: _handleDeleteDeal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDealDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova Oportunidade'),
      ),
    );
  }
}
