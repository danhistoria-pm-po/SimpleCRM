# CodeBundle: lib
Generated: 2026-11-01T21:32:35.962Z
Root: c:\Jogos\SimpleCRM\lib
Files: 18

## How to apply changes
- Return changes as **unified diffs** per file whenever possible.
- Files are delimited with `<!-- FILE: ... -->` markers.

## Project tree
```
├─ home_page.dart
├─ main.dart
└─ modules
   ├─ auth
   │  ├─ controllers
   │  │  └─ auth_controller.dart
   │  ├─ data
   │  │  └─ auth_repository.dart
   │  └─ pages
   │     ├─ login_page.dart
   │     └─ register_page.dart
   ├─ customers
   │  ├─ domain
   │  │  └─ entities
   │  │     └─ customer_entity.dart
   │  ├─ presentation
   │  │  ├─ customer_controller.dart
   │  │  ├─ customer_form_modal.dart
   │  │  └─ customer_list_page.dart
   │  └─ repositories
   │     └─ customer_repository.dart
   └─ pipeline
      ├─ components
      │  ├─ deal_card.dart
      │  ├─ deal_form_modal.dart
      │  └─ pipeline_column.dart
      ├─ controllers
      │  └─ pipeline_controller.dart
      ├─ models
      │  └─ deal_entity.dart
      ├─ presentation
      │  └─ pipeline_page.dart
      └─ repositories
         └─ pipeline_repository.dart
```

## Files list

- `home_page.dart` (2172 bytes)
- `main.dart` (2646 bytes)
- `modules/auth/controllers/auth_controller.dart` (1544 bytes)
- `modules/auth/data/auth_repository.dart` (2440 bytes)
- `modules/auth/pages/login_page.dart` (8955 bytes)
- `modules/auth/pages/register_page.dart` (8283 bytes)
- `modules/customers/domain/entities/customer_entity.dart` (1306 bytes)
- `modules/customers/presentation/customer_controller.dart` (2623 bytes)
- `modules/customers/presentation/customer_form_modal.dart` (2665 bytes)
- `modules/customers/presentation/customer_list_page.dart` (4604 bytes)
- `modules/customers/repositories/customer_repository.dart` (2191 bytes)
- `modules/pipeline/components/deal_card.dart` (4159 bytes)
- `modules/pipeline/components/deal_form_modal.dart` (6718 bytes)
- `modules/pipeline/components/pipeline_column.dart` (2879 bytes)
- `modules/pipeline/controllers/pipeline_controller.dart` (2594 bytes)
- `modules/pipeline/models/deal_entity.dart` (1202 bytes)
- `modules/pipeline/presentation/pipeline_page.dart` (7025 bytes)
- `modules/pipeline/repositories/pipeline_repository.dart` (2620 bytes)

---
<!-- FILE: home_page.dart -->
## home_page.dart

```
// lib/home_page.dart
import 'package:flutter/material.dart';
import 'modules/pipeline/presentation/pipeline_page.dart';
import 'modules/customers/presentation/customer_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Lista de páginas correspondentes às abas inferiores
  final List<Widget> _pages = [
    const PipelinePage(),
    const CustomerListPage(),
    // Placeholders temporários para as abas que ainda serão construídas
    const Scaffold(body: Center(child: Text('Gestão de Faturamento & Notas Fiscais'))),
    const Scaffold(body: Center(child: Text('Fluxo de Caixa Simples'))),
    const Scaffold(body: Center(child: Text('Pós-Venda & Follow-up'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O IndexedStack mantém o estado das páginas vivas enquanto você navega
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Pipeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Faturamento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Caixa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review),
            label: 'Pós-Venda',
          ),
        ],
      ),
    );
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: main.dart -->
## main.dart

```
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'modules/auth/pages/login_page.dart';
import 'modules/customers/presentation/customer_controller.dart'; // Import necessário para o reset

