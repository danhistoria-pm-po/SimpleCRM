// lib/modules/pipeline/controllers/pipeline_controller.dart
import 'package:flutter/foundation.dart';
import '../models/deal_entity.dart';
import '../repositories/pipeline_repository.dart';

class PipelineController extends ChangeNotifier {
  final PipelineRepository _repository = PipelineRepository();

  List<DealEntity> _deals = [];
  bool _isLoading = false;
  String _searchQuery = '';
  DealStage? _selectedStageFilter;

  List<DealEntity> get deals {
    var filtered = _deals;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((deal) =>
          deal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          deal.customerName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_selectedStageFilter != null) {
      filtered = filtered.where((deal) => deal.stage == _selectedStageFilter).toList();
    }

    return filtered;
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  DealStage? get selectedStageFilter => _selectedStageFilter;

  Future<void> loadDeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _deals = await _repository.fetchDeals();
    } catch (e) {
      debugPrint('Erro ao carregar do Supabase: $e');
      rethrow; // CORRIGIDO: Repassa o erro para a tela
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeal(DealEntity deal) async {
    try {
      await _repository.createDeal(deal);
      await loadDeals();
    } catch (e) {
      debugPrint('Erro ao criar oportunidade: $e');
      rethrow; // CORRIGIDO: Repassa o erro para a tela
    }
  }

  Future<void> updateDealStage(String id, DealStage newStage) async {
    try {
      await _repository.updateDealStage(id, newStage);
      await loadDeals();
    } catch (e) {
      debugPrint('Erro ao atualizar estágio: $e');
      rethrow; // CORRIGIDO: Repassa o erro para a tela
    }
  }

  // Método de exclusão independente direto no Kanban
  Future<void> deleteDeal(String id) async {
    try {
      await _repository.deleteDeal(id);
      _deals.removeWhere((deal) => deal.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar oportunidade: $e');
      rethrow; // CORRIGIDO: Repassa o erro para a tela
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