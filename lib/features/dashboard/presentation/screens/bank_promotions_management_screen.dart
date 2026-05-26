import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/data/models/bank_promotions.model.dart';
import '../../../../core/data/repositories/bank_promotions_repository.dart';
import '../../../../core/data/repositories/bank_repository.dart';

class DashboardBankPromotionsScreen extends ConsumerStatefulWidget {
  const DashboardBankPromotionsScreen({super.key});

  @override
  ConsumerState<DashboardBankPromotionsScreen> createState() =>
      _DashboardBankPromotionsScreenState();
}

class _DashboardBankPromotionsScreenState
    extends ConsumerState<DashboardBankPromotionsScreen> {
  bool _loading = true;
  List<BankPromotionModel> _promotions = [];
  List<BankModel> _banks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final promosFuture =
          ref.read(bankPromotionsRepositoryProvider).findMyPromotions();
      final banksFuture = ref.read(bankRepositoryProvider).findAll();

      final results = await Future.wait([promosFuture, banksFuture]);
      _promotions = results[0] as List<BankPromotionModel>;
      _banks = results[1] as List<BankModel>;
    } catch (e) {
      debugPrint('Error loading bank promotions: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openForm([BankPromotionModel? promo]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BankPromotionFormSheet(
        promo: promo,
        banks: _banks,
        onSaved: () {
          _loadData();
        },
      ),
    );
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar promoción'),
        content: const Text('¿Estás seguro de eliminar esta promoción?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(bankPromotionsRepositoryProvider).delete(id);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: const Text('Promos Bancarias'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _promotions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_rounded,
                          size: 64.r, color: Colors.grey.withAlpha(100)),
                      SizedBox(height: 16.h),
                      Text('Sin promociones activas',
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      Text(
                          'Configura promociones de bancos y billeteras\npara tus clientes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.grey)),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Crear Primera Promoción'),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 12.h)),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: _promotions.length,
                  itemBuilder: (context, index) {
                    final promo = _promotions[index];
                    final isExpired =
                        promo.expirationDate.isBefore(DateTime.now());

                    final bankNames = promo.banks.isNotEmpty
                        ? promo.banks.map((b) => b.bank.name).toList()
                        : ['Banco general'];
                    final primaryName = bankNames.first;
                    final extraBanks = bankNames.length - 1;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                            color: isExpired
                                ? Colors.red.withAlpha(60)
                                : theme.dividerColor.withAlpha(50)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 30 : 5),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: isExpired
                                  ? Colors.red.withAlpha(10)
                                  : theme.colorScheme.primary.withAlpha(15),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.r)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.account_balance_rounded,
                                      size: 18.r,
                                      color: theme.colorScheme.primary),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$primaryName${extraBanks > 0 ? ' +$extraBanks' : ''}',
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (promo.description.isNotEmpty)
                                        Text(promo.description,
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                if (isExpired)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                    ),
                                    child: Text('Expirado',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ),
                          // Body
                          Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              children: [
                                _InfoRow(
                                    icon: Icons.percent_rounded,
                                    label: 'Descuento',
                                    value: '${promo.percentajeDiscount}% OFF',
                                    highlight: true),
                                _InfoRow(
                                    icon: Icons.money_off_rounded,
                                    label: 'Tope de reintegro',
                                    value: '\$${promo.refund}'),
                                if (promo.minimumAmount > 0)
                                  _InfoRow(
                                      icon: Icons.account_balance_wallet_rounded,
                                      label: 'Compra mínima',
                                      value: '\$${promo.minimumAmount}'),
                                if (promo.installments > 0)
                                  _InfoRow(
                                      icon: Icons.credit_card_rounded,
                                      label: 'Cuotas',
                                      value:
                                          '${promo.installments} cuotas ${promo.withInterest ? 'con interés' : 'sin interés'}'),
                                _InfoRow(
                                    icon: Icons.calendar_today_rounded,
                                    label: 'Vigencia',
                                    value:
                                        '${promo.fromDate.day}/${promo.fromDate.month} al ${promo.expirationDate.day}/${promo.expirationDate.month}'),
                                SizedBox(height: 12.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_rounded,
                                          size: 20.r, color: Colors.blue),
                                      onPressed: () => _openForm(promo),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_rounded,
                                          size: 20.r, color: Colors.red),
                                      onPressed: () => _delete(promo.id),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: _promotions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva Promo'),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _BankPromotionFormSheet extends ConsumerStatefulWidget {
  final BankPromotionModel? promo;
  final List<BankModel> banks;
  final VoidCallback onSaved;

  const _BankPromotionFormSheet({
    this.promo,
    required this.banks,
    required this.onSaved,
  });

  @override
  ConsumerState<_BankPromotionFormSheet> createState() =>
      _BankPromotionFormSheetState();
}

