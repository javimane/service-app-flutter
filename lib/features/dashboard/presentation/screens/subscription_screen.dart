import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service_app_flutter/core/data/repositories/subscription_repository.dart';

// ─── Plan model ─────────────────────────────────────────────────────────────

class _Plan {
  final String id;
  final String name;
  final String description;
  final int price;
  final String period;
  final bool recommended;
  final List<String> features;

  const _Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.period,
    required this.recommended,
    required this.features,
  });
}

// Fallback static plans (merged with API prices if available)
const _staticPlans = [
  _Plan(
    id: 'gratuito',
    name: 'Plan Gratuito',
    description: 'Comenzá sin costo. Ideal para explorar la plataforma.',
    price: 0,
    period: 'mes',
    recommended: false,
    features: [
      'Perfil público básico',
      'Hasta 3 servicios',
      'Sin reels',
    ],
  ),
  _Plan(
    id: 'profesional-basico',
    name: 'Profesional Básico',
    description: 'Para profesionales que quieren crecer y visibilizarse.',
    price: 4999,
    period: 'mes',
    recommended: false,
    features: [
      'Perfil profesional completo',
      'Servicios ilimitados',
      'Hasta 5 reels',
      'Estadísticas básicas',
      'Propuestas y presupuestos',
    ],
  ),
  _Plan(
    id: 'profesional-premium',
    name: 'Profesional Premium',
    description: 'El plan más completo para maximizar tu presencia.',
    price: 9999,
    period: 'mes',
    recommended: true,
    features: [
      'Todo lo del plan Básico',
      'Reels ilimitados',
      'Promociones bancarias',
      'Prioridad en búsquedas',
      'Soporte prioritario',
      'Analíticas avanzadas',
    ],
  ),
];

// Subscription status labels
const _statusLabels = {
  'active': 'Activa',
  'cancelled': 'Cancelada',
  'past_due': 'Pago pendiente',
  'none': 'Sin suscripción',
};

// ─── Providers ───────────────────────────────────────────────────────────────

final _subLoadingProvider = StateProvider<bool>((ref) => true);
final _subDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final _plansProvider = StateProvider<List<_Plan>>((ref) => _staticPlans);
final _showPlansProvider = StateProvider<bool>((ref) => false);
final _showCancelProvider = StateProvider<bool>((ref) => false);

// ─── Screen ──────────────────────────────────────────────────────────────────

class DashboardSubscriptionScreen extends ConsumerStatefulWidget {
  const DashboardSubscriptionScreen({super.key});

  @override
  ConsumerState<DashboardSubscriptionScreen> createState() =>
      _DashboardSubscriptionScreenState();
}

