import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Productos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.filter_list, size: 24.r), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5, // Simulación de 5 productos
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
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
            child: Row(
              children: [
                // Imagen del producto simulada
                ClipRRect(
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(16.r)),
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    color: theme.colorScheme.secondary.withAlpha(51),
                    child: Icon(Icons.inventory_2_outlined,
                        color: theme.colorScheme.secondary, size: 40.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Producto de Ejemplo ${index + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Marca genérica • Stock: 10',
                          style: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withAlpha(153),
                              fontSize: 12.sp),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$2,500.00',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Icon(Icons.add_shopping_cart,
                                  color: Colors.white, size: 16.r),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

