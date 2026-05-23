import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/repositories/services_repository.dart';
import '../../../core/data/models/service_model.dart';
import '../../../core/data/repositories/categories_repository.dart';

// ─── Filter State Provider ─────────────────────────────────────────────────
final servicesFilterProvider =
    StateProvider<_ServiceFilter>((ref) => const _ServiceFilter());

class _ServiceFilter {
  final String query;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;

  const _ServiceFilter(
      {this.query = '', this.categoryId, this.minPrice, this.maxPrice});

  _ServiceFilter copyWith(
      {String? query, int? categoryId, double? minPrice, double? maxPrice}) {
    return _ServiceFilter(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

final filteredServicesProvider =
    FutureProvider<List<ServiceModel>>((ref) async {
  final filter = ref.watch(servicesFilterProvider);
  return ref.read(servicesRepositoryProvider).getServices(
        name: filter.query.isEmpty ? null : filter.query,
        categoryId: filter.categoryId,
        minPrice: filter.minPrice,
        maxPrice: filter.maxPrice,
        isActive: true,
      );
});

// ─── Screen ────────────────────────────────────────────────────────────────
class ServicesScreen extends ConsumerStatefulWidget {
  final int? initialCategoryId;

  const ServicesScreen({super.key, this.initialCategoryId});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryId != null) {
      Future.microtask(() {
        ref.read(servicesFilterProvider.notifier).state =
            _ServiceFilter(categoryId: widget.initialCategoryId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filter = ref.watch(servicesFilterProvider);
    final categories = ref.watch(serviceCategoriesProvider);
    final services = ref.watch(filteredServicesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text('Servicios',
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Text(
                    services.asData?.value.length.toString() ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Search ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withAlpha((0.08 * 255).round())),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Icon(Icons.search_rounded,
                          color: theme.colorScheme.primary, size: 20.r),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => ref
                            .read(servicesFilterProvider.notifier)
                            .state = filter.copyWith(query: v),
                        decoration: InputDecoration(
                          hintText: 'Buscar servicio...',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                      ),
                    ),
                    if (filter.query.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(servicesFilterProvider.notifier).state =
                              filter.copyWith(query: '');
                        },
                        icon: Icon(Icons.clear_rounded, size: 18.r),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ─── Category chips ──────────────────────────────────
            categories.when(
              loading: () => SizedBox(height: 40.h),
              error: (_, __) => const SizedBox.shrink(),
              data: (cats) => SizedBox(
                height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: cats.length + 1,
                  itemBuilder: (_, i) {
                    final isAll = i == 0;
                    final cat = isAll ? null : cats[i - 1];
                    final isSelected = isAll
                        ? filter.categoryId == null
                        : filter.categoryId == cat?.id;
                    return GestureDetector(
                      onTap: () {
                        ref.read(servicesFilterProvider.notifier).state =
                            _ServiceFilter(
                                query: filter.query, categoryId: cat?.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark
                                  ? Colors.white10
                                  : Colors.grey.withAlpha((0.1 * 255).round())),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          isAll ? 'Todos' : cat!.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ─── Services List ────────────────────────────────────
            Expanded(
              child: services.when(
                loading: () => _ServicesListShimmer(),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48.r, color: Colors.red),
                      SizedBox(height: 12.h),
                      Text('Error al cargar servicios',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 14.sp)),
                    ],
                  ),
                ),
                data: (svcs) {
                  if (svcs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build_circle_outlined,
                              size: 64.r, color: Colors.grey),
                          SizedBox(height: 16.h),
                          Text('No se encontraron servicios',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14.sp)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: svcs.length,
                    itemBuilder: (_, i) => _ServiceListTile(service: svcs[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  final ServiceModel service;

  const _ServiceListTile({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/services/${service.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha((0.2 * 255).round())
                  : Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primary.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.build_circle_rounded,
                  color: theme.colorScheme.primary, size: 28.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (service.categoryName != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      service.categoryName!,
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (service.description != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      service.description!,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  service.price != null
                      ? '\$${service.price!.toStringAsFixed(0)}'
                      : 'Consultar',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                if (service.durationMinutes != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '${service.durationMinutes} min',
                    style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        height: 80.h,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white10
              : Colors.grey.withAlpha((0.12 * 255).round()),
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    );
  }
}
