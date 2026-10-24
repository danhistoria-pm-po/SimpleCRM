// lib/home_page.dart
import 'package:flutter/material.dart';
import 'modules/pipeline/presentation/pipeline_page.dart';
import 'modules/customers/presentation/customer_list_page.dart';
// Importe aqui as páginas das outras abas conforme os arquivos existentes no seu projeto:
// import 'modules/billing/presentation/billing_page.dart';
// import 'modules/cashflow/presentation/cash_flow_page.dart';
// import 'modules/follow_up/presentation/follow_up_page.dart';

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
    const CustomerListPage(), // Certifique-se de usar a classe de listagem de clientes do seu módulo
    // Placeholders temporários caso as outras páginas ainda usem nomes diferentes de rota:
    const Scaffold(body: Center(child: Text('Gestão de Faturamento & Notas Fiscais'))),
    const Scaffold(body: Center(child: Text('Fluxo de Caixa Simples'))),
    const Scaffold(body: Center(child: Text('Pós-Venda & Follow-up'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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