import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_app_flutter/features/home/presentation/home_screen.dart';
import 'package:service_app_flutter/features/map/presentation/map_screen.dart';
import 'package:service_app_flutter/features/chat/presentation/chat_screen.dart';
import 'package:service_app_flutter/features/profile/presentation/settings_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  // En un entorno real se usaría StatefulShellRoute de go_router,
  // aquí usamos un bottom nav bar estático para la demostración UI.
  int currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDashboardMenu(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              label: 'Explorar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Mensajes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  void _showDashboardMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dashboard',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildMenuItem(context, Icons.dashboard_outlined, 'Principal Dashboard'),
                      _buildMenuItem(context, Icons.person_outline, 'Mi Perfil'),
                      _buildMenuItem(context, Icons.analytics_outlined, 'Analytics'),
                      _buildMenuItem(context, Icons.request_quote_outlined, 'Presupuestos'),
                      _buildMenuItem(context, Icons.local_offer_outlined, 'Promociones'),
                      _buildMenuItem(context, Icons.account_balance_outlined, 'Promociones Bancarias'),
                      _buildMenuItem(context, Icons.inventory_2_outlined, 'Productos'),
                      _buildMenuItem(context, Icons.calendar_month_outlined, 'Calendario'),
                      _buildMenuItem(context, Icons.video_library_outlined, 'Reels'),
                      _buildMenuItem(context, Icons.card_membership_outlined, 'Subscripción'),
                      _buildMenuItem(context, Icons.settings_outlined, 'Configuración'),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet
        if (title == 'Principal Dashboard') {
          // Temporarily use GoRouter context.push without importing if we assume go_router is available globally,
          // but we might need to import go_router in main_scaffold.dart. 
          // Actually, let's just make sure go_router is imported.
        }
      },
    );
  }
}
