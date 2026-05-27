import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/data/providers/session_provider.dart';
import '../../../../core/data/repositories/products_repository.dart';

class ProposalAddItemScreen extends ConsumerStatefulWidget {
  const ProposalAddItemScreen({super.key});

  @override
  ConsumerState<ProposalAddItemScreen> createState() =>
      _ProposalAddItemScreenState();
}

class _ProposalAddItemScreenState extends ConsumerState<ProposalAddItemScreen> {
  int _tabIndex = 0; // 0 = Services, 1 = Products

  // Services State
  final List<Map<String, dynamic>> _tempItems = [
    {'name': '', 'qty': 1, 'rate': 0.0}
  ];

  // Products State
  String _productSource = 'mine'; // 'mine' or 'all'
  String _productSearch = '';
  List<Map<String, dynamic>> _dbProducts = [];
  bool _isLoadingProducts = false;
  final List<Map<String, dynamic>> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProducts();
    });
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final session = ref.read(sessionInfoProvider);
      final repo = ref.read(productsRepositoryProvider);
      final profId = session.professionalId;

      List<Map<String, dynamic>> results = [];

      if (_productSource == 'mine' && profId != null) {
        final products = await repo.getProductsByProfessional(profId);
        var mapped = products.map((p) => {
          'id': p.productId,
          'name': p.product?.name ?? 'Producto',
          'price': p.price,
          'image': p.product?.images.isNotEmpty == true ? p.product!.images.first.imageUrl : null,
          'category': p.product?.category?.name,
        }).toList();

        if (_productSearch.trim().isNotEmpty) {
          final q = _productSearch.trim().toLowerCase();
          mapped = mapped.where((p) => (p['name'] as String).toLowerCase().contains(q)).toList();
        }
        results = mapped;
      } else {
        // "Toda la base de datos"
        if (_productSearch.trim().isNotEmpty) {
           final products = await repo.searchProductsByName(_productSearch.trim());
           results = products.map((p) => {
             'id': p.id,
             'name': p.name,
             'price': p.price ?? p.defaultPrice ?? 0.0,
             'image': p.images.isNotEmpty ? p.images.first.imageUrl : null,
             'category': p.category?.name,
           }).toList();
        } else {
           final products = await repo.getProducts(limit: 50);
           results = products.map((p) => {
             'id': p.id,
             'name': p.name,
             'price': p.price ?? p.defaultPrice ?? 0.0,
             'image': p.images.isNotEmpty ? p.images.first.imageUrl : null,
             'category': p.category?.name,
           }).toList();
        }
      }

      if (mounted) {
        setState(() => _dbProducts = results);
      }
    } catch (e) {
       debugPrint('Error fetching products: $e');
       if (mounted) setState(() => _dbProducts = []);
    } finally {
       if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  void _submit() {
    if (_tabIndex == 0) {
      final valid = _tempItems
          .where((i) => (i['name'] as String).trim().isNotEmpty)
          .map((i) {
        final qty = i['qty'] as int;
        final rate = i['rate'] as double;
        return {
          'name': i['name'],
          'qty': qty,
          'rate': rate,
          'total': qty * rate,
        };
      }).toList();
      Navigator.pop(context, valid);
    } else {
      final valid = _selectedProducts.map((p) {
        final qty = p['qty'] as int;
        final rate = p['rate'] as double;
        return {
          'name': p['name'],
          'qty': qty,
          'rate': rate,
          'total': qty * rate,
        };
      }).toList();
      Navigator.pop(context, valid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Ítems'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              // Tabs
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      title: 'Servicios',
                      icon: Icons.design_services_rounded,
                      isActive: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _TabButton(
                      title: 'Productos',
                      icon: Icons.shopping_cart_rounded,
                      isActive: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Content
              Expanded(
                child: _tabIndex == 0
                    ? _buildServicesTab(isDark)
                    : _buildProductsTab(isDark),
              ),

              // Footer
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: const Text('Añadir al Presupuesto'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesTab(bool isDark) {
    return ListView(
      children: [
        const Text('Ingresá los servicios manuales que querés incluir.',
            style: TextStyle(color: Colors.grey)),
        SizedBox(height: 16.h),
        ..._tempItems.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: item['name'],
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (val) => item['name'] = val,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: item['qty'].toString(),
                    decoration: const InputDecoration(labelText: 'Cant.'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => item['qty'] = int.tryParse(val) ?? 1,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: item['rate'].toString(),
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        item['rate'] = double.tryParse(val) ?? 0.0,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (_tempItems.length > 1) {
                        _tempItems.removeAt(index);
                      } else {
                        _tempItems[0] = {'name': '', 'qty': 1, 'rate': 0.0};
                      }
                    });
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(
              () => _tempItems.add({'name': '', 'qty': 1, 'rate': 0.0})),
          icon: const Icon(Icons.add),
          label: const Text('Agregar otra fila'),
        ),
      ],
    );
  }

  Widget _buildProductsTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Buscá y seleccioná productos para incluir en el presupuesto.',
            style: TextStyle(color: Colors.grey)),
        SizedBox(height: 12.h),

        // Source Toggle
        Row(
           children: [
             Expanded(
               child: OutlinedButton(
                 style: OutlinedButton.styleFrom(
                   backgroundColor: _productSource == 'mine' ? Theme.of(context).colorScheme.primary.withAlpha(20) : null,
                   side: BorderSide(color: _productSource == 'mine' ? Theme.of(context).colorScheme.primary : Colors.grey),
                 ),
                 onPressed: () {
                   setState(() { _productSource = 'mine'; _dbProducts = []; });
                   _fetchProducts();
                 },
                 child: Text('Mis productos', style: TextStyle(color: _productSource == 'mine' ? Theme.of(context).colorScheme.primary : Colors.grey)),
               ),
             ),
             SizedBox(width: 8.w),
             Expanded(
               child: OutlinedButton(
                 style: OutlinedButton.styleFrom(
                   backgroundColor: _productSource == 'all' ? Theme.of(context).colorScheme.primary.withAlpha(20) : null,
                   side: BorderSide(color: _productSource == 'all' ? Theme.of(context).colorScheme.primary : Colors.grey),
                 ),
                 onPressed: () {
                   setState(() { _productSource = 'all'; _dbProducts = []; });
                   _fetchProducts();
                 },
                 child: Text('Toda la BD', style: TextStyle(color: _productSource == 'all' ? Theme.of(context).colorScheme.primary : Colors.grey)),
               ),
             ),
           ],
        ),

        SizedBox(height: 12.h),

        // Search Bar
        Row(
           children: [
             Expanded(
               child: TextFormField(
                 initialValue: _productSearch,
                 decoration: InputDecoration(
                   hintText: 'Buscar producto...',
                   prefixIcon: const Icon(Icons.search),
                   isDense: true,
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                 ),
                 onChanged: (val) => _productSearch = val,
                 onFieldSubmitted: (_) => _fetchProducts(),
               ),
             ),
             SizedBox(width: 8.w),
             ElevatedButton(
               onPressed: _isLoadingProducts ? null : _fetchProducts,
               style: ElevatedButton.styleFrom(
                 padding: EdgeInsets.symmetric(vertical: 14.h),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                 minimumSize: Size.zero,
               ),
               child: _isLoadingProducts ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2)) : const Text('Buscar'),
             ),
           ],
        ),

        SizedBox(height: 16.h),

        Expanded(
          child: _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : _dbProducts.isEmpty
                  ? Center(child: Text(_productSource == 'all' && _productSearch.isEmpty ? 'Buscá productos usando la barra superior.' : 'No se encontraron productos.'))
                  : ListView.builder(
                      itemCount: _dbProducts.length,
                      itemBuilder: (ctx, i) {
                        final p = _dbProducts[i];
                        final isSelected = _selectedProducts.any((sp) => sp['id'] == p['id']);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: p['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(p['image'], width: 48.w, height: 48.w, fit: BoxFit.cover),
                                )
                              : Container(
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(50),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                                ),
                          title: Text(p['name']),
                          subtitle: Text('\$${p['price']} - ${p['category'] ?? "General"}'),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.add_circle_outline),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedProducts.removeWhere((sp) => sp['id'] == p['id']);
                              } else {
                                _selectedProducts.add({
                                  'id': p['id'],
                                  'name': p['name'],
                                  'rate': p['price'],
                                  'qty': 1,
                                });
                              }
                            });
                          },
                        );
                      },
                    ),
        ),

        if (_selectedProducts.isNotEmpty) ...[
          SizedBox(height: 12.h),
          const Divider(),
          Text('Productos seleccionados (${_selectedProducts.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
               itemCount: _selectedProducts.length,
               itemBuilder: (ctx, i) {
                  final sp = _selectedProducts[i];
                  return Row(
                     children: [
                       Expanded(flex: 2, child: Text(sp['name'], maxLines: 1, overflow: TextOverflow.ellipsis)),
                       SizedBox(width: 8.w),
                       Expanded(
                         flex: 1,
                         child: TextFormField(
                           initialValue: sp['qty'].toString(),
                           keyboardType: TextInputType.number,
                           decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                           onChanged: (val) {
                              setState(() {
                                 sp['qty'] = int.tryParse(val) ?? 1;
                              });
                           },
                         ),
                       ),
                       SizedBox(width: 8.w),
                       Text('\$${((sp['qty'] as int) * (sp['rate'] as double)).toStringAsFixed(2)}'),
                       IconButton(
                         icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                         onPressed: () {
                           setState(() {
                             _selectedProducts.removeAt(i);
                           });
                         }
                       ),
                     ],
                  );
               }
            ),
          ),
        ]
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton(
      {required this.title,
      required this.icon,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary
              : (theme.brightness == Brightness.dark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(5)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey),
            SizedBox(width: 8.w),
            Text(title,
                style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
