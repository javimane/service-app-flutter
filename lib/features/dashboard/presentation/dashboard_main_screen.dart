import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
// removed unused repository imports

// Dashboard view state
final dashboardViewProvider = StateProvider<String>((ref) => 'overview');

class DashboardMainScreen extends ConsumerWidget {
  const DashboardMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // theme/isDark not needed here
    final currentView = ref.watch(dashboardViewProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _DashboardSidebar(currentView: currentView),
          // Main content
          Expanded(
            child: SafeArea(
              child: _DashboardContent(view: currentView),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSidebar extends ConsumerWidget {
  final String currentView;

  const _DashboardSidebar({required this.currentView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        width: 64.w,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0F0F23),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            // Logo
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child:
                  Icon(Icons.search_rounded, color: Colors.white, size: 22.r),
            ),
            SizedBox(height: 32.h),
            _SidebarItem(
                icon: Icons.dashboard_rounded,
                view: 'overview',
                currentView: currentView),
            _SidebarItem(
                icon: Icons.description_rounded,
                view: 'proposals',
                currentView: currentView),
            _SidebarItem(
                icon: Icons.local_offer_rounded,
                view: 'promotions',
                currentView: currentView),
            _SidebarItem(
                icon: Icons.inventory_2_rounded,
                view: 'products',
                currentView: currentView),
            _SidebarItem(
                icon: Icons.build_rounded,
                view: 'services',
                currentView: currentView),
            _SidebarItem(
                icon: Icons.play_circle_rounded,
                view: 'reels',
                currentView: currentView),
            _SidebarItem(
                icon: Icons.calendar_month_rounded,
                view: 'calendar',
                currentView: currentView),
            _SidebarItem(
                icon: Icons.notifications_rounded,
                view: 'notifications',
                currentView: currentView),
            const Spacer(),
            _SidebarItem(
                icon: Icons.person_rounded,
                view: 'profile',
                currentView: currentView),
            _SidebarItem(
                icon: Icons.card_membership_rounded,
                view: 'subscription',
                currentView: currentView),
            SizedBox(height: 12.h),
            IconButton(
              onPressed: () => context.go('/login'),
              icon: Icon(Icons.logout_rounded,
                  color: Colors.red.withAlpha(178), size: 22.r),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends ConsumerWidget {
  final IconData icon;
  final String view;
  final String currentView;

  const _SidebarItem(
      {required this.icon, required this.view, required this.currentView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isActive = currentView == view;

    return GestureDetector(
      onTap: () => ref.read(dashboardViewProvider.notifier).state = view,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withAlpha(51)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: isActive ? theme.colorScheme.primary : Colors.white38,
          size: 22.r,
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final String view;

  const _DashboardContent({required this.view});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (view) {
      case 'overview':
        return const _DashboardOverview();
      case 'proposals':
        return const _DashboardProposals();
      case 'promotions':
        return const _DashboardPromotions();
      case 'products':
        return const _DashboardProducts();
      case 'services':
        return const _DashboardServices();
      case 'reels':
        return const _DashboardReels();
      case 'calendar':
        return const _DashboardCalendar();
      case 'notifications':
        return const _DashboardNotifications();
      case 'profile':
        return const _DashboardProfile();
      case 'subscription':
        return const _DashboardSubscription();
      default:
        return const _DashboardOverview();
    }
  }
}

// ─── Overview ──────────────────────────────────────────────────────────────
class _DashboardOverview extends ConsumerWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard',
                      style: TextStyle(
                          fontSize: 22.sp, fontWeight: FontWeight.w900)),
                  Text('Bienvenido de vuelta',
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                ],
              ),
              CircleAvatar(
                radius: 20.r,
                backgroundImage:
                    const NetworkImage('https://i.pravatar.cc/100?img=11'),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Vistas al perfil',
                  value: '—',
                  icon: Icons.visibility_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Presupuestos',
                  value: '—',
                  icon: Icons.description_rounded,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              const Expanded(
                child: _StatCard(
                  title: 'Views Reels',
                  value: '—',
                  icon: Icons.play_circle_rounded,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 12.w),
              const Expanded(
                child: _StatCard(
                  title: 'Likes Reels',
                  value: '—',
                  icon: Icons.favorite_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          Text('Acciones Rápidas',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),

          _QuickAction(
            icon: Icons.add_circle_rounded,
            title: 'Crear Presupuesto',
            subtitle: 'Nuevo presupuesto para cliente',
            onTap: () =>
                ref.read(dashboardViewProvider.notifier).state = 'proposals',
          ),
          _QuickAction(
            icon: Icons.local_offer_rounded,
            title: 'Gestionar Promociones',
            subtitle: 'Crear y editar ofertas',
            onTap: () =>
                ref.read(dashboardViewProvider.notifier).state = 'promotions',
          ),
          _QuickAction(
            icon: Icons.play_circle_rounded,
            title: 'Subir Reels',
            subtitle: 'Mostrar tus trabajos en video',
            onTap: () =>
                ref.read(dashboardViewProvider.notifier).state = 'reels',
          ),
          _QuickAction(
            icon: Icons.person_rounded,
            title: 'Editar Perfil',
            subtitle: 'Actualizar información pública',
            onTap: () =>
                ref.read(dashboardViewProvider.notifier).state = 'profile',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((isDark ? 0.2 : 0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22.r),
          SizedBox(height: 10.h),
          Text(value,
              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900)),
          SizedBox(height: 4.h),
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withAlpha(13),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(31),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20.r),
          ],
        ),
      ),
    );
  }
}

// ─── Proposals ─────────────────────────────────────────────────────────────
class _DashboardProposals extends StatelessWidget {
  const _DashboardProposals();

  @override
  Widget build(BuildContext context) {
    // theme not needed here
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Presupuestos',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () => _showCreateProposalSheet(context),
            icon: Icon(Icons.add_rounded, size: 18.r),
            label: const Text('Nuevo Presupuesto'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
          SizedBox(height: 24.h),
          Text('Mis Presupuestos',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Center(
            child: Column(
              children: [
                SizedBox(height: 40.h),
                Icon(Icons.description_outlined,
                    size: 64.r, color: Colors.grey),
                SizedBox(height: 12.h),
                Text('No hay presupuestos aún',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateProposalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => _CreateProposalSheet(),
    );
  }
}

class _CreateProposalSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // theme not needed here

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(76),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text('Nuevo Presupuesto',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          const _DashField(
              label: 'Título del Proyecto',
              hint: 'Ej: Instalación eléctrica completa'),
          SizedBox(height: 12.h),
          const _DashField(
              label: 'Descripción', hint: 'Detallá el trabajo...', maxLines: 3),
          SizedBox(height: 12.h),
          const _DashField(
              label: 'Monto (\$)',
              hint: '0.00',
              keyboardType: TextInputType.number),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: const Text('Crear Presupuesto'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _DashField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54)),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withAlpha(20)),
          ),
          child: TextField(
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Promotions dashboard section ──────────────────────────────────────────
class _DashboardPromotions extends StatelessWidget {
  const _DashboardPromotions();

  @override
  Widget build(BuildContext context) {
    return const _DashboardPlaceholderSection(
      title: 'Mis Promociones',
      icon: Icons.local_offer_rounded,
      description: 'Creá promociones para atraer más clientes',
      actionLabel: 'Crear Promoción',
    );
  }
}

class _DashboardProducts extends StatelessWidget {
  const _DashboardProducts();

  @override
  Widget build(BuildContext context) {
    return const _DashboardPlaceholderSection(
      title: 'Mis Productos',
      icon: Icons.inventory_2_rounded,
      description: 'Administrá el catálogo de tus productos',
      actionLabel: 'Agregar Producto',
    );
  }
}

class _DashboardServices extends StatelessWidget {
  const _DashboardServices();

  @override
  Widget build(BuildContext context) {
    return const _DashboardPlaceholderSection(
      title: 'Mis Servicios',
      icon: Icons.build_rounded,
      description: 'Gestioná los servicios que ofrecés',
      actionLabel: 'Agregar Servicio',
    );
  }
}

class _DashboardReels extends StatelessWidget {
  const _DashboardReels();

  @override
  Widget build(BuildContext context) {
    return const _DashboardPlaceholderSection(
      title: 'Mis Reels',
      icon: Icons.play_circle_rounded,
      description: 'Subí videos de tus mejores trabajos',
      actionLabel: 'Subir Video',
    );
  }
}

class _DashboardCalendar extends StatelessWidget {
  const _DashboardCalendar();

  @override
  Widget build(BuildContext context) {
    return const _DashboardPlaceholderSection(
      title: 'Calendario',
      icon: Icons.calendar_month_rounded,
      description: 'Organizá tus trabajos y citas',
      actionLabel: 'Agregar Evento',
    );
  }
}

class _DashboardNotifications extends StatelessWidget {
  const _DashboardNotifications();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notificaciones',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
          SizedBox(height: 20.h),
          const _NotifItem(
            icon: Icons.description_rounded,
            title: 'Nuevo presupuesto recibido',
            subtitle: 'Juan Pérez solicitó un presupuesto',
            time: 'Hace 2 horas',
            color: Colors.blue,
          ),
          const _NotifItem(
            icon: Icons.star_rounded,
            title: 'Nueva reseña',
            subtitle: 'Recibiste una reseña de 5 estrellas',
            time: 'Hace 1 día',
            color: Colors.amber,
          ),
          const _NotifItem(
            icon: Icons.message_rounded,
            title: 'Mensaje nuevo',
            subtitle: 'María García te envió un mensaje',
            time: 'Hace 2 días',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _NotifItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
        ],
      ),
    );
  }
}

class _DashboardProfile extends StatelessWidget {
  const _DashboardProfile();

  @override
  Widget build(BuildContext context) {
    return const _DashboardPlaceholderSection(
      title: 'Mi Perfil',
      icon: Icons.person_rounded,
      description: 'Actualizá tu información profesional',
      actionLabel: 'Editar Perfil',
    );
  }
}

class _DashboardSubscription extends StatelessWidget {
  const _DashboardSubscription();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suscripción',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7F50), Color(0xFFFF4500)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.card_membership_rounded,
                        color: Colors.white, size: 24.r),
                    SizedBox(width: 8.w),
                    Text('Plan Free',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8.h),
                Text('Actualizá tu plan para acceder a más funciones',
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => context.push('/plan-payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF7F50),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('Ver planes',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPlaceholderSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final String actionLabel;

  const _DashboardPlaceholderSection({
    required this.title,
    required this.icon,
    required this.description,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add_rounded, size: 18.r),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
          SizedBox(height: 40.h),
          Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      size: 56.r,
                      color: theme.colorScheme.primary.withAlpha(128)),
                ),
                SizedBox(height: 20.h),
                Text(
                  'No hay contenido aún',
                  style:
                      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
