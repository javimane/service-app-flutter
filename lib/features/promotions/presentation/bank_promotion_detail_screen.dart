import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/data/models/bank_promotions.model.dart';
import '../../../core/data/repositories/bank_promotions_repository.dart';

class BankPromotionDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const BankPromotionDetailScreen({super.key, required this.id});

  @override
  ConsumerState<BankPromotionDetailScreen> createState() => _BankPromotionDetailScreenState();
}

class _BankPromotionDetailScreenState extends ConsumerState<BankPromotionDetailScreen> {
  BankPromotionModel? _promo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPromo();
  }

  Future<void> _loadPromo() async {
    try {
      final repo = ref.read(bankPromotionsRepositoryProvider);
      final promo = await repo.getById(widget.id);
      if (mounted) {
        setState(() {
          _promo = promo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar la promoción: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _getDaysString(BankPromotionModel promo) {
    final days = <String>[];
    if (promo.monday) days.add('Lunes');
    if (promo.tuesday) days.add('Martes');
    if (promo.wednesday) days.add('Miércoles');
    if (promo.thursday) days.add('Jueves');
    if (promo.friday) days.add('Viernes');
    if (promo.saturday) days.add('Sábado');
    if (promo.sunday) days.add('Domingo');
    if (days.isEmpty) return 'No especificado';
    if (days.length == 7) return 'Todos los días';
    return days.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _promo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.r, color: Colors.red),
              SizedBox(height: 16.h),
              Text(_error ?? 'Promoción no encontrada'),
              TextButton(
                onPressed: _loadPromo,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _promo!;
    final companyName = p.professional?.companies.isNotEmpty == true 
      ? p.professional!.companies.first.name 
      : 'Profesional';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Promoción', style: TextStyle(fontSize: 18.sp)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('¡Mirá este descuento de ${p.percentajeDiscount}% OFF en $companyName! Encontralo en nuestra app.');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bank and Discount Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_balance, color: Colors.white, size: 48.r),
                  SizedBox(height: 16.h),
                  Text(
                    p.banks.isNotEmpty ? p.banks.map((b) => b.bank.name).join(', ') : 'Banco',
                    style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${p.percentajeDiscount}% OFF',
                    style: TextStyle(color: Colors.white, fontSize: 36.sp, fontWeight: FontWeight.w900),
                  ),
                  if (p.refund > 0)
                    Text(
                      'Tope de reintegro: \$${p.refund}',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Details Card
            Card(
              elevation: 0,
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.storefront,
                      title: 'Comercio/Profesional',
                      value: companyName ?? 'Ver profesional',
                      isLink: true,
                      onTap: () {
                        context.push('/specialist/${p.professionalId}');
                      },
                    ),
                    const Divider(height: 32),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      title: 'Días válidos',
                      value: _getDaysString(p),
                    ),
                    const Divider(height: 32),
                    _DetailRow(
                      icon: Icons.event,
                      title: 'Vigencia',
                      value: 'Hasta el ${DateFormat('dd/MM/yyyy').format(p.expirationDate)}',
                    ),
                    if (p.installments > 0) ...[
                      const Divider(height: 32),
                      _DetailRow(
                        icon: Icons.credit_card,
                        title: 'Cuotas',
                        value: '${p.installments} cuotas ${p.withInterest ? 'con' : 'sin'} interés',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Text('Descripción', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text(
              p.description.isNotEmpty ? p.description : 'Aprovechá este increíble descuento bancario pagando con medios seleccionados.',
              style: TextStyle(fontSize: 15.sp, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
            ),
            
            SizedBox(height: 24.h),
            
            if (p.termsConditions.isNotEmpty) ...[
              Text('Términos y Condiciones', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text(
                p.termsConditions,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
              SizedBox(height: 40.h),
            ]
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isLink;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isLink = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 2.h),
                Text(
                  value, 
                  style: TextStyle(
                    fontSize: 15.sp, 
                    fontWeight: FontWeight.w600,
                    color: isLink ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
              ],
            ),
          ),
          if (isLink)
            Icon(Icons.arrow_forward_ios, size: 14.r, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }
}
