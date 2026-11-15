import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  final AuthController? authController;

  const RegisterPage({super.key, this.authController});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _authController;
  late final bool _ownsAuthController;

  bool _obscurePassword = true;
  bool _acceptedLgpdTerms = false;

  @override
  void initState() {
    super.initState();
    _ownsAuthController = widget.authController == null;
    _authController = widget.authController ?? AuthController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    if (_ownsAuthController) {
      _authController.dispose();
    }
    super.dispose();
  }

  void _showTermsAndPrivacyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Termos de Uso e Privacidade (LGPD)'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Em conformidade com a Lei Geral de Proteção de Dados Pessoais (Lei nº 13.709/2018 - LGPD), informamos como seus dados são tratados no SimpleCRM:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Finalidade: Os dados cadastrados (e-mail, clientes, oportunidades, faturas, fluxo de caixa e pós-venda) são utilizados exclusivamente para a operação da sua conta no CRM.\n\n'
                  '2. Isolamento e Segurança: Seus registros são isolados por autenticação e políticas de segurança no banco de dados (Row Level Security), impedindo o acesso por terceiros.\n\n'
                  '3. Direitos do Titular: Você pode visualizar, corrigir ou excluir seus registros a qualquer momento diretamente no aplicativo.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _acceptedLgpdTerms = true;
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.pop(dialogContext);
            },
            child: const Text('Li e Aceito'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptedLgpdTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Você deve aceitar os Termos de Uso e a Política de Privacidade (LGPD) para criar a conta.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      // CORRIGIDO: Removemos o .trim() da senha para não alterar o que o usuário digitou
      final success = await _authController.register(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Faça o seu login.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Voltar à tela de login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authController.errorMessage ?? 'Erro ao criar conta'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Criar Conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comece a gerenciar suas vendas hoje mesmo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // E-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Insira um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: AppColors.surface,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Consentimento LGPD e Termos de Uso
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _acceptedLgpdTerms,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _acceptedLgpdTerms = value ?? false;
                            });
                            if (_acceptedLgpdTerms) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            }
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Li e concordo com os Termos de Uso e Política de Privacidade (LGPD).',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 28),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: AppColors.primary,
                                  ),
                                  onPressed: _showTermsAndPrivacyDialog,
                                  child: const Text(
                                    'Ler Termos e Política (LGPD)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Botão Cadastrar
                    AnimatedBuilder(
                      animation: _authController,
                      builder: (context, child) {
                        return ElevatedButton(
                          onPressed: _authController.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            elevation: 0,
                          ),
                          child: _authController.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.surface,
                                  ),
                                )
                              : const Text(
                                  'Cadastrar Conta',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}