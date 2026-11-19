// lib/screens/trial_and_paywall_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/widgets/logout_action.dart';
import '../models/user_profile.dart';
import '../services/subscription_service.dart';

const String hotmartCheckoutUrlComercio =
    'https://pay.hotmart.com/SEU_LINK_COMERCIO_49';
const String hotmartCheckoutUrlEspecializado =
    'https://pay.hotmart.com/SEU_LINK_ESPECIALIZADO_97';

class _PrismaPalette {
  static const Color primary = Color(0xFF1D4ED8); // Prisma Blue 700
  static const Color primaryDark = Color(0xFF1E3A8A); // Prisma Blue 900
  static const Color primarySoft = Color(0xFFEFF6FF); // Prisma Blue 50
  static const Color primaryBorder = Color(0xFFBFDBFE); // Prisma Blue 200
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF15803D);
  static const Color danger = Color(0xFFB91C1C);
  static const Color dangerSoft = Color(0xFFFEF2F2);
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class TrialAndPaywallScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onAccessGranted;
  final SubscriptionService? subscriptionService;
  final Future<bool> Function(Uri uri)? urlLauncher;

  const TrialAndPaywallScreen({
    super.key,
    required this.profile,
    required this.onAccessGranted,
    this.subscriptionService,
    this.urlLauncher,
  });

  @override
  State<TrialAndPaywallScreen> createState() => _TrialAndPaywallScreenState();
}

class _TrialAndPaywallScreenState extends State<TrialAndPaywallScreen> {
  final TextEditingController _codeController = TextEditingController();
  late final SubscriptionService _subscriptionService;

  bool _isRedeeming = false;
  bool _isCheckingAccess = false;
  String? _promoError;

