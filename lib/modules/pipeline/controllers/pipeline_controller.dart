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

    // Filtro por texto (título ou nome do cliente)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((deal) =>
          deal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          deal.customerName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Filtro por estágio selecionado
    if (_selectedStageFilter != null) {
      filtered = filtered.where((deal) => deal.stage == _selectedStageFilter).toList();
    }

    return filtered;
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  DealStage? get selectedStageFilter => _selectedStageFilter;

  // Carregar oportunidades do Supabase
  Future<void> loadDeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _deals = await _repository.fetchDeals();
    } catch (e) {
      debugPrint('Erro ao carregar do Supabase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar nova oportunidade direto no Supabase
  Future<void> addDeal(DealEntity deal) async {
    try {
      await _repository.createDeal(deal);
      await loadDeals(); // Recarrega a lista atualizada da nuvem
    } catch (e) {
      debugPrint('Erro ao criar oportunidade: $e');
    }
  }

  // Mover o estágio de uma oportunidade no Supabase
  Future<void> updateDealStage(String id, DealStage newStage) async {
    try {
      await _repository.updateDealStage(id, newStage);
      await loadDeals(); // Recarrega a lista atualizada
    } catch (e) {
      debugPrint('Erro ao atualizar estágio: $e');
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