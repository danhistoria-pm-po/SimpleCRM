// lib/home_page.dart
import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'modules/pipeline/presentation/pipeline_page.dart';
import 'modules/customers/presentation/customer_list_page.dart';
import 'modules/billing/presentation/billing_page.dart';
import 'modules/cash_flow/presentation/cash_flow_page.dart';
import 'features/follow_up/views/follow_up_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
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