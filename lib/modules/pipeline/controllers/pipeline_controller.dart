// lib/modules/pipeline/controllers/pipeline_controller.dart
import 'package:flutter/foundation.dart';
import '../../../features/follow_up/controllers/follow_up_controller.dart';
import '../../../features/follow_up/models/follow_up_model.dart';
import '../../billing/controllers/billing_controller.dart';
import '../../billing/models/invoice_entity.dart';
import '../../cash_flow/controllers/cash_flow_controller.dart';
import '../../cash_flow/models/cash_flow_entry_entity.dart';
import '../models/deal_entity.dart';
import '../repositories/pipeline_repository.dart';

class PipelineController extends ChangeNotifier {
  final PipelineRepository _repository;
  final BillingController? _billingController;
  final CashFlowController? _cashFlowController;
  final FollowUpController? _followUpController;

  PipelineController({
    PipelineRepository? repository,
    BillingController? billingController,
    CashFlowController? cashFlowController,
    FollowUpController? followUpController,
  })  : _repository = repository ?? PipelineRepository(),
        _billingController = billingController ??
            (repository == null ? BillingController() : null),
        _cashFlowController = cashFlowController ??
            (repository == null ? CashFlowController() : null),
        _followUpController = followUpController ??
            (repository == null ? FollowUpController() : null);

  List<DealEntity> _deals = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  String _searchQuery = '';
  DealStage? _selectedStageFilter;

  List<DealEntity> get deals {
    var filtered = _deals;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((deal) =>
              deal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              deal.customerName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedStageFilter != null) {
      filtered = filtered
          .where((deal) => deal.stage == _selectedStageFilter)
          .toList();
    }

    return List.unmodifiable(filtered);
  }

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  DealStage? get selectedStageFilter => _selectedStageFilter;

  Future<bool> loadDeals({bool silent = false}) async {
    if (!silent && _deals.isEmpty) {
      _isLoading = true;
    } else {
      _isRefreshing = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      _deals = await _repository.fetchDeals();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Erro ao carregar do Supabase: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> addDeal(DealEntity deal) async {
    try {
      _errorMessage = null;
      await _repository.createDeal(deal);
      if (deal.stage == DealStage.activeClient) {
        await convertDealToActiveClient(deal);
      }
      return await loadDeals(silent: true);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Erro ao criar oportunidade: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  bool _isValidUuid(String value) => _uuidRegex.hasMatch(value.trim());

  // Executa de forma sequencial as ações automáticas ao converter uma oportunidade em Cliente Ativo:
  // 1. Emite fatura no módulo de Faturamento
  // 2. Registra entrada financeira no Fluxo de Caixa do dia
  // 3. Agenda acompanhamento de satisfação no Pós-Venda (+7 dias)
  Future<void> convertDealToActiveClient(DealEntity deal) async {
    final now = DateTime.now();
    final safeAmount = deal.value > 0 ? deal.value : 0.01;
    final invoiceTitle = deal.title.trim().isNotEmpty
        ? '${deal.customerName} - ${deal.title.trim()}'
        : deal.customerName;

    if (_billingController != null) {
      final invoiceOk = await _billingController.createInvoice(
        InvoiceEntity(
          id: '',
          customerId: deal.customerId,
          customerName: invoiceTitle,
          amount: safeAmount,
          dueDate: now,
          status: InvoiceStatus.paid,
          createdAt: now,
        ),
      );
      if (!invoiceOk) {
        throw Exception(
          _billingController.errorMessage ??
              'Falha ao gerar fatura automática da venda.',
        );
      }
    }

    if (_cashFlowController != null) {
      final cashFlowOk = await _cashFlowController.createEntry(
        CashFlowEntryEntity(
          id: '',
          description: 'Venda fechada: ${deal.title} (${deal.customerName})',
          amount: safeAmount,
          type: CashFlowType.income,
          date: now,
        ),
      );
      if (!cashFlowOk) {
        throw Exception(
          _cashFlowController.errorMessage ??
              'Falha ao registrar entrada automática no Caixa.',
        );
      }
    }

    if (_followUpController != null) {
      final followUpOk = await _followUpController.addFollowUp(
        FollowUpModel(
          id: '',
          customerId: deal.customerId,
          dealId: _isValidUuid(deal.id) ? deal.id : null,
          title: 'Pós-venda: ${deal.title} (${deal.customerName})',
          description:
              'Acompanhamento automático de satisfação referente à oportunidade "${deal.title}" com ${deal.customerName}.',
          scheduledDate: now.add(const Duration(days: 7)),
          status: 'pendente',
          isReceived: false,
          createdAt: now,
        ),
      );
      if (!followUpOk) {
        throw Exception(
          _followUpController.errorMessage ??
              'Falha ao agendar pós-venda automático.',
        );
      }
    }
  }

  // Atualização otimista de estágio: não aciona isLoading e reverte em caso de erro
  Future<bool> updateDealStage(String id, DealStage newStage) async {
    final previousDeals = List<DealEntity>.from(_deals);
    final index = _deals.indexWhere((d) => d.id == id);
    final DealEntity? originalDeal = index != -1 ? _deals[index] : null;

    if (index != -1) {
      _deals[index] = _deals[index].copyWith(stage: newStage);
      _errorMessage = null;
      notifyListeners();
    }

    try {
      await _repository.updateDealStage(id, newStage);

      if (originalDeal != null &&
          newStage == DealStage.activeClient &&
          originalDeal.stage != DealStage.activeClient) {
        await convertDealToActiveClient(
          originalDeal.copyWith(stage: newStage),
        );
      }

      return true;
    } catch (e) {
      if (originalDeal != null &&
          newStage == DealStage.activeClient &&
          originalDeal.stage != DealStage.activeClient) {
        try {
          await _repository.updateDealStage(id, originalDeal.stage);
        } catch (_) {}
      }
      _deals = previousDeals;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Erro ao atualizar estágio: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // Exclusão otimista no Kanban com reversão em caso de falha
  Future<bool> deleteDeal(String id) async {
    final previousDeals = List<DealEntity>.from(_deals);
    _deals.removeWhere((deal) => deal.id == id);
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteDeal(id);
      return true;
    } catch (e) {
      _deals = previousDeals;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Erro ao deletar oportunidade: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStageFilter(DealStage? stage) {
    _selectedStageFilter = stage;
    notifyListeners();
  }
}
