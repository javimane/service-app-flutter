import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/data/models/categories.model.dart';
import '../../../../core/data/models/professional_product_model.dart';
import '../../../../core/data/models/product_model.dart';
import '../../../../core/data/notifiers/auth_notifier.dart';
import '../../../../core/data/repositories/categories_repository.dart';
import '../../../../core/data/repositories/products_repository.dart';
import '../../../../core/data/repositories/storage_repository.dart';
import '../../../../core/services/upload_service.dart';
import '../../../../core/widgets/app_dropdown.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

final _prodLoadingProvider = StateProvider<bool>((ref) => true);
final _prodListProvider = StateProvider<List<ProfessionalProductModel>>((ref) => []);
final _prodCategoriesProvider = StateProvider<List<CategoryModel>>((ref) => []);
final _prodSearchProvider = StateProvider<String>((ref) => '');
final _prodEanSearchProvider = StateProvider<String>((ref) => '');
final _prodCategoryFilterProvider = StateProvider<String>((ref) => '');
final _prodSortFieldProvider = StateProvider<String>((ref) => 'title'); // title, price, stock
final _prodSortDirProvider = StateProvider<bool>((ref) => true); // true = asc

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

  int? _getProfessionalId() {
    final authState = ref.read(authNotifierProvider);
    final sessionStatus =
        authState.session?['sessionStatus'] as Map<String, dynamic>?;
    if (sessionStatus != null) {
      return (sessionStatus['subscription']?['professional_id'] as int?) ??
          (sessionStatus['professional_id'] as int?);
    }
    return null;
  }

  Future<void> _load() async {
    final profId = _getProfessionalId();
    if (profId == null) return;

    ref.read(_prodLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(productsRepositoryProvider);
      final catRepo = ref.read(categoriesRepositoryProvider);

      final cats = await catRepo.findAllProducts();
      ref.read(_prodCategoriesProvider.notifier).state = cats;

      final products = await repo.getProductsByProfessional(profId);
      ref.read(_prodListProvider.notifier).state = products;
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      ref.read(_prodLoadingProvider.notifier).state = false;
    }
  }

  void _showBulkUpdateModal() {
    showDialog(
      context: context,
      builder: (_) => _BulkUpdateModal(onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(_prodLoadingProvider);
    final products = ref.watch(_prodListProvider);
    final search = ref.watch(_prodSearchProvider).toLowerCase();
    final eanSearch = ref.watch(_prodEanSearchProvider).toLowerCase();
    final catFilter = ref.watch(_prodCategoryFilterProvider);
    final sortField = ref.watch(_prodSortFieldProvider);
    final sortAsc = ref.watch(_prodSortDirProvider);
    final categories = ref.watch(_prodCategoriesProvider);

    var filtered = products.where((p) {
      final title = (p.product?.name ?? '').toLowerCase();
      final ean = (p.product?.ean ?? '').toLowerCase();
      final cat = (p.product?.category?.name ?? 'General').toString();

      bool matchName = search.isEmpty || title.contains(search);
      bool matchEan = eanSearch.isEmpty || ean.contains(eanSearch);
      bool matchCat = catFilter.isEmpty || cat == catFilter;
      return matchName && matchEan && matchCat;
    }).toList();

    filtered.sort((a, b) {
      int cmp = 0;
      if (sortField == 'title') {
        cmp = (a.product?.name ?? '').compareTo(b.product?.name ?? '');
      } else if (sortField == 'price') {
        final pa = (a.offerPrice != null && a.offerPrice! > 0)
            ? a.offerPrice!
            : a.price;
        final pb = (b.offerPrice != null && b.offerPrice! > 0)
            ? b.offerPrice!
            : b.price;
        cmp = pa.compareTo(pb);
      } else if (sortField == 'stock') {
        cmp = (a.stock ?? 0).compareTo(b.stock ?? 0);
      }
      return sortAsc ? cmp : -cmp;
    });

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
            icon: Icon(Icons.percent_rounded, color: theme.colorScheme.primary),
            onPressed: _showBulkUpdateModal,
            tooltip: 'Actualizar precios masivamente',
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary),
            onPressed: () => _showProductSheet(context, null),
            tooltip: 'Agregar Producto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
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
                          borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    onChanged: (v) =>
                        ref.read(_prodEanSearchProvider.notifier).state = v,
                    decoration: InputDecoration(
                      hintText: 'Buscar por EAN...',
                      prefixIcon: const Icon(Icons.barcode_reader),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    value: catFilter.isEmpty ? '' : catFilter,
                    hint: 'Categoría',
                    isExpanded: true,
                    items: [
                      const AppDropdownItem(value: '', label: 'Todas'),
                      ...categories.map((c) => AppDropdownItem(
                          value: c.name, label: c.name)),
                    ],
                    onChanged: (v) => ref
                        .read(_prodCategoryFilterProvider.notifier)
                        .state = v,
                  ),
                ),
                SizedBox(width: 8.w),
                AppDropdown<String>(
                  value: sortField,
                  icon: Row(
                    children: [
                      Icon(sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16.r, color: Colors.grey),
                      const Icon(Icons.sort, color: Colors.grey),
                    ],
                  ),
                  items: const [
                    AppDropdownItem(value: 'title', label: 'Título'),
                    AppDropdownItem(value: 'price', label: 'Precio'),
                    AppDropdownItem(value: 'stock', label: 'Stock'),
                  ],
                  onChanged: (v) {
                    if (v == sortField) {
                      ref.read(_prodSortDirProvider.notifier).state = !sortAsc;
                    } else {
                      ref.read(_prodSortFieldProvider.notifier).state = v;
                      ref.read(_prodSortDirProvider.notifier).state = true;
                    }
                  },
                ),
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
                                _deleteProduct(filtered[i].product!.id),
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

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desasignar Producto'),
        content: const Text(
            '¿Estás seguro de que querés desasignar este producto de tu catálogo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Desasignar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final profId = _getProfessionalId();
    if (profId == null) return;
    try {
      ref.read(_prodLoadingProvider.notifier).state = true;
      await ref
          .read(productsRepositoryProvider)
          .unassignProductFromProfessional(productId, profId);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
      ref.read(_prodLoadingProvider.notifier).state = false;
    }
  }

  void _showProductSheet(BuildContext context, ProfessionalProductModel? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductFormSheet(
        product: product,
        professionalId: _getProfessionalId()!,
        onSaved: _load,
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProfessionalProductModel product;
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
    
    // Attempt to extract image
    String? imageUrl;
    if (product.product?.images != null && product.product!.images.isNotEmpty) {
      final sorted = List.of(product.product!.images);
      sorted.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
      imageUrl = sorted.first.imageUrl;
    }

    final stock = product.stock ?? 0;
    final price = product.price;
    final offerPrice = product.offerPrice ?? 0;

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
                    product.product?.name ?? '—',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((product.product?.brand ?? '').isNotEmpty)
                    Text(
                      product.product!.brand!,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (offerPrice > 0)
                            Text(
                              '\$${price.toString()}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 10.sp,
                              ),
                            ),
                          Text(
                            '\$${offerPrice > 0 ? offerPrice : price}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
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

// ─── Bulk Update Modal ────────────────────────────────────────────────────

class _BulkUpdateModal extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _BulkUpdateModal({required this.onSaved});

  @override
  ConsumerState<_BulkUpdateModal> createState() => _BulkUpdateModalState();
}

class _BulkUpdateModalState extends ConsumerState<_BulkUpdateModal> {
  bool _isPercent = true; // true = percent, false = fixed
  bool _isIncrease = true; // true = add, false = subtract
  bool _deleteOfferPrice = false;
  final _valCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final val = double.tryParse(_valCtrl.text) ?? 0;
    if (val <= 0 && !_deleteOfferPrice) return;

    final authState = ref.read(authNotifierProvider);
    final sessionStatus =
        authState.session?['sessionStatus'] as Map<String, dynamic>?;
    final profId = sessionStatus?['subscription']?['professional_id'] as int? ??
        sessionStatus?['professional_id'] as int?;
    
    if (profId == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(productsRepositoryProvider).massUpdateProductPrices({
        'professionalId': profId,
        'type': _isPercent ? 'percent' : 'fixed',
        'value': val,
        'operation': _isIncrease ? 'add' : 'subtract',
        'delete_offer_price': _deleteOfferPrice,
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
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
    return AlertDialog(
      title: const Text('Actualización masiva'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Porcentaje')),
                      ButtonSegment(value: false, label: Text('Fijo')),
                    ],
                    selected: {_isPercent},
                    onSelectionChanged: (v) => setState(() => _isPercent = v.first),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Aumento')),
                      ButtonSegment(value: false, label: Text('Descuento')),
                    ],
                    selected: {_isIncrease},
                    onSelectionChanged: (v) => setState(() => _isIncrease = v.first),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _valCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            CheckboxListTile(
              title: const Text('Eliminar precio de oferta'),
              value: _deleteOfferPrice,
              onChanged: (v) => setState(() => _deleteOfferPrice = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? SizedBox(
                  height: 16.r, width: 16.r, child: const CircularProgressIndicator())
              : const Text('Aplicar'),
        ),
      ],
    );
  }
}

// ─── Product Form Sheet ───────────────────────────────────────────────────

class _EditImageItem {
  final String? url;
  final File? file;
  _EditImageItem({this.url, this.file});
}

class _ProductFormSheet extends ConsumerStatefulWidget {
  final ProfessionalProductModel? product;
  final int professionalId;
  final VoidCallback onSaved;

  const _ProductFormSheet(
      {this.product, required this.professionalId, required this.onSaved});

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  final _eanCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _offerPriceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String _currencyCode = 'ARG';
  String? _categoryId;

  List<_EditImageItem> _images = [];
  bool _loading = false;

  // EAN lookup state
  ProductModel? _eanMatch;
  bool _eanLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _eanCtrl.text = p.product?.ean ?? '';
      _nameCtrl.text = p.product?.name ?? '';
      _brandCtrl.text = p.product?.brand ?? '';
      _descCtrl.text = p.product?.description ?? '';
      _priceCtrl.text = p.price.toString();
      _stockCtrl.text = (p.stock ?? 0).toString();
      _offerPriceCtrl.text = (p.offerPrice ?? 0).toString();
      _discountCtrl.text = (p.percentDiscount ?? 0).toString();
      _urlCtrl.text = p.linkUrl ?? p.product?.linkUrl ?? '';
      _currencyCode = p.currencyCode ?? p.product?.currencyCode ?? 'ARG';
      _categoryId = p.product?.categoryId?.toString();

      if (p.product?.images != null) {
        final sorted = List.of(p.product!.images);
        sorted.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
        _images = sorted.map((e) => _EditImageItem(url: e.imageUrl)).toList();
      }
    }
  }

  Future<void> _checkEan() async {
    final ean = _eanCtrl.text.trim();
    if (ean.isEmpty) return;
    setState(() => _eanLoading = true);
    try {
      final repo = ref.read(productsRepositoryProvider);
      final match = await repo.getProductByEan(ean, professionalId: widget.professionalId);
      setState(() {
        _eanMatch = match;
        if (match != null) {
          _nameCtrl.text = match.name;
          _brandCtrl.text = match.brand ?? '';
          _descCtrl.text = match.description ?? '';
          _categoryId = match.categoryId?.toString();
          if (match.images.isNotEmpty) {
            final sorted = List.of(match.images);
            sorted.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
            _images = sorted.map((e) => _EditImageItem(url: e.imageUrl)).toList();
          }
        }
      });
    } catch (e) {
      debugPrint('Error checking EAN: $e');
    } finally {
      setState(() => _eanLoading = false);
    }
  }

  Future<void> _pickImage() async {
    if (_images.length >= 4) return;
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage(imageQuality: 80);
    if (pickedList.isNotEmpty) {
      setState(() {
        for (var picked in pickedList) {
          if (_images.length < 4) {
            _images.add(_EditImageItem(file: File(picked.path)));
          }
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(productsRepositoryProvider);
      final storageRepo = ref.read(storageRepositoryProvider);
      final uploadSvc = ref.read(uploadServiceProvider);

      // 1. Upload new images
      List<String> finalUrls = [];
      for (var img in _images) {
        if (img.url != null) {
          finalUrls.add(img.url!);
        } else if (img.file != null) {
          final config = await storageRepo.getProductImagesConfig();
          final uploadUrl = config?['uploadUrl'] as String?;
          if (uploadUrl != null) {
            await uploadSvc.uploadToPresignedUrl(
                uploadUrl: uploadUrl, file: img.file!);
            if (config?['publicUrl'] != null) {
              finalUrls.add(config!['publicUrl'] as String);
            }
          }
        }
      }

      final price = double.tryParse(_priceCtrl.text) ?? 0;
      final offerPrice = double.tryParse(_offerPriceCtrl.text) ?? 0;
      final stock = int.tryParse(_stockCtrl.text) ?? 0;
      final discount = int.tryParse(_discountCtrl.text) ?? 0;

      if (widget.product != null) {
        // UPDATE
        await repo.updateProfessionalProduct(
            widget.professionalId, widget.product!.product!.id, {
          'ean': _eanCtrl.text,
          'name': _nameCtrl.text,
          'description': _descCtrl.text,
          'brand': _brandCtrl.text,
          'image_url': finalUrls,
          'display_order': List.generate(finalUrls.length, (i) => i + 1),
          'categories_products_id': int.tryParse(_categoryId ?? ''),
          'price': price,
          'stock': stock,
          'offer_price': offerPrice,
          'currency_code': _currencyCode,
          'percent_discount': discount,
          'link_url': _urlCtrl.text,
        });
      } else if (_eanMatch != null) {
        // ASSIGN
        await repo.assignProductToProfessional({
          'professional_id': widget.professionalId,
          'product_id': _eanMatch!.id,
          'price': price,
          'sale_type': 'unit',
          'is_active': true,
          'stock': stock,
          'offer_price': offerPrice,
        });
      } else {
        // CREATE
        await repo.createProduct({
          'ean': _eanCtrl.text,
          'name': _nameCtrl.text,
          'description': _descCtrl.text,
          'brand': _brandCtrl.text,
          'image_url': finalUrls,
          'display_order': List.generate(finalUrls.length, (i) => i + 1),
          'categories_products_id': int.tryParse(_categoryId ?? ''),
          'professional_id': widget.professionalId,
          'price': price,
          'sale_type': 'unit',
          'stock': stock,
          'is_active': true,
          'offer_price': offerPrice,
          'currency_code': _currencyCode,
          'percent_discount': discount,
          'link_url': _urlCtrl.text,
        });
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
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
    final categories = ref.watch(_prodCategoriesProvider);

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
            SizedBox(height: 20.h),

            // EAN
            Row(
              children: [
                Expanded(
                  child: _Field(
                      ctrl: _eanCtrl, label: 'EAN', hint: 'Código de barras'),
                ),
                if (!isEdit) ...[
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: _eanLoading ? null : _checkEan,
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h)),
                    child: _eanLoading
                        ? SizedBox(height: 16.r, width: 16.r, child: const CircularProgressIndicator())
                        : const Text('Buscar'),
                  )
                ]
              ],
            ),
            if (_eanMatch != null && !isEdit) ...[
              SizedBox(height: 8.h),
              Text('¡Producto encontrado en catálogo!',
                  style: TextStyle(color: Colors.green, fontSize: 12.sp)),
            ],
            SizedBox(height: 16.h),

            // Image picker
            Text('Imágenes (máx 4)',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54)),
            SizedBox(height: 8.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._images.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final img = entry.value;
                    return Container(
                      margin: EdgeInsets.only(right: 8.w),
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.withAlpha(50)),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: img.url != null
                                ? Image.network(img.url!, fit: BoxFit.cover)
                                : Image.file(img.file!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(idx)),
                              child: CircleAvatar(
                                radius: 10.r,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, size: 12.r, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_images.length < 4)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: theme.colorScheme.primary.withAlpha(12),
                          border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black.withAlpha(25)),
                        ),
                        child: Icon(Icons.add_photo_alternate_outlined,
                            size: 28.r, color: theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            _Field(ctrl: _nameCtrl, label: 'Nombre *', hint: 'Ej: Taladro inalámbrico'),
            SizedBox(height: 10.h),
            _Field(ctrl: _brandCtrl, label: 'Marca', hint: 'Ej: Bosch'),
            SizedBox(height: 10.h),

            Text('Categoría',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54)),
            SizedBox(height: 5.h),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(4),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
              ),
              items: categories.map((c) => DropdownMenuItem(
                  value: c.id.toString(), child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
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
                        ctrl: _offerPriceCtrl,
                        label: 'Precio Oferta',
                        hint: '0',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true))),
              ],
            ),
            SizedBox(height: 10.h),

            Row(
              children: [
                Expanded(
                    child: _Field(
                        ctrl: _stockCtrl,
                        label: 'Stock',
                        hint: '0',
                        keyboardType: TextInputType.number)),
                SizedBox(width: 10.w),
                Expanded(
                    child: _Field(
                        ctrl: _discountCtrl,
                        label: '% Descuento',
                        hint: '0',
                        keyboardType: TextInputType.number)),
              ],
            ),
            SizedBox(height: 10.h),

            _Field(ctrl: _urlCtrl, label: 'URL del Link', hint: 'https://...'),
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
