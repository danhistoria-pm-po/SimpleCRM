// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/follow_up/controllers/follow_up_controller.dart';
import 'home_page.dart';
import 'modules/auth/pages/login_page.dart';
import 'modules/billing/controllers/billing_controller.dart';
import 'modules/cash_flow/controllers/cash_flow_controller.dart';
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
      theme: AppTheme.lightTheme,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthCheckPage(),
    );
  }
}

class AuthCheckPage extends StatefulWidget {
  final Stream<AuthState>? authStateStream;
  final Session? Function()? currentSessionGetter;

  const AuthCheckPage({
    super.key,
    this.authStateStream,
    this.currentSessionGetter,
  });

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  StreamSubscription<AuthState>? _authSubscription;

  Stream<AuthState> get _stream =>
      widget.authStateStream ?? Supabase.instance.client.auth.onAuthStateChange;

  Session? get _currentSession => widget.currentSessionGetter != null
      ? widget.currentSessionGetter!()
      : Supabase.instance.client.auth.currentSession;

  @override
  void initState() {
    super.initState();
    _authSubscription = _stream.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        CustomerController().reset();
        BillingController().reset();
        CashFlowController().reset();
        FollowUpController().reset();
      } else if (event == AuthChangeEvent.signedIn) {
        CustomerController().ensureLoaded();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _stream,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? _currentSession;

        if (session != null) {
          return HomePage(key: ValueKey(session.user.id));
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