  @override
  void initState() {
    super.initState();
    _subscriptionService = widget.subscriptionService ?? SubscriptionService();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _isComercioPlan => widget.profile.isComercioPlan;

  String get _planPrice => _isComercioPlan ? 'R\$ 49,00/mês' : 'R\$ 97,00/mês';

  String get _planSubtitle => _isComercioPlan
      ? 'Oferta de Lançamento — Prisma Gestão | SimpleCRM'
      : 'Plano Profissional — Prisma Gestão';

  String get _checkoutUrl => _isComercioPlan
      ? hotmartCheckoutUrlComercio
      : hotmartCheckoutUrlEspecializado;

  Future<void> _handleRedeemPromoCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _promoError = 'Digite um código promocional para continuar.';
      });
      return;
    }

    setState(() {
      _isRedeeming = true;
      _promoError = null;
    });

    final result = await _subscriptionService.redeemPromoCode(code);

    if (!mounted) return;

    setState(() {
      _isRedeeming = false;
    });

    if (result['ok'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bem-vindo! Seus 30 dias gratuitos foram ativados com sucesso.',
          ),
          backgroundColor: _PrismaPalette.success,
        ),
      );
      widget.onAccessGranted();
    } else {
      final errorMsg = result['error']?.toString() ??
          'Código inválido, expirado ou já utilizado.';
      setState(() {
        _promoError = errorMsg;
      });
    }
  }

  Future<void> _handleOpenCheckout() async {
    final uri = Uri.parse(_checkoutUrl);
    final launched = widget.urlLauncher != null
        ? await widget.urlLauncher!(uri)
        : await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir o link de pagamento. Tente novamente.',
          ),
          backgroundColor: _PrismaPalette.danger,
        ),
      );
    }
  }

  Future<void> _handleVerifyAccess() async {
    setState(() {
      _isCheckingAccess = true;
    });

    final updatedProfile = await _subscriptionService.fetchCurrentProfile();

    if (!mounted) return;

    setState(() {
      _isCheckingAccess = false;
    });

    if (updatedProfile != null && updatedProfile.hasActiveAccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acesso confirmado! Redirecionando para o sistema...'),
          backgroundColor: _PrismaPalette.success,
        ),
      );
      widget.onAccessGranted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Confirmação de pagamento ainda pendente. Aguarde alguns instantes e tente novamente.',
          ),
          backgroundColor: _PrismaPalette.primaryDark,
        ),
      );
    }
  }

  Widget _buildPromoCard() {
    return Card(
      margin: EdgeInsets.zero,
      color: _PrismaPalette.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _PrismaPalette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.card_giftcard_rounded,
                  color: _PrismaPalette.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Possui um código de convite? (30 Dias Grátis)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _PrismaPalette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Informe seu código promocional abaixo para liberar 30 dias de acesso gratuito sem compromisso.',
              style: TextStyle(
                fontSize: 12.5,
                color: _PrismaPalette.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('promo-code-field'),
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [_UpperCaseTextFormatter()],
              enabled: !_isRedeeming,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Código promocional',
                hintText: 'Ex: PRISMA30',
                prefixIcon: const Icon(
                  Icons.confirmation_number_outlined,
                  color: _PrismaPalette.primary,
                  size: 20,
                ),
                filled: true,
                fillColor: _PrismaPalette.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _PrismaPalette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: _PrismaPalette.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            if (_promoError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _PrismaPalette.dangerSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _PrismaPalette.danger.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: _PrismaPalette.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _promoError!,
                        style: const TextStyle(
                          color: _PrismaPalette.danger,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              key: const ValueKey('btn-activate-trial'),
              onPressed: _isRedeeming ? null : _handleRedeemPromoCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: _PrismaPalette.primary,
                foregroundColor: _PrismaPalette.surface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isRedeeming
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _PrismaPalette.surface,
                      ),
                    )
                  : const Text(
                      'Ativar 30 Dias Grátis',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard() {
    return Card(
      margin: EdgeInsets.zero,
      color: _PrismaPalette.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: _PrismaPalette.primaryBorder,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: _PrismaPalette.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Assinar Plano (Acesso Imediato)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _PrismaPalette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _PrismaPalette.primarySoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _PrismaPalette.primaryBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _planPrice,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _PrismaPalette.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _planSubtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _PrismaPalette.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Inclui Funil de Vendas (Kanban), Gestão de Clientes, Faturamento, Fluxo de Caixa e Pós-Venda integrados com segurança em nuvem.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _PrismaPalette.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              key: const ValueKey('btn-subscribe-now'),
              onPressed: _handleOpenCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _PrismaPalette.primaryDark,
                foregroundColor: _PrismaPalette.surface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 17),
              label: const Text(
                'Assinar Agora',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('btn-verify-access'),
              onPressed: _isCheckingAccess ? null : _handleVerifyAccess,
              style: OutlinedButton.styleFrom(
                foregroundColor: _PrismaPalette.primary,
                side: const BorderSide(color: _PrismaPalette.primary),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _isCheckingAccess
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _PrismaPalette.primary,
                      ),
                    )
                  : const Icon(Icons.refresh, size: 17),
              label: const Text(
                'Já paguei / Verificar acesso',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _PrismaPalette.background,
      appBar: AppBar(
        backgroundColor: _PrismaPalette.primaryDark,
        foregroundColor: _PrismaPalette.surface,
        automaticallyImplyLeading: canPop,
        centerTitle: false,
        titleSpacing: canPop ? 0 : 16,
        title: const Text(
          'Prisma Gestão — Acesso e Assinatura',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: LogoutAction(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 16,
                  vertical: isWide ? 18 : 14,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 920 : 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Faixa compacta de identificação Prisma Gestão / SimpleCRM
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              _PrismaPalette.primaryDark,
                              _PrismaPalette.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  color: _PrismaPalette.surface,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Prisma Gestão | SimpleCRM',
                                  style: TextStyle(
                                    color: _PrismaPalette.surface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.profile.email != null &&
                                      widget.profile.email!.isNotEmpty
                                  ? 'Conta: ${widget.profile.email}'
                                  : 'Ative seu período gratuito ou assine para liberar o acesso.',
                              style: const TextStyle(
                                color: _PrismaPalette.primarySoft,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isWide ? 16 : 12),

                      // Cards lado a lado em telas >= 760px ou empilhados em telas estreitas
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPromoCard()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPlanCard()),
                          ],
                        )
                      else ...[
                        _buildPromoCard(),
                        const SizedBox(height: 12),
                        _buildPlanCard(),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
