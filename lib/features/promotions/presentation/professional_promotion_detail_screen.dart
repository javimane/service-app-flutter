import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/data/repositories/professional_promotions_repository.dart';

class ProfessionalPromotionDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ProfessionalPromotionDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ProfessionalPromotionDetailScreen> createState() => _ProfessionalPromotionDetailScreenState();
}

class _ProfessionalPromotionDetailScreenState extends ConsumerState<ProfessionalPromotionDetailScreen> {
  Map<String, dynamic>? _promo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPromo();
  }

  Future<void> _loadPromo() async {
    try {
      final repo = ref.read(professionalPromotionsRepositoryProvider);
      final promo = await repo.getById(widget.id);
      if (mounted) {
        setState(() {
          _promo = promo as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar la promoción: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _promo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.r, color: Colors.red),
              SizedBox(height: 16.h),
              Text(_error ?? 'Promoción no encontrada'),
              TextButton(
                onPressed: _loadPromo,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _promo!;
    final professional = p['Professional'] as Map<String, dynamic>?;
    final profile = professional?['Profile'] as Map<String, dynamic>?;
    final companyName = (professional?['Company'] as List<dynamic>?)?.isNotEmpty == true
        ? professional!['Company'][0]['name']
        : 'Profesional';
        
    final title = p['title'] ?? 'Promoción especial';
    final description = p['description'] ?? '';
    final imageUrl = p['image_url'] ?? 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&q=80&w=600';
    final discountType = p['discount_type'] ?? '';
    final discountValue = p['discount_value'] ?? '';

    String badgeText = '';
    if (discountType.toString().toLowerCase() == 'percentage') {
      badgeText = '$discountValue% OFF';
    } else if (discountType.toString().toLowerCase() == 'fixed') {
      badgeText = '\$$discountValue OFF';
    } else {
      badgeText = discountValue.toString();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: const Icon(Icons.share, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Share.share('Mirá esta promoción: $title en $companyName. Encontrala en nuestra app.');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 300.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 300.h,
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 300.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withAlpha(153), Colors.transparent, Colors.black.withAlpha(204)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                if (badgeText.isNotEmpty)
                  Positioned(
                    bottom: 20.h,
                    right: 20.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(102),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
                      ),
                    ),
                  ),
              ],
            ),
            
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Professional Card
                  GestureDetector(
                    onTap: () {
                      if (professional != null && professional['id'] != null) {
                        context.push('/specialist/${professional['id']}');
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24.r,
                            backgroundImage: profile?['avatar_url'] != null ? NetworkImage(profile!['avatar_url']) : null,
                            child: profile?['avatar_url'] == null ? const Icon(Icons.store) : null,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ofrecido por',
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                ),
                                Text(
                                  companyName,
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  Text('Detalles', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text(
                    description.isNotEmpty ? description : 'Aprovechá esta promoción exclusiva.',
                    style: TextStyle(fontSize: 15.sp, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (professional != null && professional['id'] != null) {
                          context.push('/specialist/${professional['id']}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Ver Profesional', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
