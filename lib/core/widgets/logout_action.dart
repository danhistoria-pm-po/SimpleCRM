// lib/core/widgets/logout_action.dart
import 'package:flutter/material.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../theme/app_colors.dart';

class LogoutAction extends StatefulWidget {
  final AuthController? authController;

  const LogoutAction({super.key, this.authController});

  @override
  State<LogoutAction> createState() => _LogoutActionState();
}

class _LogoutActionState extends State<LogoutAction> {
  AuthController? _internalController;

  AuthController get _authController =>
      widget.authController ?? (_internalController ??= AuthController());

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  Future<void> _confirmAndLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Sair da Conta'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const Text('Deseja sair da conta?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.surface,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authController.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Sair',
      onPressed: _confirmAndLogout,
    );
  }
}
