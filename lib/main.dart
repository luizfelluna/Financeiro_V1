import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'state/finance_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/entries_screen.dart';
import 'screens/projects_registry_screen.dart';

void main() {
  runApp(const GestaoFinanceiraApp());
}

class GestaoFinanceiraApp extends StatefulWidget {
  const GestaoFinanceiraApp({super.key});

  @override
  State<GestaoFinanceiraApp> createState() => _GestaoFinanceiraAppState();
}

class _GestaoFinanceiraAppState extends State<GestaoFinanceiraApp> {
  final FinanceController _controller = FinanceController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(controller: _controller),
      EntriesScreen(controller: _controller),
      ProjectsRegistryScreen(controller: _controller),
    ];

    return MaterialApp(
      title: 'Gestão Financeira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Gestão Financeira'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Chip(
                    backgroundColor: AppColors.navyBlue,
                    side: BorderSide.none,
                    label: const Text(
                      'Protótipo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: screens[_selectedIndex],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.lightBlue.withValues(alpha: 0.25),
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Painel',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.swap_vert_circle_outlined),
                    selectedIcon: Icon(Icons.swap_vert_circle),
                    label: 'Lançamentos',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.folder_shared_outlined),
                    selectedIcon: Icon(Icons.folder_shared),
                    label: 'Projetos & Cadastros',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
