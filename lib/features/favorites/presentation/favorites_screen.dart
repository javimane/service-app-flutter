import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/repositories/favorites_repository.dart';
import '../../../core/data/models/misc_models.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text('Favoritos',
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Icon(Icons.favorite_rounded, color: theme.colorScheme.primary, size: 24.r),
                ],
              ),
            ),
            Expanded(
              child: favoritesAsync.when(
                loading: () => _FavoritesShimmer(),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 64.r, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text('Error al cargar favoritos',
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () => ref.invalidate(favoritesProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
                data: (favorites) {
                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 80.r, color: Colors.grey.withAlpha(128)),
                          SizedBox(height: 20.h),
                          Text(
                            'Sin favoritos aún',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Guardá tus profesionales favoritos\npara acceder rápido',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark ? Colors.white54 : Colors.black38,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/home'),
                            icon: Icon(Icons.explore_rounded, size: 18.r),
                            label: const Text('Explorar profesionales'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    itemCount: favorites.length,
                    itemBuilder: (_, i) => _FavoriteCard(
                      favorite: favorites[i],
                      onRemove: () async {
                        await ref
                            .read(favoritesRepositoryProvider)
                            .removeFavorite(favorites[i].professionalId);
                        ref.invalidate(favoritesProvider);
                      },
                    ),
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

class _FavoriteCard extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback onRemove;

  const _FavoriteCard({required this.favorite, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = favorite.professionalName ?? 'Profesional #${favorite.professionalId}';

    return GestureDetector(
      onTap: () => context.push('/specialist/${favorite.professionalId}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((isDark ? 0.2 : 0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: theme.colorScheme.primary.withAlpha(38),
              backgroundImage: favorite.professionalAvatar != null
                  ? NetworkImage(favorite.professionalAvatar!)
                  : null,
              child: favorite.professionalAvatar == null
                  ? Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (favorite.professionalBio != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      favorite.professionalBio!,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (favorite.rating != null) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 14.r),
                        SizedBox(width: 4.w),
                        Text(
                          favorite.rating!.toStringAsFixed(1),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_rounded, color: Colors.red, size: 22.r),
                  onPressed: onRemove,
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20.r),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        height: 80.h,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.withAlpha(31),
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}


