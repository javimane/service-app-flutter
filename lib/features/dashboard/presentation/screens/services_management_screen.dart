import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service_app_flutter/core/data/repositories/services_repository.dart';
import 'package:service_app_flutter/core/data/repositories/categories_repository.dart';
import 'package:service_app_flutter/core/data/models/categories.model.dart';
import 'package:service_app_flutter/core/widgets/app_dropdown.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

final _srvLoadingProvider = StateProvider<bool>((ref) => true);
final _srvListProvider = StateProvider<List<dynamic>>((ref) => []);
final _srvCategoriesProvider = StateProvider<List<CategoryModel>>((ref) => []);
final _srvSearchProvider = StateProvider<String>((ref) => '');

// ─── Screen ─────────────────────────────────────────────────────────────────

class DashboardServicesScreen extends ConsumerStatefulWidget {
  const DashboardServicesScreen({super.key});

  @override
  ConsumerState<DashboardServicesScreen> createState() =>
      _DashboardServicesScreenState();
}

class _DashboardServicesScreenState
    extends ConsumerState<DashboardServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    ref.read(_srvLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(servicesRepositoryProvider);
      final catRepo = ref.read(categoriesRepositoryProvider);
      final cats = await catRepo.findAllServices();
      ref.read(_srvCategoriesProvider.notifier).state = cats;
      final services = await repo.getServices(isActive: true);
      ref.read(_srvListProvider.notifier).state = services
          .map((s) => {
                'id': s.id,
                'name': s.name,
                'description': s.description ?? '',
                'base_price': s.price,
                'category_services_id': s.categoryId,
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading services: $e');
    } finally {
      ref.read(_srvLoadingProvider.notifier).state = false;
    }
  }

  void _openModal({dynamic service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServiceFormSheet(
        service: service,
        onSaved: _load,
      ),
    );
  }

  Future<void> _confirmDelete(dynamic service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Servicio'),
        content: Text(
            '¿Estás seguro de que querés eliminar "${service['name']}"?'),
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
    try {
      // Implement service delete API call here if available
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Servicio eliminado'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(_srvLoadingProvider);
    final services = ref.watch(_srvListProvider);
    final categories = ref.watch(_srvCategoriesProvider);
    final search = ref.watch(_srvSearchProvider);

    final filtered = search.isEmpty
        ? services
        : services.where((s) {
            final name = (s['name'] as String? ?? '').toLowerCase();
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
        title: const Text('Mis Servicios'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded,
                color: theme.colorScheme.primary, size: 24.r),
            onPressed: () => _openModal(),
            tooltip: 'Nuevo Servicio',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: TextField(
              onChanged: (v) =>
                  ref.read(_srvSearchProvider.notifier).state = v,
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

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _EmptyState(
                        icon: Icons.handyman_outlined,
                        message: search.isEmpty
                            ? 'No tenés servicios publicados\n¡Creá tu primer servicio!'
                            : 'No se encontraron servicios',
                        onAction: search.isEmpty ? () => _openModal() : null,
                        actionLabel: 'Crear mi primer servicio',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 4.h),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final service = filtered[i];
                            final catId =
                                service['category_services_id'] as int?;
                            final catName = catId != null
                                ? categories
                                        .where((c) => c.id == catId)
                                        .firstOrNull
                                        ?.name ??
                                    'Sin categoría'
                                : 'Sin categoría';
                            return _ServiceCard(
                              service: service,
                              categoryName: catName,
                              onEdit: () => _openModal(service: service),
                              onDelete: () => _confirmDelete(service),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openModal(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo Servicio'),
      ),
    );
  }
}

// ─── Service Card ──────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final dynamic service;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final price = service['base_price'];
    final priceStr = price != null
        ? '\$${double.tryParse(price.toString())?.toStringAsFixed(0) ?? price}'
        : 'Consultar';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isDark ? 25 : 6),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.handyman_rounded,
                    color: theme.colorScheme.primary, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'] as String? ?? '—',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                    Text(
                      categoryName,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  priceStr,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          if ((service['description'] as String? ?? '').isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              service['description'] as String,
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 16.r),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 22.r),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Service Form Sheet ────────────────────────────────────────────────────

class _ServiceFormSheet extends ConsumerStatefulWidget {
  final dynamic service;
  final VoidCallback onSaved;

  const _ServiceFormSheet({this.service, required this.onSaved});

  @override
  ConsumerState<_ServiceFormSheet> createState() =>
      _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<_ServiceFormSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int? _selectedCategoryId;
  bool _loading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    if (s != null) {
      _nameCtrl.text = s['name'] as String? ?? '';
      _descCtrl.text = s['description'] as String? ?? '';
      _priceCtrl.text = (s['base_price'] ?? '').toString();
      _selectedCategoryId = s['category_services_id'] as int?;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _selectedCategoryId == null ||
        _priceCtrl.text.isEmpty) {
      setState(
          () => _errorMsg = 'Por favor completá los campos obligatorios.');
      return;
    }
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      // Implement create/update service call here
      // final repo = ref.read(servicesRepositoryProvider);
      // await repo.create/update(...)
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.service != null
              ? '¡Servicio actualizado correctamente!'
              : '¡Servicio creado correctamente!'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      setState(() => _errorMsg = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = ref.watch(_srvCategoriesProvider);
    final isEdit = widget.service != null;

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
            Text(isEdit ? 'Editar Servicio' : 'Nuevo Servicio',
                style: TextStyle(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('GESTIÓN DE SERVICIOS',
                style: TextStyle(
                    fontSize: 10.sp,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.secondary)),
            SizedBox(height: 20.h),

            if (_errorMsg != null)
              Container(
                margin: EdgeInsets.only(bottom: 14.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 18.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(_errorMsg!,
                          style:
                              TextStyle(color: Colors.red, fontSize: 13.sp)),
                    ),
                  ],
                ),
              ),

            _FormField(
                ctrl: _nameCtrl,
                label: 'Nombre del servicio *',
                hint: 'Ej: Pintura de interiores'),
            SizedBox(height: 12.h),

            // Category selector
            Text('Categoría *',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54)),
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              child: AppDropdown<int?>(
                isExpanded: true,
                value: _selectedCategoryId,
                hint: 'Seleccionar categoría',
                items: categories
                    .map((c) => AppDropdownItem<int?>(
                          value: c.id,
                          label: c.name,
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategoryId = v),
              ),
            ),

            SizedBox(height: 12.h),
            _FormField(
              ctrl: _priceCtrl,
              label: 'Precio base (ARS) *',
              hint: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.attach_money_rounded,
            ),
            SizedBox(height: 12.h),
            _FormField(
                ctrl: _descCtrl,
                label: 'Descripción',
                hint: 'Detallá de qué trata el servicio...',
                maxLines: 3),

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
                    : Text(isEdit ? 'Guardar Cambios' : 'Crear Servicio',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
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
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18.r)
                : null,
            filled: true,
            fillColor: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withAlpha(20)),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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

  const _EmptyState({
    required this.icon,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

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
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 28.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r))),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
