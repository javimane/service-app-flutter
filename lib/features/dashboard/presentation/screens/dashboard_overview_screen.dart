import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/models/professional_model.dart';
import '../../../../core/data/repositories/professionals_repository.dart';
import '../../../../core/data/repositories/professional_proposals_repository.dart';
import '../../../../core/data/repositories/reels_repository.dart';
import '../../../../core/data/repositories/professional_videos_repository.dart';

class DashboardOverviewScreen extends ConsumerStatefulWidget {
  const DashboardOverviewScreen({super.key});

  @override
  ConsumerState<DashboardOverviewScreen> createState() =>
      _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState
    extends ConsumerState<DashboardOverviewScreen> {
  bool _loading = true;
  ProfessionalModel? _professional;
  int _proposalsCount = 0;
  Map<String, dynamic>? _reelsStats;
  List<dynamic> _videos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final profRepo = ref.read(professionalsRepositoryProvider);
      final propRepo = ref.read(professionalProposalsRepositoryProvider);
      final reelsRepo = ref.read(reelsRepositoryProvider);
      final videosRepo = ref.read(professionalVideosRepositoryProvider);

      final prof = await profRepo.getMyProfessional();
      _professional = prof;

      if (prof != null) {
        final results = await Future.wait([
          propRepo.getAcceptedCount(),
          reelsRepo.countViewsAndLikes(prof.id),
          videosRepo.findAllByProfessionalId(prof.id),
        ]);

        _proposalsCount =
            (results[0] is Map ? results[0]['count'] : results[0]) as int? ?? 0;
        _reelsStats = results[1] as Map<String, dynamic>?;
        _videos = (results[2] as List<dynamic>?) ?? [];
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final views = _professional?.profileViews ?? 0;
    final reelViews = _reelsStats?['total_views'] ?? 0;
    final reelLikes = _reelsStats?['total_likes'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // ── Welcome ────────────────────────────────────────────────────────
          Text(
            'Bienvenido, ${_professional?.name ?? 'Profesional'}.',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Aquí tienes un resumen de tu actividad reciente.',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
          SizedBox(height: 24.h),

          // ── Stats Grid ──────────────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 1.2,
            children: [
              _StatCard(
                title: 'VISTAS DE PERFIL',
                value: views.toString(),
                icon: Icons.visibility_rounded,
                color: Colors.blueAccent,
                isDark: isDark,
              ),
              _StatCard(
                title: 'TRABAJOS ACEPTADOS',
                value: _proposalsCount.toString(),
                icon: Icons.check_circle_rounded,
                color: Colors.green,
                isDark: isDark,
              ),
              _StatCard(
                title: 'REELS VISTAS',
                value: reelViews > 1000
                    ? '${(reelViews / 1000).toStringAsFixed(1)}K'
                    : reelViews.toString(),
                icon: Icons.play_circle_fill_rounded,
                color: Colors.purpleAccent,
                isDark: isDark,
              ),
              _StatCard(
                title: 'REELS LIKES',
                value: reelLikes > 1000
                    ? '${(reelLikes / 1000).toStringAsFixed(1)}K'
                    : reelLikes.toString(),
                icon: Icons.favorite_rounded,
                color: Colors.redAccent,
                isDark: isDark,
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // ── Video Performance ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance de Videos',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push('/dashboard/reels'),
                child: Text('VER TODOS',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: primary)),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          if (_videos.isEmpty)
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
              ),
              child: Center(
                child: Text('No hay videos subidos aún.',
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
              ),
            )
          else
            SizedBox(
              height: 180.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  final video = _videos[index];
                  final thumbUrl = video['thumbnail_url'];
                  final title = video['title'] ?? 'Sin título';
                  final vCount = video['views_count'] ?? 0;
                  final lCount = video['likes'] ?? 0;
                  final active = video['activate'] == true;

                  return Container(
                    width: 140.w,
                    margin: EdgeInsets.only(right: 16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withAlpha(13)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 30 : 5),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumb
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (thumbUrl != null && thumbUrl.isNotEmpty)
                                Image.network(thumbUrl, fit: BoxFit.cover)
                              else
                                Container(
                                  color: primary.withAlpha(20),
                                  child: Icon(Icons.videocam_rounded,
                                      color: primary, size: 32.r),
                                ),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(100),
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.play_arrow_rounded,
                                      color: Colors.white, size: 20.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Info
                        Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(Icons.visibility_rounded,
                                      size: 10.r, color: Colors.grey),
                                  SizedBox(width: 4.w),
                                  Text('$vCount',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.grey)),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.favorite_rounded,
                                      size: 10.r, color: Colors.grey),
                                  SizedBox(width: 4.w),
                                  Text('$lCount',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.grey)),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.green.withAlpha(20)
                                      : Colors.orange.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(active ? 'Activo' : 'Procesando',
                                    style: TextStyle(
                                        color:
                                            active ? Colors.green : Colors.orange,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 32.h),

          // ── Quick Actions ──────────────────────────────────────────────────
          Text(
            'Acciones Rápidas',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Column(
            children: [
              _ActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Crear Presupuesto',
                  onTap: () => context.push('/dashboard/proposals')),
              _ActionTile(
                  icon: Icons.movie_creation_rounded,
                  title: 'Gestionar Reels',
                  onTap: () => context.push('/dashboard/reels')),
              _ActionTile(
                  icon: Icons.person_rounded,
                  title: 'Editar Perfil',
                  onTap: () => context.push('/dashboard/profile')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 5),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                    color: color.withAlpha(20), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16.r),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(title,
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20.r),
          ],
        ),
      ),
    );
  }
}
