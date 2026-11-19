// lib/home_page.dart
import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'models/user_profile.dart';
import 'modules/pipeline/presentation/pipeline_page.dart';
import 'modules/customers/presentation/customer_list_page.dart';
import 'modules/billing/presentation/billing_page.dart';
import 'modules/cash_flow/presentation/cash_flow_page.dart';
import 'features/follow_up/views/follow_up_view.dart';
import 'screens/trial_and_paywall_screen.dart';
import 'services/subscription_service.dart';
import 'widgets/niche_scope.dart';

class HomePage extends StatefulWidget {
  final UserProfile? profile;
  final VoidCallback? onRefreshProfile;
  final SubscriptionService? subscriptionService;

  const HomePage({
    super.key,
    this.profile,
    this.onRefreshProfile,
    this.subscriptionService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Lista de páginas correspondentes às abas inferiores (Sprints 1 a 7 integradas)
  final List<Widget> _pages = const [
    PipelinePage(),
    CustomerListPage(),
    BillingPage(),
    CashFlowPage(),
    FollowUpView(),
  ];

  void _openSubscriptionScreen() {
    final profile = widget.profile;
    if (profile == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => TrialAndPaywallScreen(
          profile: profile,
          subscriptionService: widget.subscriptionService,
          onAccessGranted: () {
            if (Navigator.of(routeContext).canPop()) {
              Navigator.of(routeContext).pop();
            }
            widget.onRefreshProfile?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final nicheConfig = profile?.nicheConfig ?? NicheScope.configOf(context);
    final showTrialBanner = profile != null &&
        !profile.isSubscribed &&
        profile.remainingTrialDays > 0;

    return Scaffold(
      // O IndexedStack mantém o estado das páginas vivas enquanto você navega
      body: Column(
        children: [
          if (showTrialBanner)
            Material(
              color: nicheConfig.primaryDarkColor,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.surface,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Período gratuito ativo: restam ${profile.remainingTrialDays} dias',
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        key: const ValueKey('btn-trial-banner-subscribe'),
                        onPressed: _openSubscriptionScreen,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.surface,
                          backgroundColor: nicheConfig.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Assinar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: nicheConfig.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: nicheConfig.pipelineTabLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: nicheConfig.customersTabLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: nicheConfig.billingTabLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: nicheConfig.cashFlowTabLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.rate_review),
            label: nicheConfig.followUpTabLabel,
          ),
        ],
      ),
    );
  }
}