import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/repositories/products_repository.dart';
import 'widgets/product_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final productsAsyncValue = ref.watch(productsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Text('Productos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, size: 24.r),
                  onPressed: () {},
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(70.h),
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withAlpha(10),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar productos...',
                              hintStyle: TextStyle(fontSize: 14.sp),
                              prefixIcon: Icon(Icons.search, size: 20.r),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.filter_list, color: Colors.white, size: 20.r),
                          onPressed: () {
                            // TODO: Show filters modal
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            productsAsyncValue.when(
              data: (products) {
                if (products.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('No hay productos disponibles.'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 0.65, // Relación de aspecto para la tarjeta
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(
                          product: products[index],
                          isListMode: false,
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Text('Error al cargar productos: \$error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