class _DashboardSubscriptionScreenState
    extends ConsumerState<DashboardSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    ref.read(_subLoadingProvider.notifier).state = true;
    try {
      final plans = await ref
          .read(subscriptionRepositoryProvider)
          .getSubscriptionPlans();
      // Merge API prices into static plan list
      if (plans.isNotEmpty) {
        final merged = _staticPlans.map((p) {
          final apiPlan = plans.firstWhere(
            (ap) => (ap['plan'] as String? ?? '').toLowerCase() ==
                p.id.split('-').first.toLowerCase(),
            orElse: () => {},
          );
          if (apiPlan.isEmpty) return p;
          return _Plan(
            id: p.id,
            name: p.name,
            description: p.description,
            price: (apiPlan['amount'] as num?)?.toInt() ?? p.price,
            period: p.period,
            recommended: p.recommended,
            features: p.features,
          );
        }).toList();
        ref.read(_plansProvider.notifier).state = merged;
      }
    } catch (e) {
      debugPrint('Error loading subscription plans: $e');
    } finally {
      ref.read(_subLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _launchCheckout(String planId) async {
    // Map plan IDs to MercadoPago checkout URLs (configure via env if needed)
    const urlMap = <String, String>{
      'profesional-basico':
          'https://www.mercadopago.com.ar/subscriptions/checkout?preapproval_plan_id=2c938084973e7cc2019741b76cc10003',
      'profesional-premium':
          'https://www.mercadopago.com.ar/subscriptions/checkout?preapproval_plan_id=2c938084973e7cc2019741b76cc10004',
    };
    final url = urlMap[planId];
    if (url != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abrir checkout MercadoPago:\n$url')));
      }
    }
  }

  String _normalizeStatus(String? status) {
    if (status == null || status.isEmpty) return 'none';
    if (status == 'cancelled' || status == 'canceled') return 'cancelled';
    if (status == 'past_due') return 'past_due';
    return 'active';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '—';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = ref.watch(_subLoadingProvider);
    final sub = ref.watch(_subDataProvider);
    final plans = ref.watch(_plansProvider);
    final showPlans = ref.watch(_showPlansProvider);
    final showCancel = ref.watch(_showCancelProvider);

    final status = _normalizeStatus(sub?['status'] as String?);
    final statusLabel = _statusLabels[status] ?? 'Desconocido';
    final activePlanId = sub?['plan'] != null
        ? {
            'free': 'gratuito',
            'standard': 'profesional-basico',
            'premium': 'profesional-premium',
          }[sub!['plan'] as String]
        : null;
    final currentPlan = activePlanId != null
        ? plans.where((p) => p.id == activePlanId).firstOrNull
        : null;

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
        title: const Text('Mi Suscripción'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                // ── Current plan card ──────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              theme.colorScheme.primary.withAlpha(40),
                              theme.colorScheme.surface,
                            ]
                          : [
                              theme.colorScheme.primary.withAlpha(15),
                              Colors.white,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: currentPlan?.recommended == true
                                  ? Colors.amber.withAlpha(25)
                                  : theme.colorScheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              currentPlan?.recommended == true
                                  ? Icons.bolt_rounded
                                  : Icons.workspace_premium_rounded,
                              color: currentPlan?.recommended == true
                                  ? Colors.amber
                                  : theme.colorScheme.primary,
                              size: 22.r,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPlan?.name ?? 'Sin suscripción activa',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  currentPlan?.description ??
                                      'Suscribite para activar tu perfil y acceder a todas las funciones.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                          if (sub != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: status == 'active'
                                    ? Colors.green.withAlpha(20)
                                    : Colors.red.withAlpha(20),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                    color: status == 'active'
                                        ? Colors.green.withAlpha(60)
                                        : Colors.red.withAlpha(60)),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: status == 'active'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),

                      if (sub != null && currentPlan != null) ...[
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            _DetailTile(
                              icon: Icons.attach_money_rounded,
                              label: 'Precio mensual',
                              value:
                                  '\$${currentPlan.price.toString()}/${currentPlan.period}',
                            ),
                            SizedBox(width: 8.w),
                            _DetailTile(
                              icon: Icons.calendar_today_rounded,
                              label: 'Próximo pago',
                              value: status == 'cancelled'
                                  ? '—'
                                  : _formatDate(sub['expires_at'] as String?),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text('Tu plan incluye:',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 6.h),
                        ...currentPlan.features.map(
                          (f) => Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.green, size: 14.r),
                                SizedBox(width: 6.w),
                                Text(f,
                                    style: TextStyle(fontSize: 13.sp)),
                              ],
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 16.h),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => ref
                                  .read(_showPlansProvider.notifier)
                                  .state = !showPlans,
                              icon: Icon(
                                showPlans
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.swap_horiz_rounded,
                                size: 18.r,
                              ),
                              label: Text(showPlans
                                  ? 'Ocultar planes'
                                  : (sub != null ? 'Cambiar plan' : 'Suscribirse')),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    EdgeInsets.symmetric(vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r)),
                              ),
                            ),
                          ),
                          if (sub != null && status == 'active') ...[
                            SizedBox(width: 8.w),
                            OutlinedButton(
                              onPressed: () => ref
                                  .read(_showCancelProvider.notifier)
                                  .state = true,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding:
                                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r)),
                              ),
                              child: Icon(Icons.cancel_outlined,
                                  size: 18.r, color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Cancel confirm
                if (showCancel)
                  _CancelDialog(
                    planName: currentPlan?.name ?? 'plan',
                    onConfirm: () {
                      ref.read(_showCancelProvider.notifier).state = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Suscripción cancelada al finalizar el período.')),
                      );
                    },
                    onKeep: () =>
                        ref.read(_showCancelProvider.notifier).state = false,
                  ),

                // ── Plan selector ──────────────────────────────────────────
                if (showPlans) ...[
                  SizedBox(height: 20.h),
                  Text('Elegí tu plan',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  ...plans.map((plan) {
                    final isCurrent = plan.id == activePlanId;
                    return _PlanCard(
                      plan: plan,
                      isCurrent: isCurrent,
                      onSelect: isCurrent
                          ? null
                          : () => plan.id == 'gratuito'
                              ? null
                              : _launchCheckout(plan.id),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}

// ─── Detail Tile ─────────────────────────────────────────────────────────────

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: theme.dividerColor.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 16.r),
            SizedBox(height: 4.h),
            Text(label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            Text(value,
                style: TextStyle(
                    fontSize: 13.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Plan Card ───────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool isCurrent;
  final VoidCallback? onSelect;

  const _PlanCard(
      {required this.plan, required this.isCurrent, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: plan.recommended
              ? Colors.amber.withAlpha(120)
              : isCurrent
                  ? theme.colorScheme.primary.withAlpha(80)
                  : (isDark ? Colors.white10 : Colors.black.withAlpha(15)),
          width: plan.recommended ? 1.5 : 1,
        ),
        boxShadow: [
          if (plan.recommended)
            BoxShadow(
                color: Colors.amber.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.recommended)
            Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded,
                      color: Colors.amber, size: 12.r),
                  SizedBox(width: 4.w),
                  Text('Recomendado',
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.amber,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          Row(
            children: [
              Icon(
                plan.recommended
                    ? Icons.bolt_rounded
                    : Icons.workspace_premium_outlined,
                color: plan.recommended
                    ? Colors.amber
                    : theme.colorScheme.primary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(plan.name,
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.bold)),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                        text: '\$',
                        style: TextStyle(
                            fontSize: 13.sp, color: Colors.grey)),
                    TextSpan(
                      text: plan.price == 0
                          ? 'Gratis'
                          : plan.price
                              .toString()
                              .replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]}.'),
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: plan.recommended
                              ? Colors.amber
                              : theme.colorScheme.primary),
                    ),
                    if (plan.price > 0)
                      TextSpan(
                          text: '/${plan.period}',
                          style: TextStyle(
                              fontSize: 11.sp, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(plan.description,
              style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          SizedBox(height: 10.h),
          ...plan.features.map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 13.r),
                  SizedBox(width: 6.w),
                  Text(f, style: TextStyle(fontSize: 12.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent
                    ? Colors.grey.withAlpha(40)
                    : plan.recommended
                        ? Colors.amber
                        : theme.colorScheme.primary,
                foregroundColor: isCurrent ? Colors.grey : Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text(
                isCurrent ? 'Plan actual' : 'Elegir plan',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cancel Dialog ───────────────────────────────────────────────────────────

class _CancelDialog extends StatelessWidget {
  final String planName;
  final VoidCallback onConfirm;
  final VoidCallback onKeep;

  const _CancelDialog({
    required this.planName,
    required this.onConfirm,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withAlpha(60)),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.red, size: 32.r),
          SizedBox(height: 10.h),
          Text('¿Cancelar suscripción?',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          SizedBox(height: 6.h),
          Text(
            'Perderás el acceso al plan $planName al finalizar el período de facturación actual.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onConfirm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: const Text('Sí, cancelar'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onKeep,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: const Text('Mantener plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
