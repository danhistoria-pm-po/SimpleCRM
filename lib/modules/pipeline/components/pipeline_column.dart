// lib/modules/pipeline/components/pipeline_column.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/deal_entity.dart';
import 'deal_card.dart';

class PipelineColumn extends StatelessWidget {
  final String title;
  final DealStage stage;
  final List<DealEntity> deals;
  final Color headerColor;
  final Function(String, DealStage) onStageChanged;
  final Function(String) onDelete;

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
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Faixa superior de 4 px na cor da etapa
          Container(
            height: 4,
            width: double.infinity,
            color: headerColor,
          ),
          // Cabeçalho neutro da coluna (fundo surface, texto textPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${deals.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
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