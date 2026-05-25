import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/models/product_model.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isListMode;

  const ProductCard({
    super.key,
    required this.product,
    this.isListMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Obtener la imagen principal
    final images = product.images;
    images.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
    final primaryImage = images.isNotEmpty
        ? images.first.imageUrl
        : (product.imageUrl ??
            'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?auto=format&fit=crop&w=800&q=80');

    // Obtener información de vendedores
    final sellers = product.professionalProducts;
    final firstSeller = sellers.isNotEmpty ? sellers.first : null;

    final displayPrice = product.price ?? firstSeller?.price ?? 0.0;
    final displayDiscount = firstSeller?.percentDiscount ?? 0;
    
    // Asumiendo que el modelo original en web usaba original_price, si no, se calcula
    final displayOriginalPrice = displayDiscount > 0 
        ? displayPrice / (1 - (displayDiscount / 100))
        : null;

    final currencyCode = product.professionalProducts.isNotEmpty 
        ? product.professionalProducts.first.currencyCode ?? 'ARG' 
        : 'ARG';

    String sellerName = 'Varios vendedores';
    if (sellers.length == 1) {
      sellerName = firstSeller?.professional?.companies.isNotEmpty == true
          ? firstSeller!.professional!.companies.first.name ?? 'Vendedor'
          : 'Vendedor';
    } else if (sellers.isEmpty) {
      sellerName = 'Vendedor Desconocido';
    } else {
      sellerName = 'Varios vendedores (${sellers.length})';
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'es_AR',
      symbol: currencyCode == 'USD' ? 'USD \$' : '\$',
      decimalDigits: 2,
    );

    return InkWell(
      onTap: () {
        context.push('/products/${product.id}');
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: isListMode ? 16.h : 0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.transparent : Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isListMode ? _buildListMode(context, primaryImage, sellerName, displayPrice, displayOriginalPrice, displayDiscount) : _buildGridMode(context, primaryImage, sellerName, displayPrice, displayOriginalPrice, displayDiscount),
      ),
    );
  }

  Widget _buildGridMode(BuildContext context, String primaryImage, String sellerName, double price, double? originalPrice, int discount) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.network(
                  primaryImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.secondary.withAlpha(51),
                    child: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.secondary, size: 40.r),
                  ),
                ),
              ),
              if (product.isForeign == true)
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(200),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public, color: Colors.white, size: 10.r),
                        SizedBox(width: 4.w),
                        Text('EXTERNO', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              if (discount > 0)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(200),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('-$discount%', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(8.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(153), fontSize: 10.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      product.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (originalPrice != null)
                      Text(
                        formatCurrency.format(originalPrice),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                          fontSize: 10.sp,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Row(
                      children: [
                        Text(
                          formatCurrency.format(price),
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14.sp),
                        ),
                        if (discount > 0) ...[
                          SizedBox(width: 4.w),
                          Text(
                            '$discount% OFF',
                            style: TextStyle(color: Colors.green, fontSize: 10.sp, fontWeight: FontWeight.bold),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListMode(BuildContext context, String primaryImage, String sellerName, double price, double? originalPrice, int discount) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Row(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
              child: Image.network(
                primaryImage,
                width: 120.w,
                height: 140.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120.w,
                  height: 140.h,
                  color: theme.colorScheme.secondary.withAlpha(51),
                  child: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.secondary, size: 40.r),
                ),
              ),
            ),
            if (product.isForeign == true)
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(200),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.public, color: Colors.white, size: 10.r),
                      SizedBox(width: 4.w),
                      Text('EXTERNO', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sellerName,
                  style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(153), fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                if (originalPrice != null)
                  Text(
                    formatCurrency.format(originalPrice),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                      fontSize: 12.sp,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      formatCurrency.format(price),
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                    if (discount > 0) ...[
                      SizedBox(width: 8.w),
                      Text(
                        '$discount% OFF',
                        style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
