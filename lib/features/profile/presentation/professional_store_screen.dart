import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/repositories/professionals_repository.dart';
import '../../../core/data/repositories/services_repository.dart';
import '../../../core/data/repositories/products_repository.dart';
import '../../../core/data/repositories/reviews_repository.dart';
// removed unused import

final professionalDetailProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  return ref.read(professionalsRepositoryProvider).getProfessionalDetail(id);
});

class ProfessionalStoreScreen extends ConsumerStatefulWidget {
  final int professionalId;

  const ProfessionalStoreScreen({super.key, required this.professionalId});

  @override
  ConsumerState<ProfessionalStoreScreen> createState() =>
      _ProfessionalStoreScreenState();
}

class _ProfessionalStoreScreenState
    extends ConsumerState<ProfessionalStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final professionalAsync =
        ref.watch(professionalDetailProvider(widget.professionalId));
    final servicesAsync = ref.watch(
      FutureProvider.family<dynamic, int>(
        (ref, id) =>
            ref.read(servicesRepositoryProvider).getServicesByProfessional(id),
      )(widget.professionalId),
    );
    final productsAsync = ref.watch(
      FutureProvider.family<dynamic, int>(
        (ref, id) =>
            ref.read(productsRepositoryProvider).getProductsByProfessional(id),
      )(widget.professionalId),
    );
    final reviewsAsync = ref.watch(
      FutureProvider.family<dynamic, int>(
        (ref, id) =>
            ref.read(reviewsRepositoryProvider).getReviewsByProfessional(id),
      )(widget.professionalId),
    );

    return Scaffold(
      body: professionalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48.r, color: Colors.red),
              SizedBox(height: 12.h),
              TextButton(
                  onPressed: () => context.pop(), child: const Text('Volver')),
            ],
          ),
        ),
        data: (data) {
          final profile = data?['Profile'] as Map<String, dynamic>?;
          final name = profile?['display_name'] as String? ?? 'Profesional';
          final avatarUrl = profile?['avatar_url'] as String?;
          final rating = (data?['rating_avg'] as num?)?.toDouble() ?? 0.0;
          // final bio not used currently

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 280.h,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A1A2E),
                          theme.colorScheme.primary.withAlpha(204),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40.h),
                          CircleAvatar(
                            radius: 50.r,
                            backgroundColor:
                                theme.colorScheme.primary.withAlpha(76),
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? Text(
                                    name[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 18.r),
                              SizedBox(width: 4.w),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20.r),
                  ),
                  onPressed: () => context.pop(),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48.h),
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13.sp),
                      indicatorColor: theme.colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Servicios'),
                        Tab(text: 'Productos'),
                        Tab(text: 'Reseñas'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // Services tab
                servicesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const _EmptyTab(
                    icon: Icons.build_circle_outlined,
                    message: 'No hay servicios disponibles',
                  ),
                  data: (svcs) {
                    final services = svcs as List;
                    if (services.isEmpty) {
                      return const _EmptyTab(
                        icon: Icons.build_circle_outlined,
                        message: 'Este profesional no tiene servicios',
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: services.length,
                      itemBuilder: (_, i) {
                        final svc = services[i];
                        return _StoreServiceItem(service: svc);
                      },
                    );
                  },
                ),

                // Products tab
                productsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const _EmptyTab(
                    icon: Icons.inventory_2_outlined,
                    message: 'No hay productos disponibles',
                  ),
                  data: (prods) {
                    final products = prods as List;
                    if (products.isEmpty) {
                      return const _EmptyTab(
                        icon: Icons.inventory_2_outlined,
                        message: 'Este profesional no tiene productos',
                      );
                    }
                    return GridView.builder(
                      padding: EdgeInsets.all(16.r),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        final prod = products[i];
                        return _StoreProductItem(product: prod);
                      },
                    );
                  },
                ),

                // Reviews tab
                reviewsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const _EmptyTab(
                    icon: Icons.rate_review_outlined,
                    message: 'No hay reseñas disponibles',
                  ),
                  data: (revs) {
                    final reviews = revs as List;
                    if (reviews.isEmpty) {
                      return const _EmptyTab(
                        icon: Icons.rate_review_outlined,
                        message: 'Este profesional no tiene reseñas aún',
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: reviews.length,
                      itemBuilder: (_, i) {
                        final rev = reviews[i];
                        return _ReviewItem(review: rev);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyTab({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56.r, color: Colors.grey),
          SizedBox(height: 12.h),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
        ],
      ),
    );
  }
}

class _StoreServiceItem extends StatelessWidget {
  final dynamic service;

  const _StoreServiceItem({required this.service});

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
          color: isDark ? Colors.white10 : Colors.black.withAlpha(15),
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
            child: Icon(Icons.build_rounded,
                color: theme.colorScheme.primary, size: 20.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name as String? ?? 'Servicio',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.sp)),
                if (service.description != null)
                  Text(service.description as String,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            service.price != null
                ? '\$${(service.price as double).toStringAsFixed(0)}'
                : 'Consultar',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreProductItem extends StatelessWidget {
  final dynamic product;

  const _StoreProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white10
                : Colors.black.withAlpha(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              child: product.imageUrl != null
                  ? Image.network(product.imageUrl as String,
                      height: 110.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                            height: 110.h,
                            color: theme.colorScheme.primary.withAlpha(26),
                            child: Icon(Icons.inventory_2_rounded,
                                color: theme.colorScheme.primary, size: 36.r),
                          ))
                  : Container(
                      height: 110.h,
                      color: theme.colorScheme.primary.withAlpha(26),
                      child: Center(
                        child: Icon(Icons.inventory_2_rounded,
                            color: theme.colorScheme.primary, size: 36.r),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name as String? ?? 'Producto',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Text(
                    product.price != null
                        ? '\$${(product.price as double).toStringAsFixed(0)}'
                        : 'Consultar',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
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

class _ReviewItem extends StatelessWidget {
  final dynamic review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rating = (review.rating as double?) ?? 5.0;
    final name = review.reviewerName as String? ?? 'Usuario';
    final comment = review.comment as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: theme.colorScheme.primary.withAlpha(51),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 10.w),
              Text(name,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    color: i < rating.round()
                        ? Colors.amber
                        : Colors.grey.withAlpha(76),
                    size: 16.r,
                  ),
                ),
              ),
            ],
          ),
          if (comment != null) ...[
            SizedBox(height: 10.h),
            Text(
              comment,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
