// lib/core/widgets/tutorial_help_action.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Row(
        children: [
          Icon(Icons.ondemand_video, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ajuda — Imersão SimpleCRM',
              style: TextStyle(
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
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: AppColors.primaryDark,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Vídeo Tutorial de Imersão',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aprenda passo a passo como gerenciar seus clientes, movimentar oportunidades no Funil de Vendas (Kanban), emitir cobranças no Faturamento, controlar o Fluxo de Caixa e registrar o Pós-Venda.',
                      style: TextStyle(
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
                onPressed: () => launchTutorialVideo(
                  context,
                  urlLauncher: urlLauncher,
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text(
                  'Assistir Vídeo Tutorial - Imersão SimpleCRM',
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
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                        color: AppColors.primary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.ondemand_video,
                color: AppColors.primaryDark,
                size: 20,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Novo por aqui? Conheça o passo a passo completo do sistema.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            key: const ValueKey('btn-banner-watch-tutorial'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
            label: const Text(
              'Assistir Vídeo Tutorial - Imersão SimpleCRM',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
