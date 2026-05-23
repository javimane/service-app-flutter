import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Datos simulados estructurados para el diseño
    final categories = [
      {'icon': Icons.build_outlined, 'name': 'Construcción'},
      {'icon': Icons.cleaning_services_outlined, 'name': 'Limpieza'},
      {'icon': Icons.bolt_outlined, 'name': 'Electricidad'},
      {'icon': Icons.water_drop_outlined, 'name': 'Plomería'},
      {'icon': Icons.format_paint_outlined, 'name': 'Pintura'},
      {'icon': Icons.local_shipping_outlined, 'name': 'Fletes'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GridView.builder(
          padding: EdgeInsets.only(top: 16.h, bottom: 100.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20.r),
                border:
                    Border.all(color: isDark ? Colors.white10 : Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.transparent
                        : Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(26),
                        shape: BoxShape.circle),
                    child: Icon(category['icon'] as IconData,
                        color: theme.colorScheme.primary, size: 32.r),
                  ),
                  SizedBox(height: 12.h),
                  Text(category['name'] as String,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14.sp)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

