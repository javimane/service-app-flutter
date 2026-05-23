import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/repositories/services_repository.dart';
import '../../../core/data/models/service_model.dart';

final serviceDetailProvider = FutureProvider.family<ServiceModel?, int>((ref, id) async {
  return ref.read(servicesRepositoryProvider).getServiceById(id);
});

class ServiceDetailScreen extends ConsumerWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final serviceAsync = ref.watch(serviceDetailProvider(serviceId));

    return Scaffold(
      body: serviceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48.r, color: Colors.red),
              SizedBox(height: 12.h),
              Text('Error al cargar servicio', style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 12.h),
              TextButton(onPressed: () => context.pop(), child: const Text('Volver')),
            ],
          ),
        ),
        data: (service) {
          if (service == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_circle_outlined, size: 64.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text('Servicio no encontrado', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                  SizedBox(height: 12.h),
                  TextButton(onPressed: () => context.pop(), child: const Text('Volver')),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              // Hero section
              SliverAppBar(
                expandedHeight: 220.h,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withAlpha(178),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.build_circle_rounded,
                            size: 160.r,
                            color: Colors.white.withAlpha(26),
                          ),
                        ),
                        Center(
                          child: Icon(Icons.build_circle_rounded,
                              color: Colors.white, size: 80.r),
                        ),
                      ],
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
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20.r),
                  ),
                  onPressed: () => context.pop(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      if (service.categoryName != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withAlpha(31),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            service.categoryName!,
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),

                      SizedBox(height: 12.h),

                      Text(
                        service.name,
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
                      ),

                      SizedBox(height: 16.h),

                      // Stats row
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.attach_money_rounded,
                            label: service.price != null
                                ? '\$${service.price!.toStringAsFixed(0)}'
                                : 'Consultar',
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          if (service.durationMinutes != null)
                            _StatChip(
                              icon: Icons.access_time_rounded,
                              label: '${service.durationMinutes} min',
                              color: theme.colorScheme.secondary,
                            ),
                          SizedBox(width: 8.w),
                          _StatChip(
                            icon: Icons.circle,
                            label: service.isActive ? 'Disponible' : 'No disponible',
                            color: service.isActive ? Colors.green : Colors.red,
                          ),
                        ],
                      ),

                      if (service.description != null) ...[
                        SizedBox(height: 24.h),
                        Text(
                          'Descripción',
                          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          service.description!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ],

                      if (service.professionalName != null) ...[
                        SizedBox(height: 24.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black.withAlpha(15),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24.r,
                                backgroundColor: theme.colorScheme.primary.withAlpha(51),
                                child: Text(
                                  service.professionalName![0].toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.professionalName!,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                  ),
                                  Text(
                                    'Profesional',
                                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (service.rating != null)
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded, color: Colors.amber, size: 16.r),
                                    SizedBox(width: 4.w),
                                    Text(
                                      service.rating!.toStringAsFixed(1),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 32.h),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (service.professionalId != null) {
                              context.push('/specialist/${service.professionalId}');
                            }
                          },
                          icon: Icon(Icons.send_rounded, size: 18.r),
                          label: Text(
                            'CONTACTAR PROFESIONAL',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.r),
          SizedBox(width: 6.w),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.sp)),
        ],
      ),
    );
  }
}

