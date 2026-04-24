import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alex Mercer', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('usuario@obsidian.io', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('CUENTA PREMIUM', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text('CONFIGURACIÓN GENERAL', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: Colors.grey)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.dark_mode, color: theme.colorScheme.primary),
            title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Switch(
              value: isDark,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.notifications, color: theme.colorScheme.primary),
            title: const Text('Notificaciones Push', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Switch(
              value: true,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {},
            ),
          ),
          const SizedBox(height: 32),
          Text('MI CUENTA', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: Colors.grey)),
          const SizedBox(height: 16),
          _SettingsItem(icon: Icons.person_outline, title: 'Datos Personales'),
          _SettingsItem(icon: Icons.payment, title: 'Métodos de Pago'),
          _SettingsItem(icon: Icons.security, title: 'Privacidad y Seguridad'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
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
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
