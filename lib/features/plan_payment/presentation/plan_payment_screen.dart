import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
// removed unused import

class PlanPaymentScreen extends ConsumerWidget {
  const PlanPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fallback static plans if API doesn't return anything
    final staticPlans = [
      const _PlanData(
        name: 'Free',
        price: 0,
        period: 'mes',
        features: [
          'Perfil básico',
          'Hasta 3 servicios',
          'Mensajes ilimitados',
          'Visibilidad estándar',
        ],
        color: Color(0xFF9E9E9E),
        isPopular: false,
      ),
      const _PlanData(
        name: 'Professional',
        price: 4999,
        period: 'mes',
        features: [
          'Todo lo de Free',
          'Servicios ilimitados',
          'Reels y videos',
          'Promociones propias',
          'Promos bancarias',
          'Presupuestos digitales',
          'Calendario de trabajos',
          'Estadísticas avanzadas',
        ],
        color: Color(0xFFFF7F50),
        isPopular: true,
      ),
      const _PlanData(
        name: 'Premium',
        price: 9999,
        period: 'mes',
        features: [
          'Todo lo de Professional',
          'Posición destacada',
          'Badge verificado',
          'Soporte prioritario',
          'API acceso',
          'Analytics avanzado',
        ],
        color: Color(0xFF9C27B0),
        isPopular: false,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back_rounded, size: 24.r),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(31),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        'PLANES Y PRECIOS',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Elegí el plan\nque más te conviene',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Comenzá gratis y escalá cuando estés listo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Plans
            SliverToBoxAdapter(
              child: Column(
                children:
                    staticPlans.map((plan) => _PlanCard(plan: plan)).toList(),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            // Features comparison
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comparación completa',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    const _FeatureRow(
                        feature: 'Perfil público',
                        free: true,
                        professional: true,
                        premium: true),
                    const _FeatureRow(
                        feature: 'Mensajes',
                        free: true,
                        professional: true,
                        premium: true),
                    const _FeatureRow(
                        feature: 'Reels de video',
                        free: false,
                        professional: true,
                        premium: true),
                    const _FeatureRow(
                        feature: 'Promociones propias',
                        free: false,
                        professional: true,
                        premium: true),
                    const _FeatureRow(
                        feature: 'Presupuestos',
                        free: false,
                        professional: true,
                        premium: true),
                    const _FeatureRow(
                        feature: 'Posición destacada',
                        free: false,
                        professional: false,
                        premium: true),
                    const _FeatureRow(
                        feature: 'Badge verificado',
                        free: false,
                        professional: false,
                        premium: true),
                    const _FeatureRow(
                        feature: 'Soporte prioritario',
                        free: false,
                        professional: false,
                        premium: true),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 80.h)),
          ],
        ),
      ),
    );
  }
}

class _PlanData {
  final String name;
  final double price;
  final String period;
  final List<String> features;
  final Color color;
  final bool isPopular;

  const _PlanData({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.color,
    required this.isPopular,
  });
}

class _PlanCard extends StatelessWidget {
  final _PlanData plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: plan.isPopular
              ? plan.color
              : (isDark ? Colors.white12 : Colors.black.withAlpha(20)),
          width: plan.isPopular ? 2 : 1,
        ),
        color: plan.isPopular
            ? plan.color.withAlpha((isDark ? 0.15 : 0.05 * 255).round())
            : theme.colorScheme.surface,
        boxShadow: plan.isPopular
            ? [
                BoxShadow(
                    color: plan.color.withAlpha(51),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ]
            : [],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: plan.color,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              plan.price == 0
                                  ? 'GRATIS'
                                  : '\$${plan.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: plan.price == 0 ? 24.sp : 30.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (plan.price > 0) ...[
                              SizedBox(width: 4.w),
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Text('/${plan.period}',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 13.sp)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    if (plan.isPopular)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: plan.color,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '⭐ Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                ...plan.features.map(
                  (f) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: plan.color, size: 18.r),
                        SizedBox(width: 10.w),
                        Text(f, style: TextStyle(fontSize: 13.sp)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.color,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      plan.price == 0 ? 'Comenzar gratis' : 'Suscribirme',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String feature;
  final bool free;
  final bool professional;
  final bool premium;

  const _FeatureRow({
    required this.feature,
    required this.free,
    required this.professional,
    required this.premium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget checkOrX(bool value) => Icon(
          value ? Icons.check_rounded : Icons.close_rounded,
          color: value ? Colors.green : Colors.red.withAlpha(128),
          size: 18.r,
        );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: isDark ? Colors.white10 : Colors.black.withAlpha(15)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(feature, style: TextStyle(fontSize: 13.sp)),
          ),
          Expanded(child: Center(child: checkOrX(free))),
          Expanded(child: Center(child: checkOrX(professional))),
          Expanded(child: Center(child: checkOrX(premium))),
        ],
      ),
    );
  }
}
