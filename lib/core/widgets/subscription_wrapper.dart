import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/notifiers/auth_notifier.dart';

class SubscriptionWrapper extends ConsumerWidget {
  final Widget child;
  const SubscriptionWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final sessionMap = authState.session;

    bool isFreePlan = true; // Default to free if we can't determine

    if (sessionMap != null) {
      // Try to parse the nested structure similar to web's LoginResponse
      final sessionStatus = sessionMap['sessionStatus'] as Map<String, dynamic>?;
      if (sessionStatus != null) {
        final subscription = sessionStatus['subscription'] as Map<String, dynamic>?;
        if (subscription != null) {
          final plan = subscription['plan'] as String?;
          isFreePlan = plan == 'free';
        }
      }
    }

    if (isFreePlan) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
          title: const Text('Suscripción Requerida'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(height: 24),
                Text(
                  'Suscripción profesional requerida',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Para acceder a esta funcionalidad necesitás una suscripción profesional activa.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.push('/dashboard/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Ver planes'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