class _BankPromotionFormSheetState
    extends ConsumerState<_BankPromotionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  late TextEditingController _discountCtrl;
  late TextEditingController _refundCtrl;
  late TextEditingController _minAmountCtrl;
  late TextEditingController _installmentsCtrl;
  late TextEditingController _descCtrl;

  List<int> _selectedBankIds = [];
  bool _withInterest = false;
  late DateTime _fromDate;
  late DateTime _expirationDate;

  final Map<String, bool> _days = {
    'monday': false,
    'tuesday': false,
    'wednesday': false,
    'thursday': false,
    'friday': false,
    'saturday': false,
    'sunday': false,
  };

  @override
  void initState() {
    super.initState();
    final p = widget.promo;
    _discountCtrl =
        TextEditingController(text: p?.percentajeDiscount.toString() ?? '');
    _refundCtrl = TextEditingController(text: p?.refund.toString() ?? '');
    _minAmountCtrl =
        TextEditingController(text: p?.minimumAmount.toString() ?? '');
    _installmentsCtrl = TextEditingController(
        text: p != null && p.installments > 0 ? p.installments.toString() : '');
    _descCtrl = TextEditingController(text: p?.description ?? '');

    _withInterest = p?.withInterest ?? false;
    _fromDate = p?.fromDate ?? DateTime.now();
    _expirationDate = p?.expirationDate ??
        DateTime.now().add(const Duration(days: 30));

    if (p != null) {
      _days['monday'] = p.monday;
      _days['tuesday'] = p.tuesday;
      _days['wednesday'] = p.wednesday;
      _days['thursday'] = p.thursday;
      _days['friday'] = p.friday;
      _days['saturday'] = p.saturday;
      _days['sunday'] = p.sunday;
      _selectedBankIds = p.banks.map((b) => b.bank.id).toList();
    }
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    _refundCtrl.dispose();
    _minAmountCtrl.dispose();
    _installmentsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart ? _fromDate : _expirationDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _fromDate = picked;
          if (_expirationDate.isBefore(_fromDate)) {
            _expirationDate = _fromDate.add(const Duration(days: 1));
          }
        } else {
          _expirationDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBankIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione al menos un banco')));
      return;
    }
    if (!_days.values.any((v) => v)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione al menos un día')));
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(bankPromotionsRepositoryProvider);

      final payload = {
        'percentaje_discount': int.tryParse(_discountCtrl.text) ?? 0,
        'refund': int.tryParse(_refundCtrl.text) ?? 0,
        'minimum_amount': int.tryParse(_minAmountCtrl.text) ?? 0,
        'installments': int.tryParse(_installmentsCtrl.text) ?? 0,
        'with_interest': _withInterest,
        'description': _descCtrl.text.trim(),
        'from_date': _fromDate.toIso8601String(),
        'expiration_date': _expirationDate.toIso8601String(),
        'bankIds': _selectedBankIds,
        'monday': _days['monday'],
        'tuesday': _days['tuesday'],
        'wednesday': _days['wednesday'],
        'thursday': _days['thursday'],
        'friday': _days['friday'],
        'saturday': _days['saturday'],
        'sunday': _days['sunday'],
      };

      if (widget.promo != null) {
        await repo.update(widget.promo!.id, payload);
      } else {
        await repo.create(payload);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.promo != null
                          ? 'Editar Promoción'
                          : 'Nueva Promoción',
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                SizedBox(height: 16.h),

                // Bancos
                Text('Bancos',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: widget.banks.map((b) {
                    final isSel = _selectedBankIds.contains(b.id);
                    return FilterChip(
                      selected: isSel,
                      label: Text(b.name, style: TextStyle(fontSize: 12.sp)),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedBankIds.add(b.id);
                          } else {
                            _selectedBankIds.remove(b.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),

                // Descuento y Reintegro
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Descuento (%)',
                          prefixIcon: const Icon(Icons.percent_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: _refundCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Tope reintegro (\$)',
                          prefixIcon: const Icon(Icons.money_off_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Cuotas
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _installmentsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cuotas (Opcional)',
                          prefixIcon: const Icon(Icons.credit_card_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Con interés',
                            style: TextStyle(fontSize: 13.sp)),
                        value: _withInterest,
                        onChanged: (v) =>
                            setState(() => _withInterest = v ?? false),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Mínimo y Desc
                TextFormField(
                  controller: _minAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Compra mínima (\$)',
                    prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Descripción corta',
                    prefixIcon: const Icon(Icons.description_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 16.h),

                // Fechas
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Desde',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                              '${_fromDate.day}/${_fromDate.month}/${_fromDate.year}'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Hasta',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                              '${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Días
                Text('Días de aplicación',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    _dayChip('L', 'monday'),
                    _dayChip('M', 'tuesday'),
                    _dayChip('X', 'wednesday'),
                    _dayChip('J', 'thursday'),
                    _dayChip('V', 'friday'),
                    _dayChip('S', 'saturday'),
                    _dayChip('D', 'sunday'),
                  ],
                ),
                SizedBox(height: 24.h),

                // Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r))),
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Guardar Promoción',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayChip(String label, String key) {
    final isSel = _days[key]!;
    return FilterChip(
      selected: isSel,
      label: Text(label),
      onSelected: (val) => setState(() => _days[key] = val),
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
    );
  }
}
