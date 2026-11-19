// lib/widgets/access_gate.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../home_page.dart';
import '../models/user_profile.dart';
import '../screens/trial_and_paywall_screen.dart';
import '../services/subscription_service.dart';

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

    setState(() {
      _profile = fetched ??
          UserProfile.fallback(id: widget.userId, email: widget.userEmail);
      _isLoading = false;
    });
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

    if (profile.hasActiveAccess) {
      return HomePage(
        key: ValueKey(widget.userId),
        profile: profile,
        onRefreshProfile: _loadProfile,
        subscriptionService: _subscriptionService,
      );
    }

    return TrialAndPaywallScreen(
      profile: profile,
      subscriptionService: _subscriptionService,
      onAccessGranted: _loadProfile,
    );
  }
}
