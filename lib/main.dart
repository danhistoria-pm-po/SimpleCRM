// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'modules/pipeline/presentation/pipeline_page.dart';

Future<void> main() async {
  // Garante que os bindings do Flutter estão prontos antes de inicializar serviços externos
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Substitua pelas suas credenciais reais do Supabase (URL e Anon Key)
  await Supabase.initialize(
    url: 'https://cmvkanmyrhoxuprlpexh.supabase.co',
    publishableKey: 'sb_publishable_KsrWncim4nyX3ctKl9fKeA_yNKXwqa2',
  );

  runApp(const SimpleCRMApp());
}

class SimpleCRMApp extends StatelessWidget {
  const SimpleCRMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleCRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PipelinePage(),
    );
  }
}