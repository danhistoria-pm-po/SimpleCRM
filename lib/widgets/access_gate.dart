// lib/widgets/access_gate.dart
import 'package:flutter/material.dart';
import '../config/niche_config.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/follow_up/controllers/follow_up_controller.dart';
import '../home_page.dart';
import '../models/user_profile.dart';
import '../modules/billing/controllers/billing_controller.dart';
import '../modules/cash_flow/controllers/cash_flow_controller.dart';
import '../modules/customers/presentation/customer_controller.dart';
import '../screens/trial_and_paywall_screen.dart';
import '../services/subscription_service.dart';
import 'niche_scope.dart';

class AccessGate extends StatefulWidget {
  final String userId;
  final String? userEmail;
  final SubscriptionService? subscriptionService;

  const AccessGate({
    super.key,
    required this.userId,
    this.userEmail,
    this.subscriptionService,
  });

  @override
  State<AccessGate> createState() => _AccessGateState();
}

class _AccessGateState extends State<AccessGate> {
  late final SubscriptionService _subscriptionService;
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subscriptionService = widget.subscriptionService ?? SubscriptionService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final fetched = await _subscriptionService.fetchCurrentProfile();
    if (!mounted) return;

    final resolved = fetched ??
        UserProfile.fallback(id: widget.userId, email: widget.userEmail);
    ActiveNicheContext.set(resolved.niche);

    setState(() {
      _profile = resolved;
      _isLoading = false;
    });
  }

  void _reloadSharedModuleControllers() {
    CustomerController().reset();
    BillingController().reset();
    CashFlowController().reset();
    FollowUpController().reset();

    CustomerController().loadCustomers();
    BillingController().loadInvoices();
    CashFlowController().loadEntries();
    FollowUpController().loadFollowUps();
  }

  Future<void> _handleSwitchNiche(PrismaNiche newNiche) async {
    final current = _profile ??
        UserProfile.fallback(id: widget.userId, email: widget.userEmail);
    final newConfig = NicheConfig.fromNiche(newNiche);

    // Atualiza o nicho ativo e recarrega todos os módulos sem vazar dados do nicho anterior
    ActiveNicheContext.set(newConfig.key);
    setState(() {
      _profile = current.copyWith(
        niche: newConfig.key,
        planTier: newConfig.planTier,
      );
    });
    _reloadSharedModuleControllers();

    try {
      await _subscriptionService.updateNiche(newConfig.key);
    } catch (e) {
      if (!mounted) return;
      ActiveNicheContext.set(current.niche);
      setState(() {
        _profile = current;
      });
      _reloadSharedModuleControllers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o módulo selecionado: ${e.toString().replaceAll("Exception: ", "")}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Verificando acesso...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile ??
        UserProfile.fallback(id: widget.userId, email: widget.userEmail);
    final nicheConfig = profile.nicheConfig;

    final Widget screen = profile.hasActiveAccess
        ? HomePage(
            key: ValueKey(widget.userId),
            profile: profile,
            onRefreshProfile: _loadProfile,
            subscriptionService: _subscriptionService,
          )
        : TrialAndPaywallScreen(
            profile: profile,
            subscriptionService: _subscriptionService,
            onAccessGranted: _loadProfile,
          );

    return NicheScope(
      config: nicheConfig,
      onSwitchNiche: _handleSwitchNiche,
      child: Theme(
        data: AppTheme.forNiche(nicheConfig),
        child: screen,
      ),
    );
  }
}
