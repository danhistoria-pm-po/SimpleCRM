// lib/modules/pipeline/components/deal_card.dart
import 'package:flutter/material.dart';
import '../models/deal_entity.dart';

class DealCard extends StatelessWidget {
  final DealEntity deal;
  final Function(DealStage) onStageChanged;

  const DealCard({
    super.key,
    required this.deal,
    required this.onStageChanged,
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
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${deal.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: PopupMenuButton<DealStage>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    tooltip: 'Mover Estágio',
                    onSelected: onStageChanged,
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