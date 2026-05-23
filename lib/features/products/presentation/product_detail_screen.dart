import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/repositories/products_repository.dart';
import '../../../core/data/models/product_model.dart';

final productDetailProvider = FutureProvider.family<ProductModel?, int>((ref, id) async {
  return ref.read(productsRepositoryProvider).getProductById(id);
});

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48.r, color: Colors.red),
              SizedBox(height: 12.h),
              Text('Error al cargar producto', style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 12.h),
              TextButton(onPressed: () => context.pop(), child: const Text('Volver')),
            ],
          ),
        ),
        data: (product) {
          if (product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text('Producto no encontrado', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                  SizedBox(height: 12.h),
                  TextButton(onPressed: () => context.pop(), child: const Text('Volver')),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.h,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: product.imageUrl != null
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: theme.colorScheme.primary.withAlpha(31),
                            child: Icon(Icons.inventory_2_rounded,
                                color: theme.colorScheme.primary, size: 80.r),
                          ))
                      : Container(
                          color: theme.colorScheme.primary.withAlpha(31),
                          child: Icon(Icons.inventory_2_rounded,
                              color: theme.colorScheme.primary, size: 80.r),
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
                      // Category & Brand
                      Row(
                        children: [
                          if (product.categoryName != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withAlpha(31),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(product.categoryName!,
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          if (product.brand != null) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(31),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(product.brand!,
                                  style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(product.name,
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900)),
                      SizedBox(height: 16.h),
                      // Price
                      Row(
                        children: [
                          Text(
                            product.price != null
                                ? '\$${product.price!.toStringAsFixed(2)}'
                                : 'Consultar precio',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          if (product.stock != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: product.stock! > 0
                                    ? Colors.green.withAlpha(31)
                                    : Colors.red.withAlpha(31),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                product.stock! > 0 ? 'Stock: ${product.stock}' : 'Sin stock',
                                style: TextStyle(
                                  color: product.stock! > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (product.description != null) ...[
                        SizedBox(height: 24.h),
                        Text('Descripción',
                            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ],
                      if (product.professionalName != null) ...[
                        SizedBox(height: 24.h),
                        Text('Vendedor',
                            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: () {
                            if (product.professionalId != null) {
                              context.push('/specialist/${product.professionalId}');
                            }
                          },
                          child: Container(
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
                                  radius: 22.r,
                                  backgroundColor: theme.colorScheme.primary.withAlpha(51),
                                  child: Text(
                                    product.professionalName![0].toUpperCase(),
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.professionalName!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                    Text('Ver perfil →',
                                        style: TextStyle(
                                            color: theme.colorScheme.primary, fontSize: 12.sp)),
                                  ],
                                ),
                                const Spacer(),
                                Icon(Icons.chevron_right_rounded,
                                    color: Colors.grey, size: 22.r),
                              ],
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (product.professionalId != null) {
                              context.push('/specialist/${product.professionalId}');
                            }
                          },
                          icon: Icon(Icons.shopping_cart_rounded, size: 18.r),
                          label: Text('CONTACTAR VENDEDOR',
                              style:
                                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
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

