import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/repositories/professionals_repository.dart';

// Promotions screen - uses professionals ranking as featured specialists
// Real promotions API not available, so we show featured professionals with their services
class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final professionalsAsync = ref.watch(professionalsProvider);

    // Sample bank promotions (static, as API not available)
    final bankPromos = [
      const _BankPromo(
        bank: 'Banco Galicia',
        discount: '20% OFF',
        day: 'Lunes y Martes',
        icon: Icons.account_balance_rounded,
        color: Color(0xFF1565C0),
      ),
      const _BankPromo(
        bank: 'Banco Santander',
        discount: '3 Cuotas Sin Interés',
        day: 'Todos los días',
        icon: Icons.credit_card_rounded,
        color: Color(0xFFCC0000),
      ),
      const _BankPromo(
        bank: 'BBVA',
        discount: '15% OFF',
        day: 'Miércoles y Jueves',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF004A97),
      ),
      const _BankPromo(
        bank: 'HSBC',
        discount: '6 Cuotas Sin Interés',
        day: 'Viernes y Sábado',
        icon: Icons.savings_rounded,
        color: Color(0xFFDB0011),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text('Promociones',
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Icon(Icons.local_offer_rounded,
                      color: theme.colorScheme.primary, size: 24.r),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.withAlpha(26),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Imperdibles'),
                  Tab(text: 'Bancarias'),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Imperdibles tab - featured professionals with deals
                  professionalsAsync.when(
                    loading: () => _PromosShimmer(),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 48.r, color: Colors.red),
                          SizedBox(height: 12.h),
                          Text('Error al cargar promociones',
                              style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                        ],
                      ),
                    ),
                    data: (pros) {
                      if (pros.isEmpty) {
                        return Center(
                          child: Text('No hay promociones disponibles',
                              style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: pros.length,
                        itemBuilder: (_, i) {
                          final pro = pros[i];
                          final discounts = ['30% OFF', '2x1', '25% OFF', '15% OFF', 'GRATIS envío'];
                          final discount = discounts[i % discounts.length];
                          return _PromoCard(
                            title: 'Oferta especial',
                            subtitle: pro.name,
                            tag: discount,
                            professionalId: pro.id,
                            avatarUrl: pro.avatar,
                            rating: pro.ratingAvg,
                          );
                        },
                      );
                    },
                  ),

                  // Bank promotions tab
                  ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: bankPromos.length,
                    itemBuilder: (_, i) => _BankPromoCard(promo: bankPromos[i]),
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

class _BankPromo {
  final String bank;
  final String discount;
  final String day;
  final IconData icon;
  final Color color;

  const _BankPromo({
    required this.bank,
    required this.discount,
    required this.day,
    required this.icon,
    required this.color,
  });
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final int professionalId;
  final String? avatarUrl;
  final double? rating;

  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.professionalId,
    this.avatarUrl,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/specialist/$professionalId'),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((isDark ? 0.2 : 0.06 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withAlpha(204),
                        theme.colorScheme.secondary.withAlpha(153),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundImage:
                            avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                        child: avatarUrl == null
                            ? Icon(Icons.person_rounded, size: 40.r, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style:
                                TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                        SizedBox(height: 3.h),
                        Text(subtitle,
                            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (rating != null)
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 16.r),
                        SizedBox(width: 4.w),
                        Text(rating!.toStringAsFixed(1),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      ],
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

class _BankPromoCard extends StatelessWidget {
  final _BankPromo promo;

  const _BankPromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [
            promo.color.withAlpha((isDark ? 0.3 : 0.9 * 255).round()),
            promo.color.withAlpha((isDark ? 0.15 : 0.7 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: promo.color.withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(promo.icon, color: Colors.white, size: 28.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.bank,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  promo.discount,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  promo.day,
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromosShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        height: 200.h,
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.withAlpha(31),
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}


