import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service_app_flutter/features/home/presentation/home_screen.dart';
import 'package:service_app_flutter/features/map/presentation/map_screen.dart';
import 'package:service_app_flutter/features/categories/presentation/categories_screen.dart';
import 'package:service_app_flutter/features/chat/presentation/conversations_screen.dart';
import 'package:go_router/go_router.dart';
// Removed unused imports: chat_screen and settings_screen

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int get _currentIndex {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/categories')) return 1;
    if (location.startsWith('/map')) return 2;
    if (location.startsWith('/reels')) return 3;
    if (location.startsWith('/chat')) return 4;
    return 0; // Default
  }

  void _onItemTapped(int index) {
    if (index == 5) {
      _showDashboardMenu(context);
      return;
    }
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/categories');
        break;
      case 2:
        context.go('/map');
        break;
      case 3:
        context.go('/reels');
        break;
      case 4:
        context.go('/chat');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
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
              icon: Icon(Icons.category_outlined),
              label: 'Categorías',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline),
              label: 'Videos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Mensajes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menú',
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
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Text(
                      'Menú Principal',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildSectionHeader(theme, 'PARA TI'),
                  _buildMenuItem(context, Icons.people_outline,
                      'Professionales/Comercios'),
                  _buildMenuItem(
                      context, Icons.local_offer_outlined, 'Promociones'),
                  _buildMenuItem(
                      context, Icons.inventory_2_outlined, 'Productos'),
                  _buildMenuItem(context, Icons.map_outlined, 'Mapa'),
                  _buildMenuItem(context, Icons.build_outlined, 'Servicios'),
                  _buildMenuItem(context, Icons.movie_filter_outlined, 'Reels'),
                  const Divider(),
                  _buildSectionHeader(theme, 'DASHBOARD'),
                  _buildMenuItem(
                      context, Icons.notifications_none, 'Notificaciones'),
                  _buildMenuItem(
                      context, Icons.chat_bubble_outline, 'Mensajes'),
                  _buildMenuItem(
                      context, Icons.request_quote_outlined, 'Presupuestos'),
                  _buildMenuItem(
                      context, Icons.discount_outlined, 'Promociones'),
                  _buildMenuItem(context, Icons.account_balance_outlined,
                      'Promociones Bancarias'),
                  _buildMenuItem(context, Icons.category_outlined, 'Productos'),
                  _buildMenuItem(context, Icons.person_outline, 'Perfil'),
                  _buildMenuItem(context, Icons.miscellaneous_services_outlined,
                      'Servicios'),
                  _buildMenuItem(
                      context, Icons.calendar_month_outlined, 'Calendario'),
                  _buildMenuItem(
                      context, Icons.video_collection_outlined, 'Reels'),
                  _buildMenuItem(context, Icons.share_outlined, 'Referidos'),
                  const Divider(),
                  _buildSectionHeader(theme, 'CONFIGURACIÓN'),
                  _buildMenuItem(
                      context, Icons.card_membership_outlined, 'Subscripción'),
                  _buildMenuItem(
                      context, Icons.badge_outlined, 'Datos Generales'),
                  const Divider(),
                  _buildMenuItem(context, Icons.help_outline, 'Ayuda'),
                  _buildMenuItem(context, Icons.logout, 'Cerrar Sesión',
                      isDestructive: true),
                  SizedBox(height: 40.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title,
      {bool isDestructive = false}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
        size: 24.r,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          color: isDestructive ? theme.colorScheme.error : null,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 20.r, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        // Lógica de navegación con GoRouter aquí
      },
    );
  }
}
