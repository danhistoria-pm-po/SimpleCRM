// lib/widgets/niche_scope.dart
import 'package:flutter/material.dart';
import '../config/niche_config.dart';

class NicheScope extends InheritedWidget {
  final NicheConfig config;
  final Future<void> Function(PrismaNiche niche)? onSwitchNiche;

  const NicheScope({
    super.key,
    required this.config,
    this.onSwitchNiche,
    required super.child,
  });

  static NicheScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NicheScope>();
  }

  static NicheConfig configOf(BuildContext context) {
    return maybeOf(context)?.config ?? NicheConfig.simplecrm;
  }

  @override
  bool updateShouldNotify(NicheScope oldWidget) {
    return config.niche != oldWidget.config.niche;
  }
}

class NicheSwitcherAction extends StatelessWidget {
  const NicheSwitcherAction({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = NicheScope.maybeOf(context);
    if (scope == null || scope.onSwitchNiche == null) {
      return const SizedBox.shrink();
    }

    final current = scope.config;

    return PopupMenuButton<PrismaNiche>(
      key: const ValueKey('btn-niche-switcher'),
      tooltip: 'Trocar módulo Prisma Gestão',
      icon: const Icon(Icons.apps_rounded),
      onSelected: (selected) async {
        if (selected == current.niche) return;
        await scope.onSwitchNiche!(selected);
      },
      itemBuilder: (context) => NicheConfig.all.map((item) {
        final isSelected = item.niche == current.niche;
        return PopupMenuItem<PrismaNiche>(
          value: item.niche,
          child: Row(
            children: [
              Icon(item.icon, color: item.primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.shortName,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.monthlyPriceLabel,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check, color: item.primaryColor, size: 18),
            ],
          ),
        );
      }).toList(),
    );
  }
}
