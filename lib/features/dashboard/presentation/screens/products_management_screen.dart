import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:service_app_flutter/core/data/repositories/products_repository.dart';
import 'package:service_app_flutter/core/data/repositories/categories_repository.dart';
import 'package:service_app_flutter/core/data/repositories/storage_repository.dart';
import 'package:service_app_flutter/core/data/models/categories.model.dart';
import 'package:service_app_flutter/core/services/upload_service.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

final _prodLoadingProvider = StateProvider<bool>((ref) => true);
final _prodListProvider = StateProvider<List<dynamic>>((ref) => []);
final _prodCategoriesProvider = StateProvider<List<CategoryModel>>((ref) => []);
final _prodSearchProvider = StateProvider<String>((ref) => '');

// ─── Screen ─────────────────────────────────────────────────────────────────

class DashboardProductsScreen extends ConsumerStatefulWidget {
  const DashboardProductsScreen({super.key});

  @override
  ConsumerState<DashboardProductsScreen> createState() =>
      _DashboardProductsScreenState();
}

class _DashboardProductsScreenState
    extends ConsumerState<DashboardProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    ref.read(_prodLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(productsRepositoryProvider);
      final catRepo = ref.read(categoriesRepositoryProvider);
      final cats = await catRepo.findAllProducts();
      ref.read(_prodCategoriesProvider.notifier).state = cats;
      // getProductsByProfessional requires a professionalId – using a public list for now
      final products = await repo.getProducts(limit: 50);
      ref.read(_prodListProvider.notifier).state = products
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'price': p.price,
                'image_url': p.imageUrl,
                'brand': p.brand ?? '',
                'stock': p.stock ?? 0,
                'description': p.description ?? '',
                'category_id': p.categoryId,
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      ref.read(_prodLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(_prodLoadingProvider);
    final products = ref.watch(_prodListProvider);
    final search = ref.watch(_prodSearchProvider);

    final filtered = search.isEmpty
        ? products
        : products.where((p) {
            final name = (p['name'] as String? ?? '').toLowerCase();
            return name.contains(search.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Mis Productos'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded,
                color: theme.colorScheme.primary, size: 24.r),
            onPressed: () => _showProductSheet(context, null),
            tooltip: 'Agregar Producto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: TextField(
              onChanged: (v) =>
                  ref.read(_prodSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),

          // Stats chip
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _ChipStat(
                    label: 'Total', value: products.length, color: theme.colorScheme.primary),
                SizedBox(width: 8.w),
                _ChipStat(
                    label: 'Con stock',
                    value: products
                        .where((p) => (p['stock'] as int? ?? 0) > 0)
                        .length,
                    color: Colors.green),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _EmptyState(
                        icon: Icons.inventory_2_outlined,
                        message: 'No se encontraron productos',
                        onAction: () => _showProductSheet(context, null),
                        actionLabel: 'Agregar Producto',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 4.h),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _ProductCard(
                            product: filtered[i],
                            onEdit: () =>
                                _showProductSheet(context, filtered[i]),
                            onDelete: () =>
                                _deleteProduct(filtered[i]['id'].toString()),
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductSheet(context, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo Producto'),
      ),
    );
  }

  Future<void> _deleteProduct(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content:
            const Text('¿Estás seguro de que querés eliminar este producto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // Call unassign or delete API here
    _load();
  }

  void _showProductSheet(BuildContext context, dynamic product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductFormSheet(
        product: product,
        onSaved: _load,
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final imageUrl = product['image_url'] as String?;
    final stock = product['stock'] as int? ?? 0;
    final price = product['price'];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isDark ? 25 : 6),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 90.w,
                    height: 90.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(theme),
                  )
                : _imagePlaceholder(theme),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String? ?? '—',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((product['brand'] as String? ?? '').isNotEmpty)
                    Text(
                      product['brand'] as String,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        price != null
                            ? '\$${price.toString()}'
                            : 'Sin precio',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: stock > 0
                              ? Colors.green.withAlpha(25)
                              : Colors.red.withAlpha(25),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Stock: $stock',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: stock > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 20.r, color: theme.colorScheme.primary),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 20.r, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          SizedBox(width: 4.w),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(ThemeData theme) {
    return Container(
      width: 90.w,
      height: 90.h,
      color: theme.colorScheme.primary.withAlpha(18),
      child: Icon(Icons.inventory_2_outlined,
          color: theme.colorScheme.primary.withAlpha(80), size: 28.r),
    );
  }
}

// ─── Product Form Sheet ───────────────────────────────────────────────────

class _ProductFormSheet extends ConsumerStatefulWidget {
  final dynamic product;
  final VoidCallback onSaved;

  const _ProductFormSheet({this.product, required this.onSaved});

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  File? _imageFile;
  String? _existingImageUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameCtrl.text = p['name'] as String? ?? '';
      _brandCtrl.text = p['brand'] as String? ?? '';
      _descCtrl.text = p['description'] as String? ?? '';
      _priceCtrl.text = (p['price'] ?? '').toString();
      _stockCtrl.text = (p['stock'] ?? '').toString();
      _existingImageUrl = p['image_url'] as String?;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      // ignore: unused_local_variable
      String? imageUrl;
      if (_imageFile != null) {
        final storageRepo = ref.read(storageRepositoryProvider);
        final config = await storageRepo.getProductImagesConfig();
        final uploadUrl = config?['uploadUrl'] as String?;
        if (uploadUrl != null) {
          await ref.read(uploadServiceProvider).uploadToPresignedUrl(
              uploadUrl: uploadUrl, file: _imageFile!);
          imageUrl = config?['publicUrl'] as String?;
        }
      } else {
        imageUrl = _existingImageUrl;
      }

      // TODO: pass imageUrl to createProductAction / updateProfessionalProductAction
      final repo = ref.read(productsRepositoryProvider);
      // For new product creation via the public endpoint
      await repo.getProducts(); // placeholder – implement create/update with actual method

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.product != null
              ? 'Producto actualizado'
              : 'Producto guardado'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.product != null;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(isEdit ? 'Editar Producto' : 'Nuevo Producto',
                style: TextStyle(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('CATÁLOGO DE PRODUCTOS',
                style: TextStyle(
                    fontSize: 10.sp,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.secondary)),
            SizedBox(height: 20.h),

            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 140.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: theme.colorScheme.primary.withAlpha(12),
                  border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : Colors.black.withAlpha(25)),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13.r),
                        child: Image.file(_imageFile!, fit: BoxFit.cover,
                            width: double.infinity),
                      )
                    : _existingImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13.r),
                            child: Image.network(_existingImageUrl!,
                                fit: BoxFit.cover, width: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 36.r, color: theme.colorScheme.primary),
                              SizedBox(height: 8.h),
                              Text('Toca para agregar imagen',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: theme.colorScheme.primary)),
                            ],
                          ),
              ),
            ),

            SizedBox(height: 16.h),
            _Field(ctrl: _nameCtrl, label: 'Nombre *', hint: 'Ej: Taladro inalámbrico'),
            SizedBox(height: 10.h),
            _Field(ctrl: _brandCtrl, label: 'Marca', hint: 'Ej: Bosch'),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                    child: _Field(
                        ctrl: _priceCtrl,
                        label: 'Precio *',
                        hint: '0',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true))),
                SizedBox(width: 10.w),
                Expanded(
                    child: _Field(
                        ctrl: _stockCtrl,
                        label: 'Stock',
                        hint: '0',
                        keyboardType: TextInputType.number)),
              ],
            ),
            SizedBox(height: 10.h),
            _Field(
                ctrl: _descCtrl,
                label: 'Descripción',
                hint: 'Detallá el producto...',
                maxLines: 2),

            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _loading
                    ? SizedBox(
                        height: 20.r,
                        width: 20.r,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'Guardar Cambios' : 'Agregar Producto',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared widgets ─────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54)),
        SizedBox(height: 5.h),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
            filled: true,
            fillColor: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                  color:
                      isDark ? Colors.white10 : Colors.black.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                  color:
                      isDark ? Colors.white10 : Colors.black.withAlpha(20)),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          ),
        ),
      ],
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ChipStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: color)),
          SizedBox(width: 5.w),
          Text(label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _EmptyState(
      {required this.icon,
      required this.message,
      this.onAction,
      this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60.r, color: Colors.grey.withAlpha(80)),
          SizedBox(height: 14.h),
          Text(message,
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              textAlign: TextAlign.center),
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r))),
            ),
          ],
        ],
      ),
    );
  }
}
