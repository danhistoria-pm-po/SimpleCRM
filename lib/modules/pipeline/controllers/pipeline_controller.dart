// lib/modules/pipeline/controllers/pipeline_controller.dart
import 'package:flutter/material.dart';
import '../models/deal_entity.dart';

class PipelineController extends ChangeNotifier {
  final List<DealEntity> _deals = [
    DealEntity(
      id: '1',
      customerId: 'c1',
      customerName: 'Empresa Alpha Ltda',
      title: 'Implantação do Sistema',
      value: 4500.00,
      stage: DealStage.potential,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DealEntity(
      id: '2',
      customerId: 'c2',
      customerName: 'Comércio Beta',
      title: 'Renovação de Licença',
      value: 1200.00,
      stage: DealStage.inNegotiation,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DealEntity(
      id: '3',
      customerId: 'c3',
      customerName: 'Supermercado Delta',
      title: 'Módulo Fiscal Avançado',
      value: 3200.00,
      stage: DealStage.proposalSent,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    DealEntity(
      id: '4',
      customerId: 'c4',
      customerName: 'Distribuidora Gama',
      title: 'Pacote Enterprise',
      value: 12500.00,
      stage: DealStage.activeClient,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    DealEntity(
      id: '5',
      customerId: 'c5',
      customerName: 'Loja Omega',
      title: 'Consultoria Básica',
      value: 800.00,
      stage: DealStage.lost,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  String _searchQuery = '';
  DealStage? _filterStage;

  String get searchQuery => _searchQuery;
  DealStage? get filterStage => _filterStage;

  List<DealEntity> getDealsByStage(DealStage stage) {
    return _deals.where((deal) {
      final matchesStage = deal.stage == stage;
      final matchesGlobalStageFilter = _filterStage == null || deal.stage == _filterStage;

      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          deal.customerName.toLowerCase().contains(query) ||
          deal.title.toLowerCase().contains(query);

      return matchesStage && matchesGlobalStageFilter && matchesSearch;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStage(DealStage? stage) {
    _filterStage = stage;
    notifyListeners();
  }

  void addDeal(DealEntity deal) {
    _deals.add(deal);
    notifyListeners();
  }

  void updateDealStage(String dealId, DealStage newStage) {
    final index = _deals.indexWhere((d) => d.id == dealId);
    if (index != -1) {
      _deals[index] = _deals[index].copyWith(stage: newStage);
      notifyListeners();
    }
  }

  void deleteDeal(String dealId) {
    _deals.removeWhere((d) => d.id == dealId);
    notifyListeners();
  }
}