// lib/modules/pipeline/components/pipeline_column.dart
import 'package:flutter/material.dart';
import '../models/deal_entity.dart';
import 'deal_card.dart';

class PipelineColumn extends StatelessWidget {
  final String title;
  final DealStage stage;
  final List<DealEntity> deals;
  final Color headerColor;
  final Function(String, DealStage) onStageChanged;
  final Function(String) onDelete; // Novo callback para exclusão

  const PipelineColumn({
    super.key,
    required this.title,
    required this.stage,
    required this.deals,
    required this.headerColor,
    required this.onStageChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240, // Largura reduzida para acomodar melhor na tela
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Cabeçalho da Coluna
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white,
                  child: Text(
                    '${deals.length}',
                    style: TextStyle(fontSize: 11, color: headerColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Lista de Cards da Coluna
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(6),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                return DealCard(
                  deal: deal,
                  onStageChanged: (newStage) => onStageChanged(deal.id, newStage),
                  onDelete: (dealId) => onDelete(dealId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}