// lib/app/routes/home_page.dart
import 'package:flutter/material.dart';
import '../../modules/pipeline/presentation/pipeline_page.dart';
import '../../modules/customers/presentation/customer_list_page.dart';
import '../../modules/billing/presentation/billing_page.dart';
import '../../modules/cash_flow/presentation/cash_flow_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Lista com todos os ecrãs do SimpleCRM (incluindo o espaço reservado para a Sprint 5)
  final List<Widget> _pages = [
    const PipelinePage(),
    const CustomerListPage(),
    const BillingPage(),
    const CashFlowPage(),
    // Placeholder temporário para a Sprint 5 (Pós-Venda)
    const Scaffold(
      body: Center(
        child: Text(
          'Sprint 5 – Pós-Venda & Satisfação\n(Em Breve)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
            icon: Icon(Icons.view_kanban),
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