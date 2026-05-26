// lib/core/widgets/plan_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/session_provider.dart';

/// Widget that conditionally displays [child] based on the user's subscription
/// plan and professional status. If the requirements are not met, a fallback
/// screen is shown prompting the user to upgrade.
class PlanGuard extends ConsumerWidget {
  final Widget child;
  final List<String> allowedPlans; // e.g. ['standard', 'premium']
  final bool requireProfessional; // if true, only professional accounts can access

  const PlanGuard({
    super.key,
    required this.child,
    required this.allowedPlans,
    this.requireProfessional = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionInfoProvider);
    final plan = session.plan ?? 'free';
    final hasAccess = session.isActive &&
        allowedPlans.contains(plan) &&
        (!requireProfessional || session.isProfessional);

    if (hasAccess) return child;

    // Fallback UI similar to SubscriptionWrapper
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
        title: const Text('Acceso Requerido'),
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
                'Se requiere una suscripción ${allowedPlans.join('/')} activa',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Para acceder a esta funcionalidad necesitás una suscripción ${allowedPlans.join('/')}.'
                ' Por favor, actualizá tu plan.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.push('/dashboard/subscription'),
                child: const Text('Ver planes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