Future<void> main() async {
  // Garante que os bindings do Flutter estão prontos antes de inicializar serviços externos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização oficial do Supabase
  await Supabase.initialize(
    url: 'https://cmvkanmyrhoxuprlpexh.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNtdmthbm15cmhveHVwcmxwZXhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI2MDQ4OTEsImV4cCI6MjEwODE4MDg5MX0.8kwmlvWv2fb3x51tDS3I77v2vR0DHjHgwl4caE9Icak',
  );

  runApp(const SimpleCRMApp());
}

class SimpleCRMApp extends StatelessWidget {
  const SimpleCRMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleCRM — Produtividade PME',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Azul corporativo
          primary: const Color(0xFF1E3A8A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const AuthCheckPage(),
    );
  }
}

/// Página de verificação de autenticação em tempo real
class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    // Escuta mudanças de autenticação (Login / Logout)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      // Se o usuário deslogar, limpamos a memória dos Singletons
      if (event == AuthChangeEvent.signedOut) {
        CustomerController().reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/auth/controllers/auth_controller.dart -->
## modules/auth/controllers/auth_controller.dart

```
import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authRepository.isAuthenticated;

  // Ação de Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false; // Falha
    }
  }

  // Ação de Registo
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signUp(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false; // Falha
    }
  }

  // Ação de Logout
  Future<void> logout() async {
    await _authRepository.signOut();
    notifyListeners();
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/auth/data/auth_repository.dart -->
## modules/auth/data/auth_repository.dart

```
// lib/modules/auth/data/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // ATENÇÃO: Removemos o .trim() da senha. 
      // O e-mail pode ser limpo, mas a senha tem que ser enviada exatamente como digitada.
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password, 
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(_translateError(e));
    } catch (e) {
      throw Exception('Erro inesperado ao fazer login: $e');
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(_translateError(e));
    } catch (e) {
      throw Exception('Erro inesperado ao criar conta: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao terminar sessão: $e');
    }
  }

  // NOVO: Tradutor de erros do Supabase para português claro
  String _translateError(AuthException e) {
    final message = e.message.toLowerCase();
    
    if (message.contains('invalid login credentials')) {
      return 'E-mail ou palavra-passe incorretos.';
    }
    if (message.contains('email not confirmed')) {
      return 'Por favor, confirme o seu e-mail antes de entrar.';
    }
    if (message.contains('user already registered')) {
      return 'Este e-mail já está registado. Tente fazer login.';
    }
    if (message.contains('password should be at least 6 characters')) {
      return 'A palavra-passe deve ter pelo menos 6 caracteres.';
    }
    if (message.contains('rate limit')) {
      return 'Muitas tentativas. Aguarde um momento e tente novamente.';
    }
    
    // Se for um erro que não mapeamos, devolve a mensagem original do Supabase
    return e.message; 
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/auth/pages/login_page.dart -->
## modules/auth/pages/login_page.dart

```
// lib/modules/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // CORRIGIDO: Mantemos o trim no e-mail (evita espaços extras), 
      // mas a senha vai EXATAMENTE como o usuário digitou.
      final success = await _authController.login(
        _emailController.text.trim(),
        _passwordController.text, 
      );

      if (!mounted) return;

      if (!success) {
        // Se falhar, mostra o erro traduzido pelo nosso AuthRepository
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authController.errorMessage ?? 'Erro desconhecido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Se der sucesso, NÃO fazemos nada. O AuthCheckPage (main.dart) 
      // vai detectar a mudança de estado e trocar para a HomePage automaticamente.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                      Icons.hub_rounded,
                      size: 64,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SimpleCRM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestão comercial simples e direta ao ponto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo de E-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
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

                    // Campo de Palavra-passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Palavra-passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: Colors.white,
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
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A palavra-passe deve ter pelo menos 6 carateres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botão de Entrar Reativo ao Estado de Loading
                    AnimatedBuilder(
                      animation: _authController,
                      builder: (context, child) {
                        return ElevatedButton(
                          onPressed: _authController.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: _authController.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Link para Registo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Não tem uma conta?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text('Registe-se'),
                        ),
                      ],
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

```
<!-- END_FILE -->

---
<!-- FILE: modules/auth/pages/register_page.dart -->
## modules/auth/pages/register_page.dart

```
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
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
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Voltar ao ecrã de login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authController.errorMessage ?? 'Erro ao criar conta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // CORRIGIDO: grey[550] não existe, o tom 50 deixa igual ao login
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
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
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Criar Conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comece a gerir as suas vendas hoje mesmo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
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

                    // Palavra-passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Palavra-passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: Colors.white,
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
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A palavra-passe deve ter pelo menos 6 carateres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botão Registar
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
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: _authController.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Registar Conta',
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

```
<!-- END_FILE -->

---
<!-- FILE: modules/customers/domain/entities/customer_entity.dart -->
## modules/customers/domain/entities/customer_entity.dart

```
// lib/modules/customers/domain/entities/customer_entity.dart

enum CustomerStatus {
  potential,
  prospect,
  negotiation,
  active,
  inactive,
  afterSales,
}

class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address; // Campo de endereço adicionado
  final CustomerStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.status = CustomerStatus.potential,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    CustomerStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/customers/presentation/customer_controller.dart -->
## modules/customers/presentation/customer_controller.dart

```
// lib/modules/customers/presentation/customer_controller.dart
import 'package:flutter/foundation.dart';
import '../domain/entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class CustomerController extends ChangeNotifier {
  // Padrão Singleton: Garante uma única instância partilhada em todo o app
  static final CustomerController _instance = CustomerController._internal();
  factory CustomerController() => _instance;
  
  CustomerController._internal() {
    loadCustomers(); // Carrega automaticamente os clientes do Supabase assim que o controller inicializa
  }

  final CustomerRepository _repository = CustomerRepository();

  List<Customer> _customers = [];
  List<Customer> get customers => List.unmodifiable(_customers);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Limpa a memória do app ao fazer logout
  void reset() {
    _customers = [];
    notifyListeners();
  }

  // Carrega os clientes do Supabase
  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _repository.getCustomers();
    } catch (e) {
      debugPrint('Erro no controller ao carregar clientes: $e');
      rethrow; // Repassa o erro para a tela avisar o usuário
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adiciona um cliente e persiste no Supabase
  Future<void> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
    CustomerStatus status = CustomerStatus.potential,
    String? notes,
  }) async {
    final now = DateTime.now();
    final newCustomer = Customer(
      id: '', // Gerado pelo Supabase
      name: name,
      phone: phone,
      email: email,
      address: address,
      status: status,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.addCustomer(newCustomer);
      await loadCustomers(); // Atualiza a lista unificada direto da base de dados
    } catch (e) {
      debugPrint('Erro ao adicionar cliente: $e');
      rethrow; // Repassa o erro para a tela avisar o usuário
    }
  }

  // Remove o cliente do Supabase
  Future<void> removeCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      _customers.removeWhere((customer) => customer.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao remover cliente: $e');
      rethrow; // Repassa o erro para a tela avisar o usuário
    }
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/customers/presentation/customer_form_modal.dart -->
## modules/customers/presentation/customer_form_modal.dart

