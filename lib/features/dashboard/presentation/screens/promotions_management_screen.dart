import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app_flutter/core/data/repositories/professional_promotions_repository.dart';
import 'package:service_app_flutter/core/data/repositories/storage_repository.dart';
import 'package:service_app_flutter/core/services/upload_service.dart';

// ─── Models ─────────────────────────────────────────────────────────────────

const _discountTypes = [
  {'value': 'percentage', 'label': 'Porcentaje (%)'},
  {'value': 'fixed', 'label': 'Monto Fijo (\$)'},
  {'value': 'bogo', 'label': '2x1'},
  {'value': 'free', 'label': 'Gratis'},
];

const _statusLabels = {
  'active': 'Activa',
  'expired': 'Expirada',
  'draft': 'Borrador',
};

// ─── Providers ──────────────────────────────────────────────────────────────

final _promotionsViewProvider = StateProvider<String>((ref) => 'list');
final _editingPromotionProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final _promotionsLoadingProvider = StateProvider<bool>((ref) => true);
final _promotionsListProvider =
    StateProvider<List<dynamic>>((ref) => []);

// ─── Main Screen ─────────────────────────────────────────────────────────────

class DashboardPromotionsScreen extends ConsumerStatefulWidget {
  const DashboardPromotionsScreen({super.key});

  @override
  ConsumerState<DashboardPromotionsScreen> createState() =>
      _DashboardPromotionsScreenState();
}

class _DashboardPromotionsScreenState
    extends ConsumerState<DashboardPromotionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPromotions());
  }

  Future<void> _loadPromotions() async {
    ref.read(_promotionsLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(professionalPromotionsRepositoryProvider);
      final result = await repo.findAllPublic();
      ref.read(_promotionsListProvider.notifier).state =
          (result?['data'] as List?) ?? (result is List ? result : []);
    } catch (e) {
      debugPrint('Error loading promotions: $e');
    } finally {
      ref.read(_promotionsLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(_promotionsViewProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: view != 'list'
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  ref.read(_promotionsViewProvider.notifier).state = 'list';
                  ref.read(_editingPromotionProvider.notifier).state = null;
                },
              )
            : const BackButton(),
        title: Text(view == 'list'
            ? 'Mis Promociones'
            : view == 'create'
                ? 'Crear Promoción'
                : 'Editar Promoción'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: view == 'list'
            ? [
                IconButton(
                  onPressed: () {
                    ref.read(_editingPromotionProvider.notifier).state = null;
                    ref.read(_promotionsViewProvider.notifier).state = 'create';
                  },
                  icon: Icon(Icons.add_rounded,
                      color: theme.colorScheme.primary, size: 24.r),
                ),
              ]
            : null,
      ),
      body: view == 'list'
          ? _PromotionsList(
              onCreateNew: () {
                ref.read(_editingPromotionProvider.notifier).state = null;
                ref.read(_promotionsViewProvider.notifier).state = 'create';
              },
              onEdit: (promo) {
                ref.read(_editingPromotionProvider.notifier).state =
                    Map<String, dynamic>.from(promo as Map);
                ref.read(_promotionsViewProvider.notifier).state = 'edit';
              },
              onReload: _loadPromotions,
            )
          : _PromotionForm(
              promotionToEdit: ref.watch(_editingPromotionProvider),
              onDone: () {
                ref.read(_promotionsViewProvider.notifier).state = 'list';
                ref.read(_editingPromotionProvider.notifier).state = null;
                _loadPromotions();
              },
            ),
    );
  }
}

// ─── Promotions List ─────────────────────────────────────────────────────────

class _PromotionsList extends ConsumerWidget {
  final VoidCallback onCreateNew;
  final void Function(dynamic) onEdit;
  final VoidCallback onReload;

  const _PromotionsList({
    required this.onCreateNew,
    required this.onEdit,
    required this.onReload,
  });

