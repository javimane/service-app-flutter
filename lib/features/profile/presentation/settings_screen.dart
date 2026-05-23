import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    onPressed: () => context.pop(),
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alex Mercer',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp)),
                          Text('usuario@obsidian.io',
                              style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(51),
                                borderRadius: BorderRadius.circular(8.r)),
                            child: Text('CUENTA PREMIUM',
                                style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),
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
                  Text('MI CUENTA',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(letterSpacing: 1.5, color: Colors.grey, fontSize: 11.sp)),
                  SizedBox(height: 16.h),
                  const _SettingsItem(icon: Icons.person_outline, title: 'Datos Personales'),
                  const _SettingsItem(icon: Icons.payment, title: 'Métodos de Pago'),
                  const _SettingsItem(icon: Icons.security, title: 'Privacidad y Seguridad'),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/login'),
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
      onTap: () {},
    );
  }
}

