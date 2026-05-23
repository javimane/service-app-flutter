import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/repositories/professionals_repository.dart';
import '../../permissions/request_permissions_button.dart';
import '../../../core/data/repositories/services_repository.dart';
import '../../../core/data/repositories/products_repository.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  final List<_BannerData> _banners = [
    const _BannerData(
      title: 'Encontrá tu\nProfesional ideal',
      subtitle: 'Electricistas, plomeros, diseñadores y más',
      gradient: [Color(0xFFFF7F50), Color(0xFFFF4500)],
      icon: Icons.handyman_rounded,
    ),
    const _BannerData(
      title: 'Promociones\nExclusivas',
      subtitle: 'Descuentos bancarios y ofertas de temporada',
      gradient: [Color(0xFF2196F3), Color(0xFF1565C0)],
      icon: Icons.local_offer_rounded,
    ),
    const _BannerData(
      title: 'Productos\ncerca tuyo',
      subtitle: 'Materiales y herramientas al mejor precio',
      gradient: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
      icon: Icons.shopping_bag_rounded,
    ),
    const _BannerData(
      title: 'Reels de\nProfesionales',
      subtitle: 'Mirá los mejores trabajos en video',
      gradient: [Color(0xFF00BCD4), Color(0xFF006064)],
      icon: Icons.play_circle_fill_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentBanner + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final professionals = ref.watch(professionalsProvider);
    final services = ref.watch(servicesProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.search_rounded,
                              color: Colors.white, size: 20.r),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'SERCIO',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.push('/messages'),
                          icon: Icon(Icons.chat_bubble_outline_rounded,
                              size: 22.r),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.notifications_none_rounded,
                                  size: 22.r),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 8.r,
                                height: 8.r,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 4.w),
                        CircleAvatar(
                          radius: 18.r,
                          backgroundImage: const NetworkImage(
                              'https://i.pravatar.cc/100?img=11'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Banner Carousel ───────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 190.h,
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: _banners.length,
                      onPageChanged: (i) => setState(() => _currentBanner = i),
                      itemBuilder: (context, index) {
                        final banner = _banners[index];
                        return _AnimatedBanner(banner: banner);
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _banners.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentBanner == i ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentBanner == i
                              ? theme.colorScheme.primary
                              : Colors.grey.withAlpha(76),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Button to request runtime permissions
                  const Center(child: RequestPermissionsButton()),
                ],
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            // ─── Search Bar ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color:
                          isDark ? Colors.white10 : Colors.black.withAlpha(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Icon(Icons.search_rounded,
                            color: theme.colorScheme.primary, size: 22.r),
                      ),
                      Expanded(
                        child: TextField(
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            hintText: 'Busca servicios, profesionales...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 16.h),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text('Buscar',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),

            // ─── Quick Access Icons ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickAccessItem(
                        icon: Icons.build_rounded,
                        label: 'Servicios',
                        onTap: () => context.push('/services')),
                    _QuickAccessItem(
                        icon: Icons.category_rounded,
                        label: 'Categorías',
                        onTap: () => context.push('/categories')),
                    _QuickAccessItem(
                        icon: Icons.map_rounded,
                        label: 'Mapa',
                        onTap: () => context.push('/map')),
                    _QuickAccessItem(
                        icon: Icons.local_offer_rounded,
                        label: 'Promos',
                        onTap: () => context.push('/promotions')),
                    _QuickAccessItem(
                        icon: Icons.favorite_rounded,
                        label: 'Favoritos',
                        onTap: () => context.push('/favorites')),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),

            // ─── Featured Professionals ────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Profesionales Destacados',
                onSeeAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200.h,
                child: professionals.when(
                  loading: () =>
                      _HorizontalShimmer(count: 3, width: 160.w, height: 200.h),
                  error: (_, __) =>
                      _HorizontalShimmer(count: 3, width: 160.w, height: 200.h),
                  data: (pros) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: pros.length,
                    itemBuilder: (context, i) =>
                        _ProfessionalCard(professional: pros[i]),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),

            // ─── Services Near You ─────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Servicios Cerca de Ti',
                onSeeAll: () => context.push('/services'),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 175.h,
                child: services.when(
                  loading: () =>
                      _HorizontalShimmer(count: 3, width: 160.w, height: 175.h),
                  error: (_, __) =>
                      _HorizontalShimmer(count: 3, width: 160.w, height: 175.h),
                  data: (svcs) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: svcs.length,
                    itemBuilder: (context, i) => _ServiceCard(service: svcs[i]),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),

            // ─── Products ─────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Productos de la App',
                onSeeAll: () => context.push('/products'),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210.h,
                child: products.when(
                  loading: () =>
                      _HorizontalShimmer(count: 3, width: 150.w, height: 210.h),
                  error: (_, __) =>
                      _HorizontalShimmer(count: 3, width: 150.w, height: 210.h),
                  data: (prods) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: prods.length,
                    itemBuilder: (context, i) =>
                        _ProductCard(product: prods[i]),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),

            // ─── Reels CTA ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: GestureDetector(
                  onTap: () => context.push('/reels'),
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Opacity(
                              opacity: 0.3,
                              child: Image.network(
                                'https://images.unsplash.com/photo-1542044896530-05d85be9b11a?w=800&q=80',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.r),
                          child: Row(
                            children: [
                              Container(
                                width: 48.r,
                                height: 48.r,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(51),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 28.r),
                              ),
                              SizedBox(width: 16.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Reels y Trabajos',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                  Text(
                                    'Mirá los mejores trabajos',
                                    style: TextStyle(
                                        color: Colors.white60, fontSize: 13.sp),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 22.r),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
}

class _AnimatedBanner extends StatelessWidget {
  final _BannerData banner;

  const _AnimatedBanner({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            colors: banner.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 160.r,
                height: 160.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(20),
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: -40,
              child: Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(15),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          banner.subtitle,
                          style: TextStyle(
                            color: Colors.white.withAlpha(217),
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Text(
                            'Explorar →',
                            style: TextStyle(
                              color: banner.gradient.first,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    banner.icon,
                    color: Colors.white.withAlpha(230),
                    size: 72.r,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Ver todo',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(31),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24.r),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final dynamic professional;

  const _ProfessionalCard({required this.professional});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = professional.name as String;
    final avatar = professional.avatar as String;
    final rating = professional.ratingAvg ?? 5.0;

    return GestureDetector(
      onTap: () => context.push('/specialist/${professional.id}'),
      child: Container(
        width: 155.w,
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withAlpha((isDark ? 0.3 : 0.06 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36.r,
              backgroundImage: NetworkImage(avatar),
            ),
            SizedBox(height: 10.h),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              professional.bio ?? 'Profesional',
              style: TextStyle(color: Colors.grey, fontSize: 11.sp),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 14.r),
                SizedBox(width: 4.w),
                Text(
                  rating.toStringAsFixed(1),
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final dynamic service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/services/${service.id}'),
      child: Container(
        width: 155.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withAlpha((isDark ? 0.3 : 0.06 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                color: theme.colorScheme.primary.withAlpha(38),
              ),
              child: Center(
                child: Icon(Icons.build_circle_rounded,
                    color: theme.colorScheme.primary, size: 40.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name as String,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        service.price != null
                            ? '\$${(service.price as double).toStringAsFixed(0)}'
                            : 'Consultar',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
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

class _ProductCard extends StatelessWidget {
  final dynamic product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        width: 150.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withAlpha((isDark ? 0.3 : 0.06 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl as String,
                      height: 110.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 110.h,
                        color: Colors.grey.withAlpha(51),
                        child: Icon(Icons.image_rounded,
                            size: 40.r, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 110.h,
                      color: Colors.grey.withAlpha(51),
                      child: Icon(Icons.inventory_2_rounded,
                          color: theme.colorScheme.primary, size: 40.r),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name as String,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.price != null
                        ? '\$${(product.price as double).toStringAsFixed(2)}'
                        : 'Consultar',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
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

class _HorizontalShimmer extends StatelessWidget {
  final int count;
  final double width;
  final double height;

  const _HorizontalShimmer(
      {required this.count, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: count,
      itemBuilder: (_, __) => Container(
        width: width,
        height: height,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.withAlpha(38),
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}
