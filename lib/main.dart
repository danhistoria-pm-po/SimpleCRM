// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'modules/auth/pages/login_page.dart';
import 'modules/customers/presentation/customer_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const AuthCheckPage(),
    );
  }
}

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      if (event == AuthChangeEvent.signedOut) {
        // Limpa os dados do usuário que acabou de sair
        CustomerController().reset(); 
      } else if (event == AuthChangeEvent.signedIn) {
        // AJUSTE CRÍTICO: Força o Singleton a recarregar a lista para o novo usuário
        CustomerController().loadCustomers(); 
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