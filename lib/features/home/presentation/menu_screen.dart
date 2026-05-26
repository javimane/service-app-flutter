import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(theme, 'PARA TI'),
            _buildMenuItem(
                context, Icons.people_outline, 'Professionales/Comercios',
                route: '/specialist'),
            _buildMenuItem(context, Icons.local_offer_outlined, 'Promociones',
                route: '/promotions'),
            _buildMenuItem(context, Icons.inventory_2_outlined, 'Productos',
                route: '/products'),
            _buildMenuItem(context, Icons.map_outlined, 'Mapa', route: '/map'),
            _buildMenuItem(context, Icons.build_outlined, 'Servicios',
                route: '/services'),
            _buildMenuItem(context, Icons.movie_filter_outlined, 'Reels',
                route: '/reels'),
            const Divider(),
            _buildSectionHeader(theme, 'DASHBOARD'),
            _buildMenuItem(context, Icons.analytics, 'Analíticas',
                route: '/dashboard/analytics'),
            _buildMenuItem(context, Icons.notifications_none, 'Notificaciones',
                route: '/dashboard/notifications'),
            _buildMenuItem(
                context, Icons.request_quote_outlined, 'Presupuestos',
                route: '/dashboard/proposals'),
            _buildMenuItem(context, Icons.discount_outlined, 'Promociones',
                route: '/dashboard/promotions'),
            _buildMenuItem(context, Icons.account_balance_outlined,
                'Promociones Bancarias',
                route: '/dashboard/bank-promotions'),
            _buildMenuItem(context, Icons.category_outlined, 'Productos',
                route: '/dashboard/products'),
            _buildMenuItem(context, Icons.person_outline, 'Perfil',
                route: '/dashboard/profile'),
            _buildMenuItem(
                context, Icons.miscellaneous_services_outlined, 'Servicios',
                route: '/dashboard/services'),
            _buildMenuItem(context, Icons.calendar_month_outlined, 'Calendario',
                route: '/dashboard/calendar'),
            _buildMenuItem(context, Icons.video_collection_outlined, 'Reels',
                route: '/dashboard/reels'),
            _buildMenuItem(context, Icons.share_outlined, 'Referidos',
                route: '/dashboard/referrals'),
            const Divider(),
            _buildSectionHeader(theme, 'CONFIGURACIÓN'),
            _buildMenuItem(
                context, Icons.card_membership_outlined, 'Subscripción',
                route: '/dashboard/subscription'),
            _buildMenuItem(context, Icons.badge_outlined, 'Datos Generales',
                route: '/dashboard/profile'),
            const Divider(),
            _buildMenuItem(context, Icons.help_outline, 'Ayuda'),
            _buildMenuItem(context, Icons.logout, 'Cerrar Sesión',
                isDestructive: true),
            SizedBox(height: 40.h),
          ],
        ),
      ),
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
      {bool isDestructive = false, String? route}) {
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
        if (route != null) {
          context.push(route);
        }
      },
    );
  }
}
