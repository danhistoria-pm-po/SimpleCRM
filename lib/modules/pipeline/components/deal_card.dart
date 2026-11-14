// lib/modules/pipeline/components/deal_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../models/deal_entity.dart';

class DealCard extends StatelessWidget {
  final DealEntity deal;
  final Function(DealStage) onStageChanged;
  final Function(String) onDelete;

  const DealCard({
    super.key,
    required this.deal,
    required this.onStageChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deal.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              deal.customerName,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrency(deal.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: PopupMenuButton<Object>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    tooltip: 'Opções da Oportunidade',
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete(deal.id);
                      } else if (value is DealStage) {
                        onStageChanged(value);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: DealStage.potential,
                        child: Text('Potencial', style: TextStyle(fontSize: 12)),
                      ),
                      const PopupMenuItem(
                        value: DealStage.inNegotiation,
                        child: Text('Em Negociação', style: TextStyle(fontSize: 12)),
                      ),
                      const PopupMenuItem(
                        value: DealStage.proposalSent,
                        child: Text('Proposta Enviada', style: TextStyle(fontSize: 12)),
                      ),
                      const PopupMenuItem(
                        value: DealStage.activeClient,
                        child: Text('Cliente Ativo', style: TextStyle(fontSize: 12)),
                      ),
                      const PopupMenuItem(
                        value: DealStage.lost,
                        child: Text('Perdido', style: TextStyle(fontSize: 12)),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: AppColors.danger),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Excluir Oportunidade',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}