  String _offerLabel(dynamic promo) {
    final type = promo['discount_type'] as String?;
    final value = promo['discount_value'];
    switch (type) {
      case 'percentage':
        return '$value% OFF';
      case 'fixed':
        return '\$$value';
      case 'bogo':
        return '2x1';
      case 'free':
        return 'GRATIS';
      default:
        return '';
    }
  }

  String _statusLabel(dynamic promo) {
    final state = promo['state'] as String? ?? 'active';
    return _statusLabels[state] ?? 'Activa';
  }

  Color _statusColor(dynamic promo) {
    final state = promo['state'] as String? ?? 'active';
    switch (state) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = ref.watch(_promotionsLoadingProvider);
    final promotions = ref.watch(_promotionsListProvider);

    // Stats
    final total = promotions.length;
    final active =
        promotions.where((p) => p['state'] == 'active').length;
    final expired =
        promotions.where((p) => p['state'] == 'expired').length;
    final drafts =
        promotions.where((p) => p['state'] == 'draft').length;

    return RefreshIndicator(
      onRefresh: () async => onReload(),
      child: CustomScrollView(
        slivers: [
          // Stats
          SliverToBoxAdapter(
            child: Container(
              color: theme.colorScheme.surface,
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  _StatPill(label: 'Total', value: total, color: theme.colorScheme.primary),
                  SizedBox(width: 8.w),
                  _StatPill(label: 'Activas', value: active, color: Colors.green),
                  SizedBox(width: 8.w),
                  _StatPill(label: 'Expiradas', value: expired, color: Colors.red),
                  SizedBox(width: 8.w),
                  _StatPill(label: 'Borradores', value: drafts, color: Colors.orange),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.r),
            sliver: isLoading
                ? SliverToBoxAdapter(
                    child: Column(children: [
                      SizedBox(height: 60.h),
                      const CircularProgressIndicator(),
                    ]),
                  )
                : promotions.isEmpty
                    ? SliverToBoxAdapter(
                        child: SizedBox(
                          height: 300.h,
                          child: const _EmptyState(
                            icon: Icons.local_offer_outlined,
                            message:
                                'No tenés promociones aún.\n¡Creá tu primera oferta!',
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final promo = promotions[i];
                            final imageUrl = promo['image_url'] as String?;
                            return Container(
                              margin: EdgeInsets.only(bottom: 14.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.black.withAlpha(13)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withAlpha(isDark ? 30 : 8),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  if (imageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(18.r)),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            height: 160.h,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              height: 160.h,
                                              color: theme
                                                  .colorScheme.primary
                                                  .withAlpha(20),
                                              child: const Center(
                                                  child: Icon(
                                                      Icons.image_not_supported_outlined)),
                                            ),
                                          ),
                                          // Offer badge
                                          Positioned(
                                            bottom: 10.h,
                                            left: 10.w,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 4.h),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Text(
                                                _offerLabel(promo),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Status badge
                                          Positioned(
                                            top: 10.h,
                                            right: 10.w,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 4.h),
                                              decoration: BoxDecoration(
                                                color: _statusColor(promo),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Text(
                                                _statusLabel(promo),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 80.h,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withAlpha(20),
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(18.r)),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.local_offer_rounded,
                                                color: theme.colorScheme.primary,
                                                size: 24.r),
                                            SizedBox(width: 8.w),
                                            Text(
                                              _offerLabel(promo),
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  Padding(
                                    padding: EdgeInsets.all(14.r),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          promo['title'] as String? ?? '—',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (promo['description'] != null)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4.h),
                                            child: Text(
                                              promo['description'] as String,
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.grey),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        SizedBox(height: 10.h),
                                        // Dates
                                        if (promo['from_date'] != null ||
                                            promo['expires_at'] != null)
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today_rounded,
                                                  size: 13.r,
                                                  color: Colors.grey),
                                              SizedBox(width: 4.w),
                                              Text(
                                                '${_fmtDate(promo['from_date'])} — ${_fmtDate(promo['expires_at'])}',
                                                style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: 12.h),
                                        // Actions
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => onEdit(promo),
                                                icon: Icon(Icons.edit_rounded,
                                                    size: 16.r),
                                                label: const Text('Editar'),
                                                style: OutlinedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 8.h),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.r)),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            _DeleteButton(
                                              promoId: promo['id'].toString(),
                                              onDeleted: onReload,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: promotions.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      return DateTime.parse(raw as String).toLocal().toString().substring(0, 10);
    } catch (_) {
      return raw.toString().substring(0, 10);
    }
  }
}

// ─── Delete Button ────────────────────────────────────────────────────────────

class _DeleteButton extends ConsumerStatefulWidget {
  final String promoId;
  final VoidCallback onDeleted;

  const _DeleteButton({required this.promoId, required this.onDeleted});

  @override
  ConsumerState<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends ConsumerState<_DeleteButton> {
  bool _loading = false;

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Promoción'),
        content: const Text(
            '¿Estás seguro de que querés eliminar esta promoción?'),
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

    setState(() => _loading = true);
    try {
      await ref
          .read(professionalPromotionsRepositoryProvider)
          .delete(widget.promoId);
      widget.onDeleted();
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
    return IconButton(
      onPressed: _loading ? null : _delete,
      icon: _loading
          ? SizedBox(
              height: 18.r,
              width: 18.r,
              child:
                  const CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
            )
          : Icon(Icons.delete_outline_rounded, size: 22.r, color: Colors.red),
      tooltip: 'Eliminar',
    );
  }
}

// ─── Promotion Form (Create / Edit) ──────────────────────────────────────────

class _PromotionForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? promotionToEdit;
  final VoidCallback onDone;

  const _PromotionForm({this.promotionToEdit, required this.onDone});

  @override
  ConsumerState<_PromotionForm> createState() => _PromotionFormState();
}

class _PromotionFormState extends ConsumerState<_PromotionForm> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _discountValueCtrl = TextEditingController();
  final _applicableToCtrl = TextEditingController();
  String _discountType = 'percentage';
  DateTime? _validFrom;
  DateTime? _validTo;
  bool _unlimitedStock = false;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.promotionToEdit;
    if (p != null) {
      _titleCtrl.text = p['title'] as String? ?? '';
      _descCtrl.text = p['description'] as String? ?? '';
      _discountType = p['discount_type'] as String? ?? 'percentage';
      _discountValueCtrl.text =
          (p['discount_value'] ?? '').toString();
      _applicableToCtrl.text = p['applicable_to'] as String? ?? '';
      _unlimitedStock = p['unlimited_stock'] == true;
      _existingImageUrl = p['image_url'] as String?;
      if (p['from_date'] != null) {
        _validFrom = DateTime.tryParse(p['from_date'] as String);
      }
      if (p['expires_at'] != null) {
        _validTo = DateTime.tryParse(p['expires_at'] as String);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _discountValueCtrl.dispose();
    _applicableToCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_validFrom ?? now) : (_validTo ?? now),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _validFrom = picked;
        } else {
          _validTo = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El título es obligatorio')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        final storageRepo = ref.read(storageRepositoryProvider);
        final config = await storageRepo.getPromotionsConfig();
        final uploadUrl = config?['uploadUrl'] as String?;
        if (uploadUrl != null) {
          final uploadService = ref.read(uploadServiceProvider);
          await uploadService.uploadToPresignedUrl(
              uploadUrl: uploadUrl, file: _imageFile!);
          imageUrl = config?['publicUrl'] as String?;
        }
      }

      final repo = ref.read(professionalPromotionsRepositoryProvider);
      final body = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'discount_type': _discountType,
        'discount_value': double.tryParse(_discountValueCtrl.text) ?? 0,
        'applicable_to': _applicableToCtrl.text.trim(),
        'unlimited_stock': _unlimitedStock,
        'from_date': _validFrom?.toIso8601String(),
        'expires_at': _validTo?.toIso8601String(),
        if (imageUrl != null) 'image_url': imageUrl,
        'state': widget.promotionToEdit?['state'] ?? 'active',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (widget.promotionToEdit != null) {
        await repo.update(
            widget.promotionToEdit!['id'].toString(), body);
      } else {
        body['created_at'] = DateTime.now().toIso8601String();
        await repo.create(body);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.promotionToEdit != null
                ? 'Promoción actualizada'
                : 'Promoción creada exitosamente'),
            backgroundColor: Colors.green));
        widget.onDone();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasImage = _imageFile != null || _existingImageUrl != null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Upload
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: theme.colorScheme.primary.withAlpha(15),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black.withAlpha(30),
                  style: BorderStyle.solid,
                ),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : Image.network(_existingImageUrl!,
                              fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded,
                            size: 40.r,
                            color: theme.colorScheme.primary),
                        SizedBox(height: 8.h),
                        Text('Subir imagen de la promoción',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600)),
                        Text('JPG, PNG hasta 10MB',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 11.sp)),
                      ],
                    ),
            ),
          ),

          SizedBox(height: 20.h),

          // Basic Info Section
          _SectionHeader(label: 'INFORMACIÓN BÁSICA'),
          SizedBox(height: 10.h),
          _TextField(ctrl: _titleCtrl, label: 'Título', hint: 'Ej: Descuento de verano'),
          SizedBox(height: 12.h),
          _TextField(
              ctrl: _descCtrl,
              label: 'Descripción',
              hint: 'Describí los beneficios...',
              maxLines: 3),

          SizedBox(height: 20.h),
          _SectionHeader(label: 'DESCUENTO'),
          SizedBox(height: 10.h),

          // Discount Type
          Text('Tipo de Descuento',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54)),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withAlpha(20)),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _discountType,
                items: _discountTypes
                    .map((t) => DropdownMenuItem<String>(
                          value: t['value'],
                          child: Text(t['label']!),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _discountType = v ?? 'percentage'),
              ),
            ),
          ),

          if (_discountType == 'percentage' ||
              _discountType == 'fixed') ...[
            SizedBox(height: 12.h),
            _TextField(
              ctrl: _discountValueCtrl,
              label: _discountType == 'percentage' ? 'Valor (%)' : 'Valor (\$)',
              hint: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],

          SizedBox(height: 12.h),
          _TextField(
              ctrl: _applicableToCtrl,
              label: 'Aplica a',
              hint: 'Ej: Todos los servicios, pintura, etc.'),

          SizedBox(height: 20.h),
          _SectionHeader(label: 'VIGENCIA Y STOCK'),
          SizedBox(height: 10.h),

          // Date pickers
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Válido desde',
                  date: _validFrom,
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _DateButton(
                  label: 'Válido hasta',
                  date: _validTo,
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          GestureDetector(
            onTap: () =>
                setState(() => _unlimitedStock = !_unlimitedStock),
            child: Row(
              children: [
                Switch.adaptive(
                  value: _unlimitedStock,
                  onChanged: (v) =>
                      setState(() => _unlimitedStock = v),
                ),
                SizedBox(width: 8.w),
                Text('Hasta agotar stock',
                    style: TextStyle(fontSize: 13.sp)),
              ],
            ),
          ),

          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r)),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.r,
                      width: 20.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      widget.promotionToEdit != null
                          ? 'Guardar Cambios'
                          : 'Crear Promoción',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.secondary,
        letterSpacing: 1.3,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _TextField({
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
        SizedBox(height: 6.h),
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
                  color: isDark ? Colors.white10 : Colors.black.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withAlpha(20)),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateButton(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withAlpha(20)),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14.r, color: theme.colorScheme.primary),
                SizedBox(width: 6.w),
                Text(
                  date != null
                      ? date!.toString().substring(0, 10)
                      : 'Seleccionar',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: date != null ? null : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: color),
            ),
            Text(label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.r, color: Colors.grey.withAlpha(80)),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