```
// lib/modules/customers/presentation/customer_form_modal.dart

import 'package:flutter/material.dart';

class CustomerFormModal extends StatelessWidget {
  final Function({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) onSave;

  const CustomerFormModal({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    return AlertDialog(
      title: const Text('Novo Cliente'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome *'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefone / WhatsApp'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Observações'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              onSave(
                name: nameController.text,
                phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                email: emailController.text.isNotEmpty ? emailController.text : null,
                address: addressController.text.isNotEmpty ? addressController.text : null,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/customers/presentation/customer_list_page.dart -->
## modules/customers/presentation/customer_list_page.dart

```
// lib/modules/customers/presentation/customer_list_page.dart

import 'package:flutter/material.dart';
import 'customer_controller.dart';
import 'customer_form_modal.dart'; 
import '../../auth/controllers/auth_controller.dart'; // NOVO IMPORT

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final CustomerController _controller = CustomerController();
  final AuthController _authController = AuthController(); // NOVA INSTÂNCIA

  // ⚠️ O método dispose() foi REMOVIDO daqui para não destruir o Singleton.

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CustomerFormModal(
          onSave: ({required name, phone, email, address, notes}) async {
            try {
              // Tenta salvar no banco de dados
              await _controller.addCustomer(
                name: name,
                phone: phone,
                email: email,
                address: address,
                notes: notes,
              );
            } catch (e) {
              // Se o banco der erro, mostra a tarja vermelha na tela
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao salvar cliente: ${e.toString().replaceAll("Exception: ", "")}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleCRM - Clientes'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // BOTÃO DE LOGOUT ADICIONADO
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // O AuthCheckPage vai detectar a mudança e voltar para o login sozinho
              await _authController.logout(); 
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final customers = _controller.customers;

          if (customers.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum cliente cadastrado ainda.\nClique no botão abaixo para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    [
                      customer.phone,
                      customer.email,
                      customer.address,
                    ].where((item) => item != null && item.isNotEmpty).join(' • '),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _controller.removeCustomer(customer.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Cliente'),
      ),
    );
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/customers/repositories/customer_repository.dart -->
## modules/customers/repositories/customer_repository.dart

```
// lib/modules/customers/repositories/customer_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/customer_entity.dart';

class CustomerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Buscar todos os clientes da tabela correta 'customers'
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _supabase.from('customers').select();

      return (response as List).map((data) {
        return Customer(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          phone: data['phone'],
          email: data['email'],
          address: data['address'],
          status: CustomerStatus.potential,
          notes: data['notes'],
          createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
          updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      // CORRIGIDO: Em vez de esconder o erro e retornar uma lista vazia,
      // nós avisamos o Controller para que ele possa mostrar na tela.
      rethrow; 
    }
  }

  // Inserir um novo cliente na tabela 'customers'
  Future<void> addCustomer(Customer customer) async {
    try {
      await _supabase.from('customers').insert({
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'notes': customer.notes,
        // O user_id é preenchido automaticamente pelo Supabase (default auth.uid())
      });
    } catch (e) {
      rethrow;
    }
  }

  // Deletar um cliente e as deals associadas para manter a consistência com o Pipeline
  Future<void> deleteCustomer(String id) async {
    try {
      // 1. Remove primeiro as oportunidades (deals) associadas a este cliente no funil de vendas
      await _supabase.from('deals').delete().eq('customer_id', id);

      // 2. Remove o cliente da tabela 'customers'
      await _supabase.from('customers').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/pipeline/components/deal_card.dart -->
## modules/pipeline/components/deal_card.dart

```
// lib/modules/pipeline/components/deal_card.dart
import 'package:flutter/material.dart';
import '../models/deal_entity.dart';

class DealCard extends StatelessWidget {
  final DealEntity deal;
  final Function(DealStage) onStageChanged;
  final Function(String) onDelete;

  const DealCard({
    super.key,
    required this.deal,
    required this.onStageChanged,
    required this.onDelete,
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
                  child: PopupMenuButton<Object>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    tooltip: 'Opções da Oportunidade',
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete(deal.id);
                      } else if (value is DealStage) {
                        onStageChanged(value);
                      }
                    },
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
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text('Excluir Oportunidade', style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
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

```
<!-- END_FILE -->

---
<!-- FILE: modules/pipeline/components/deal_form_modal.dart -->
## modules/pipeline/components/deal_form_modal.dart

```
// lib/modules/pipeline/components/deal_form_modal.dart
import 'package:flutter/material.dart';
import '../../customers/presentation/customer_controller.dart';
import '../models/deal_entity.dart';

class DealFormModal extends StatefulWidget {
  final Function(DealEntity) onSave;
  final CustomerController customerController;

  const DealFormModal({
    super.key,
    required this.onSave,
    required this.customerController,
  });

  @override
  State<DealFormModal> createState() => _DealFormModalState();
}

class _DealFormModalState extends State<DealFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  
  dynamic _selectedCustomer;
  DealStage _selectedStage = DealStage.potential;

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nova Oportunidade',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título da Oportunidade'),
                  validator: (value) => value == null || value.isEmpty ? 'Informe o título' : null,
                ),
                const SizedBox(height: 12),
                
                // Seletor Dinâmico de Clientes Cadastrados
                AnimatedBuilder(
                  animation: widget.customerController,
                  builder: (context, child) {
                    final customers = widget.customerController.customers;

                    if (customers.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Nenhum cliente cadastrado. Cadastre um cliente primeiro na aba Clientes.',
                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        ),
                      );
                    }

                    return DropdownButtonFormField<dynamic>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(labelText: 'Selecione o Cliente'),
                      items: customers.map((customer) {
                        return DropdownMenuItem<dynamic>(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (customer) {
                        setState(() {
                          _selectedCustomer = customer;
                        });
                      },
                      validator: (value) => value == null ? 'Selecione um cliente' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(labelText: 'Valor (R\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Informe um valor válido' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DealStage>(
                  value: _selectedStage,
                  decoration: const InputDecoration(labelText: 'Etapa Inicial'),
                  items: DealStage.values.map((stage) {
                    return DropdownMenuItem(
                      value: stage,
                      child: Text(_getStageLabel(stage)),
                    );
                  }).toList(),
                  onChanged: (stage) {
                    if (stage != null) {
                      setState(() {
                        _selectedStage = stage;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && _selectedCustomer != null) {
                          final newDeal = DealEntity(
                            id: '',
                            customerId: _selectedCustomer.id,
                            customerName: _selectedCustomer.name,
                            title: _titleController.text,
                            value: double.tryParse(_valueController.text) ?? 0.0,
                            stage: _selectedStage,
                            createdAt: DateTime.now(),
                          );

                          widget.onSave(newDeal);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStageLabel(DealStage stage) {
    switch (stage) {
      case DealStage.potential:
        return 'Potencial';
      case DealStage.inNegotiation:
        return 'Em Negociação';
      case DealStage.proposalSent:
        return 'Proposta Enviada';
      case DealStage.activeClient:
        return 'Cliente Ativo';
      case DealStage.lost:
        return 'Perdido';
    }
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/pipeline/components/pipeline_column.dart -->
## modules/pipeline/components/pipeline_column.dart

```
// lib/modules/pipeline/components/pipeline_column.dart
import 'package:flutter/material.dart';
import '../models/deal_entity.dart';
import 'deal_card.dart';

class PipelineColumn extends StatelessWidget {
  final String title;
  final DealStage stage;
  final List<DealEntity> deals;
  final Color headerColor;
  final Function(String, DealStage) onStageChanged;
  final Function(String) onDelete; // Novo callback para exclusão

  const PipelineColumn({
    super.key,
    required this.title,
    required this.stage,
    required this.deals,
    required this.headerColor,
    required this.onStageChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240, // Largura reduzida para acomodar melhor na tela
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Cabeçalho da Coluna
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white,
                  child: Text(
                    '${deals.length}',
                    style: TextStyle(fontSize: 11, color: headerColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Lista de Cards da Coluna
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(6),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                return DealCard(
                  deal: deal,
                  onStageChanged: (newStage) => onStageChanged(deal.id, newStage),
                  onDelete: (dealId) => onDelete(dealId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/pipeline/controllers/pipeline_controller.dart -->
## modules/pipeline/controllers/pipeline_controller.dart

```
// lib/modules/pipeline/controllers/pipeline_controller.dart
import 'package:flutter/foundation.dart';
import '../models/deal_entity.dart';
import '../repositories/pipeline_repository.dart';

class PipelineController extends ChangeNotifier {
  final PipelineRepository _repository = PipelineRepository();

  List<DealEntity> _deals = [];
  bool _isLoading = false;
  String _searchQuery = '';
  DealStage? _selectedStageFilter;

  List<DealEntity> get deals {
    var filtered = _deals;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((deal) =>
          deal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          deal.customerName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_selectedStageFilter != null) {
      filtered = filtered.where((deal) => deal.stage == _selectedStageFilter).toList();
    }

    return filtered;
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  DealStage? get selectedStageFilter => _selectedStageFilter;

  Future<void> loadDeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _deals = await _repository.fetchDeals();
    } catch (e) {
      debugPrint('Erro ao carregar do Supabase: $e');
      rethrow; // CORRIGIDO: Repassa o erro para a tela
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeal(DealEntity deal) async {
    try {
      await _repository.createDeal(deal);
      await loadDeals();
    } catch (e) {
      debugPrint('Erro ao criar oportunidade: $e');
      rethrow; // CORRIGIDO: Repassa o erro para a tela
    }
  }

  Future<void> updateDealStage(String id, DealStage newStage) async {
    try {
      await _repository.updateDealStage(id, newStage);
      await loadDeals();
    } catch (e) {
      debugPrint('Erro ao atualizar estágio: $e');
      rethrow; // CORRIGIDO: Repassa o erro para a tela
    }
  }

  // Método de exclusão independente direto no Kanban
  Future<void> deleteDeal(String id) async {
    try {
      await _repository.deleteDeal(id);
      _deals.removeWhere((deal) => deal.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar oportunidade: $e');
      rethrow; // CORRIGIDO: Repassa o erro para a tela
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStageFilter(DealStage? stage) {
    _selectedStageFilter = stage;
    notifyListeners();
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/pipeline/models/deal_entity.dart -->
## modules/pipeline/models/deal_entity.dart

```
// lib/modules/pipeline/models/deal_entity.dart
enum DealStage { 
  potential,       // Potencial / Lead
  inNegotiation,   // Em Negociação
  proposalSent,    // Proposta Enviada
  activeClient,    // Cliente Ativo (Ganho)
  lost             // Perdido
}

class DealEntity {
  final String id;
  final String customerId;
  final String customerName;
  final String title;
  final double value;
  final DealStage stage;
  final DateTime createdAt;

  DealEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.value,
    required this.stage,
    required this.createdAt,
  });

  DealEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? title,
    double? value,
    DealStage? stage,
    DateTime? createdAt,
  }) {
    return DealEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      value: value ?? this.value,
      stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/pipeline/presentation/pipeline_page.dart -->
## modules/pipeline/presentation/pipeline_page.dart

```
// lib/modules/pipeline/presentation/pipeline_page.dart
import 'package:flutter/material.dart';
import '../controllers/pipeline_controller.dart';
import '../models/deal_entity.dart';
import '../components/pipeline_column.dart';
import '../components/deal_form_modal.dart';
import '../../customers/presentation/customer_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class PipelinePage extends StatefulWidget {
  const PipelinePage({super.key});

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage> {
  final PipelineController _controller = PipelineController();
  final CustomerController _customerController = CustomerController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _loadDealsComTratamentoDeErro(); // Chama a versão com tratamento de erro
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  // --- MÉTODOS DE TRATAMENTO DE ERRO ---

  Future<void> _loadDealsComTratamentoDeErro() async {
    try {
      await _controller.loadDeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar oportunidades: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAddDeal(DealEntity deal) async {
    try {
      await _controller.addDeal(deal);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar oportunidade: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateStage(String id, DealStage newStage) async {
    try {
      await _controller.updateDealStage(id, newStage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao mover oportunidade: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteDeal(String id) async {
    try {
      await _controller.deleteDeal(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir oportunidade: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ------------------------------------

  void _showAddDealDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DealFormModal(
          customerController: _customerController,
          onSave: (deal) async {
            // Usa a função de tratamento de erro
            await _handleAddDeal(deal); 
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleCRM - Funil de Vendas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Pipeline',
            onPressed: _loadDealsComTratamentoDeErro, // Atualiza com tratamento de erro
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await _authController.logout();
            },
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PipelineColumn(
                      title: 'Potencial',
                      stage: DealStage.potential,
                      deals: _controller.deals.where((d) => d.stage == DealStage.potential).toList(),
                      headerColor: Colors.blueAccent,
                      onStageChanged: _handleUpdateStage, // Usa o tratamento de erro
                      onDelete: _handleDeleteDeal, // Usa o tratamento de erro
                    ),
                    PipelineColumn(
                      title: 'Em Negociação',
                      stage: DealStage.inNegotiation,
                      deals: _controller.deals.where((d) => d.stage == DealStage.inNegotiation).toList(),
                      headerColor: Colors.orangeAccent,
                      onStageChanged: _handleUpdateStage,
                      onDelete: _handleDeleteDeal,
                    ),
                    PipelineColumn(
                      title: 'Proposta Enviada',
                      stage: DealStage.proposalSent,
                      deals: _controller.deals.where((d) => d.stage == DealStage.proposalSent).toList(),
                      headerColor: Colors.purpleAccent,
                      onStageChanged: _handleUpdateStage,
                      onDelete: _handleDeleteDeal,
                    ),
                    PipelineColumn(
                      title: 'Cliente Ativo',
                      stage: DealStage.activeClient,
                      deals: _controller.deals.where((d) => d.stage == DealStage.activeClient).toList(),
                      headerColor: Colors.green,
                      onStageChanged: _handleUpdateStage,
                      onDelete: _handleDeleteDeal,
                    ),
                    PipelineColumn(
                      title: 'Perdido',
                      stage: DealStage.lost,
                      deals: _controller.deals.where((d) => d.stage == DealStage.lost).toList(),
                      headerColor: Colors.redAccent,
                      onStageChanged: _handleUpdateStage,
                      onDelete: _handleDeleteDeal,
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDealDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Oportunidade'),
      ),
    );
  }
}

```
<!-- END_FILE -->

---
<!-- FILE: modules/pipeline/repositories/pipeline_repository.dart -->
## modules/pipeline/repositories/pipeline_repository.dart

```
// lib/modules/pipeline/repositories/pipeline_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deal_entity.dart';

class PipelineRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Buscar todas as oportunidades da tabela 'deals'
  Future<List<DealEntity>> fetchDeals() async {
    try {
      final response = await _supabase.from('deals').select();

      return (response as List).map((data) {
        // Mapeia a string do banco para o enum DealStage corretamente
        DealStage stageVal = DealStage.potential;
        final stageStr = data['stage'] as String?;
        if (stageStr == 'inNegotiation') stageVal = DealStage.inNegotiation;
        if (stageStr == 'proposalSent') stageVal = DealStage.proposalSent;
        if (stageStr == 'activeClient') stageVal = DealStage.activeClient;
        if (stageStr == 'lost') stageVal = DealStage.lost;

        return DealEntity(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          customerId: data['customer_id'] ?? '',
          customerName: data['customer_name'] ?? '',
          value: (data['value'] != null) ? (data['value'] as num).toDouble() : 0.0,
          stage: stageVal,
          createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      // CORRIGIDO: Repassa o erro para o Controller avisar a tela
      rethrow;
    }
  }

  // Criar uma nova oportunidade na tabela 'deals'
  Future<void> createDeal(DealEntity deal) async {
    try {
      await _supabase.from('deals').insert({
        'title': deal.title,
        'customer_id': deal.customerId,
        'customer_name': deal.customerName,
        'value': deal.value,
        'stage': deal.stage.name,
        // O user_id é preenchido automaticamente pelo Supabase (default auth.uid())
      });
    } catch (e) {
      // CORRIGIDO: Repassa o erro
      rethrow;
    }
  }

  // Atualizar o estágio de uma oportunidade
  Future<void> updateDealStage(String id, DealStage newStage) async {
    try {
      await _supabase.from('deals').update({
        'stage': newStage.name,
      }).eq('id', id);
    } catch (e) {
      // CORRIGIDO: Repassa o erro
      rethrow;
    }
  }

  // Deletar uma oportunidade diretamente pelo ID no Kanban
  Future<void> deleteDeal(String id) async {
    try {
      await _supabase.from('deals').delete().eq('id', id);
    } catch (e) {
      // CORRIGIDO: Repassa o erro
      rethrow;
    }
  }
}

```
<!-- END_FILE -->


---
## Bundle notes
- Redaction: enabled (mask: `***REDACTED***`).
- No truncations.

