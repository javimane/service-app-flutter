import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/repositories/products_repository.dart';
import '../../../core/data/models/product_model.dart';

final productDetailProvider =
    FutureProvider.family<ProductModel?, String>((ref, id) async {
  return ref.read(productsRepositoryProvider).getProductById(id);
});

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedImageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48.r, color: Colors.red),
              SizedBox(height: 12.h),
              Text('Error al cargar producto',
                  style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 12.h),
              TextButton(
                  onPressed: () => context.pop(), child: const Text('Volver')),
            ],
          ),
        ),
        data: (product) {
          if (product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text('Producto no encontrado',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                  SizedBox(height: 12.h),
                  TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Volver')),
                ],
              ),
            );
          }

          final images = product.images.toList();
          images.sort(
              (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));

          final allImageUrls = <String>[];
          if (product.imageUrl != null) allImageUrls.add(product.imageUrl!);
          for (final img in images) {
            if (img.imageUrl != product.imageUrl) {
              allImageUrls.add(img.imageUrl);
            }
          }

          final currentMainImage = _selectedImageUrl ??
              (allImageUrls.isNotEmpty ? allImageUrls.first : null);

          return Column(
            children: [
              // Fixed Images Section
              Stack(
                children: [
                  Container(
                    height: 280.h,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 10.h),
                    color: theme.colorScheme.surface,
                    child: currentMainImage != null
                        ? Image.network(currentMainImage,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                                  color:
                                      theme.colorScheme.primary.withAlpha(31),
                                  child: Icon(Icons.inventory_2_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 80.r),
                                ))
                        : Container(
                            color: theme.colorScheme.primary.withAlpha(31),
                            child: Icon(Icons.inventory_2_rounded,
                                color: theme.colorScheme.primary, size: 80.r),
                          ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10.h,
                    left: 16.w,
                    child: IconButton(
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
                  ),
                ],
              ),
              if (allImageUrls.length > 1)
                Container(
                  height: 80.h,
                  color: theme.colorScheme.surface,
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: allImageUrls.length,
                    separatorBuilder: (context, index) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final imgUrl = allImageUrls[index];
                      final isSelected = currentMainImage == imgUrl;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageUrl = imgUrl;
                          });
                        },
                        child: Container(
                          width: 60.h,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Scrollable Details Section
              Expanded(
                child: SingleChildScrollView(
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.secondary.withAlpha(31),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withAlpha(31),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(product.brand!,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11.sp)),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(product.name,
                            style: TextStyle(
                                fontSize: 24.sp, fontWeight: FontWeight.w900)),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: product.stock! > 0
                                      ? Colors.green.withAlpha(31)
                                      : Colors.red.withAlpha(31),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  product.stock! > 0
                                      ? 'Stock: ${product.stock}'
                                      : 'Sin stock',
                                  style: TextStyle(
                                    color: product.stock! > 0
                                        ? Colors.green
                                        : Colors.red,
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
                              style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold)),
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
                              style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: () {
                              if (product.professionalId != null) {
                                context.push(
                                    '/specialist/${product.professionalId}');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black.withAlpha(15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22.r,
                                    backgroundColor:
                                        theme.colorScheme.primary.withAlpha(51),
                                    child: Text(
                                      product.professionalName![0]
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.professionalName!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp)),
                                      Text('Ver perfil →',
                                          style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontSize: 12.sp)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(Icons.chevron_right_rounded,
                                      color: Colors.grey, size: 22.r),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (product.professionalId != null) {
                                  final msg = 'Hola, qué tal, pregunto por el producto: ${product.name}';
                                  final encodedMsg = Uri.encodeComponent(msg);
                                  context.push(
                                      '/chat/${product.professionalId}?initialMessage=$encodedMsg');
                                }
                              },
                              icon:
                                  Icon(Icons.shopping_cart_rounded, size: 16.r),
                              label: Text('Contactar vendedor',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 16.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 40.h),
                      ],
                    ),
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
