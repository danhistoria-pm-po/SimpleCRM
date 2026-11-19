// lib/core/widgets/tutorial_help_action.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/niche_scope.dart';
import '../theme/app_colors.dart';
import '../utils/url_opener.dart';

const String kTutorialVideoUrl =
    'https://drive.google.com/file/d/1cZTOqHp8ep5uqpEN_34VWIOzUbxrZfkg/view?usp=sharing';

Future<void> launchTutorialVideo(
  BuildContext context, {
  Future<bool> Function(String url)? urlLauncher,
}) async {
  final launcher = urlLauncher ?? openExternalUrl;
  final opened = await launcher(kTutorialVideoUrl);
  if (!opened && context.mounted) {
    await Clipboard.setData(const ClipboardData(text: kTutorialVideoUrl));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Link do vídeo tutorial copiado para a área de transferência.',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

Future<void> showTutorialVideoModal(
  BuildContext context, {
  Future<bool> Function(String url)? urlLauncher,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => TutorialVideoModal(urlLauncher: urlLauncher),
  );
}

class TutorialVideoModal extends StatelessWidget {
  final Future<bool> Function(String url)? urlLauncher;

  const TutorialVideoModal({super.key, this.urlLauncher});

  @override
  Widget build(BuildContext context) {
    final nicheConfig = NicheScope.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Icon(Icons.ondemand_video, color: nicheConfig.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ajuda — Imersão ${nicheConfig.shortName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: nicheConfig.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: nicheConfig.primaryColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: nicheConfig.primaryDarkColor,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Vídeo Tutorial de Imersão — ${nicheConfig.shortName}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: nicheConfig.primaryDarkColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aprenda passo a passo como gerenciar ${nicheConfig.customersTabLabel}, movimentar ${nicheConfig.pipelineEntityPlural} no Kanban, emitir ${nicheConfig.billingTabLabel}, controlar o ${nicheConfig.cashFlowTabLabel} e acompanhar ${nicheConfig.followUpTabLabel}.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                key: const ValueKey('btn-modal-watch-tutorial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: nicheConfig.primaryColor,
                  foregroundColor: AppColors.surface,
                ),
                onPressed: () => launchTutorialVideo(
                  context,
                  urlLauncher: urlLauncher,
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(
                  'Assistir Vídeo Tutorial - Imersão ${nicheConfig.shortName}',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: SelectableText(
                        kTutorialVideoUrl,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.copy,
                        size: 18,
                        color: nicheConfig.primaryColor,
                      ),
                      tooltip: 'Copiar link do vídeo',
                      onPressed: () async {
                        await Clipboard.setData(
                          const ClipboardData(text: kTutorialVideoUrl),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copiado com sucesso!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

class TutorialHelpAction extends StatelessWidget {
  final Future<bool> Function(String url)? urlLauncher;

  const TutorialHelpAction({super.key, this.urlLauncher});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: 'Ajuda e Vídeo Tutorial',
      onPressed: () => showTutorialVideoModal(
        context,
        urlLauncher: urlLauncher,
      ),
    );
  }
}

class TutorialQuickAccessBanner extends StatelessWidget {
  final Future<bool> Function(String url)? urlLauncher;

  const TutorialQuickAccessBanner({super.key, this.urlLauncher});

  @override
  Widget build(BuildContext context) {
    final nicheConfig = NicheScope.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: nicheConfig.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: nicheConfig.primaryColor.withValues(alpha: 0.30),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.ondemand_video,
                color: nicheConfig.primaryDarkColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Novo por aqui? Conheça o passo a passo completo do sistema.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: nicheConfig.primaryDarkColor,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            key: const ValueKey('btn-banner-watch-tutorial'),
            style: ElevatedButton.styleFrom(
              backgroundColor: nicheConfig.primaryColor,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {
              final launcher = urlLauncher ?? openExternalUrl;
              launcher(kTutorialVideoUrl);
              showTutorialVideoModal(
                context,
                urlLauncher: urlLauncher,
              );
            },
            icon: const Icon(Icons.play_circle_outline, size: 18),
            label: Text(
              'Assistir Vídeo Tutorial - Imersão ${nicheConfig.shortName}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
