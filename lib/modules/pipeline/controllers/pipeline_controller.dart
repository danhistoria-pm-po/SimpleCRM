// lib/modules/pipeline/controllers/pipeline_controller.dart
import 'package:flutter/foundation.dart';
import '../models/deal_entity.dart';
import '../repositories/pipeline_repository.dart';

class PipelineController extends ChangeNotifier {
  final PipelineRepository _repository;

  PipelineController({PipelineRepository? repository})
      : _repository = repository ?? PipelineRepository();

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
      return await loadDeals(silent: true);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Erro ao criar oportunidade: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // Atualização otimista de estágio: não aciona isLoading e reverte em caso de erro
  Future<bool> updateDealStage(String id, DealStage newStage) async {
    final previousDeals = List<DealEntity>.from(_deals);
    final index = _deals.indexWhere((d) => d.id == id);

    if (index != -1) {
      _deals[index] = _deals[index].copyWith(stage: newStage);
      _errorMessage = null;
      notifyListeners();
    }

    try {
      await _repository.updateDealStage(id, newStage);
      return true;
    } catch (e) {
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
