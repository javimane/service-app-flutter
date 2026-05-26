import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/data/providers/session_provider.dart';
import '../../../core/data/notifiers/auth_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use centralized session provider
    final sessionInfo = ref.watch(sessionInfoProvider);
    final name = sessionInfo.name;
    final email = sessionInfo.email;
    final isProfessional = sessionInfo.isProfessional;
    final hasProfessionalSubscription = sessionInfo.hasProfessionalSubscription;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, size: 24.r),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/dashboard');
                      }
                    },
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Configuración',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(24.r),
                children: [
                  // User Card
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundColor: theme.colorScheme.primary.withAlpha(50),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: TextStyle(fontSize: 24.sp, color: theme.colorScheme.primary),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20.sp)),
                            Text(email,
                                style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Text(isProfessional ? 'PERFIL COMERCIAL' : 'CUENTA PERSONAL',
                                  style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),

                  // General Settings
                  Text('CONFIGURACIÓN GENERAL',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(letterSpacing: 1.5, color: Colors.grey, fontSize: 11.sp)),
                  SizedBox(height: 16.h),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.dark_mode, color: theme.colorScheme.primary, size: 24.r),
                    title: Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    trailing: Switch(
                      value: isDark,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).state =
                            val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.notifications, color: theme.colorScheme.primary, size: 24.r),
                    title: Text('Notificaciones Push', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    trailing: Switch(
                      value: true,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (val) {},
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Personal Account Settings
                  Text('MI CUENTA',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(letterSpacing: 1.5, color: Colors.grey, fontSize: 11.sp)),
                  SizedBox(height: 16.h),
                  const _SettingsItem(icon: Icons.person_outline, title: 'Datos Personales'),
                  const _SettingsItem(icon: Icons.security, title: 'Privacidad y Seguridad'),
                  
                  if (!isProfessional) ...[
                    const _SettingsItem(icon: Icons.photo_camera_front_outlined, title: 'Avatar y Portada'),
                  ],

                  SizedBox(height: 32.h),

                  // Business Account Settings (Only for professionals)
                  if (isProfessional) ...[
                    Text('PERFIL COMERCIAL',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(letterSpacing: 1.5, color: Colors.grey, fontSize: 11.sp)),
                    SizedBox(height: 16.h),
                    const _SettingsItem(icon: Icons.business, title: 'Datos del Comercio'),
                    const _SettingsItem(icon: Icons.category_outlined, title: 'Categorías y Servicios'),
                    const _SettingsItem(icon: Icons.location_on_outlined, title: 'Sedes y Cobertura'),
                    const _SettingsItem(icon: Icons.storefront_outlined, title: 'Operaciones (Local/Online)'),
                    const _SettingsItem(icon: Icons.payments_outlined, title: 'Métodos de Pago'),
                    const _SettingsItem(icon: Icons.verified_outlined, title: 'Verificación ARCA'),
                    SizedBox(height: 32.h),
                  ] else ...[
                    // Call to Action for Normal Users
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.business_center, color: theme.colorScheme.primary, size: 40.r),
                          SizedBox(height: 12.h),
                          Text('Completar Perfil Comercial',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          SizedBox(height: 8.h),
                          Text(
                            'Aún no has registrado los datos de tu comercio o actividad autónoma. Completalos para aparecer en las búsquedas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to Business Registration
                            },
                            icon: Icon(Icons.add_circle_outline, size: 18.r),
                            label: const Text('Comenzar Registro'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).logout();
                        context.go('/login');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: Colors.red.withAlpha(128)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      ),
                      child: Text('CERRAR SESIÓN',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey, size: 24.r),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey, size: 24.r),
      onTap: () {
        // TODO: Navigate to corresponding settings form
      },
    );
  }
}
