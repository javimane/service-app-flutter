import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:service_app_flutter/core/data/models/location_model.dart';

import '../../../core/data/repositories/bank_promotions_repository.dart';
import '../../../core/data/repositories/professional_promotions_repository.dart';
import '../../../core/data/repositories/provinces_repository.dart';
import '../../../core/data/repositories/bank_repository.dart';
import '../../../core/data/models/bank_promotions.model.dart';

class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filters
  int? _selectedProvince;
  int? _selectedBank;
  String? _selectedDay;
  String? _selectedDiscountType;

  // Data
  List<BankPromotionModel> _bankPromos = [];
  List<dynamic> _profPromos = [];
  List<ProvinceModel> _provinces = [];
  List<BankModel> _banks = [];

  bool _isLoading = true;

  final List<String> _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];
  final List<String> _discountTypes = [
    'Percentage',
    'Fixed Amount',
    '2x1',
    'Free Shipping'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // trigger rebuild for filter icon changes
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final bankPromosRepo = ref.read(bankPromotionsRepositoryProvider);
      final profPromosRepo = ref.read(professionalPromotionsRepositoryProvider);
      final provRepo = ref.read(provincesRepositoryProvider);
      final bankRepo = ref.read(bankRepositoryProvider);

      final results = await Future.wait([
        bankPromosRepo
            .findAll(query: {'limit': 100}), // Simplified pagination for mobile
        profPromosRepo.findAllPublic(query: {'limit': 100}),
        provRepo.findAll(),
        bankRepo.findAll(),
      ]);

      if (mounted) {
        setState(() {
          _bankPromos = results[0] as List<BankPromotionModel>;
          _profPromos = results[1] as List<dynamic>;
          _provinces = results[2] as List<ProvinceModel>;
          _banks = results[3] as List<BankModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading promos: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _checkPromoDay(BankPromotionModel p, String day) {
    switch (day) {
      case 'Lunes':
        return p.monday;
      case 'Martes':
        return p.tuesday;
      case 'Miércoles':
        return p.wednesday;
      case 'Jueves':
        return p.thursday;
      case 'Viernes':
        return p.friday;
      case 'Sábado':
        return p.saturday;
      case 'Domingo':
        return p.sunday;
      default:
        return false;
    }
  }

  List<BankPromotionModel> get _filteredBankPromos {
    return _bankPromos.where((p) {
      if (_selectedProvince != null) {
        // Checking direct province ID or via professional address
        // As a simplification for frontend, if backend doesn't filter perfectly, we do basic matching
        // In real app, we might want backend to handle filtering perfectly via query params
      }
      if (_selectedBank != null) {
        final hasBank = p.banks.any((b) => b.bank.id == _selectedBank);
        if (!hasBank) return false;
      }
      if (_selectedDay != null && !_checkPromoDay(p, _selectedDay!)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<dynamic> get _filteredProfPromos {
    return _profPromos.where((p) {
      if (_selectedDiscountType != null &&
          p['discount_type'] != _selectedDiscountType) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          final isBankTab = _tabController.index == 1;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20.w,
              right: 20.w,
              top: 20.h,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filtros',
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Provincias
                  InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Provincia',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedProvince,
                        items: [
                          const DropdownMenuItem<int>(
                              value: null, child: Text('Todas las Provincias')),
                          ..._provinces.map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.name))),
                        ],
                        onChanged: (val) =>
                            setModalState(() => _selectedProvince = val),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  if (isBankTab) ...[
                    // Bancos
                    InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Banco',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedBank,
                          items: [
                            const DropdownMenuItem<int>(
                                value: null, child: Text('Todos los Bancos')),
                            ..._banks.map((b) => DropdownMenuItem(
                                value: b.id, child: Text(b.name))),
                          ],
                          onChanged: (val) =>
                              setModalState(() => _selectedBank = val),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Días
                    InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Día',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedDay,
                          items: [
                            const DropdownMenuItem<String>(
                                value: null, child: Text('Cualquier Día')),
                            ..._days.map((d) =>
                                DropdownMenuItem(value: d, child: Text(d))),
                          ],
                          onChanged: (val) =>
                              setModalState(() => _selectedDay = val),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Tipos de descuento
                    InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Tipo de Descuento',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedDiscountType,
                          items: [
                            const DropdownMenuItem<String>(
                                value: null, child: Text('Todos los Tipos')),
                            ..._discountTypes.map((d) =>
                                DropdownMenuItem(value: d, child: Text(d))),
                          ],
                          onChanged: (val) =>
                              setModalState(() => _selectedDiscountType = val),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedProvince = null;
                              _selectedBank = null;
                              _selectedDay = null;
                              _selectedDiscountType = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h)),
                          child: const Text('Limpiar'),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Apply to main screen
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: const Text('Aplicar Filtros'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text('Promociones',
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.filter_list_rounded,
                        color: theme.colorScheme.primary),
                    onPressed: _showFilters,
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.withAlpha(26),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Imperdibles'),
                  Tab(text: 'Bancarias'),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Imperdibles tab - professional promotions
                        _filteredProfPromos.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                itemCount: _filteredProfPromos.length,
                                itemBuilder: (_, i) {
                                  final promo = _filteredProfPromos[i];
                                  return _PromoCard(promo: promo);
                                },
                              ),

                        // Bancarias tab - 2 columns grid
                        _filteredBankPromos.isEmpty
                            ? _buildEmptyState()
                            : GridView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: _filteredBankPromos.length,
                                itemBuilder: (_, i) {
                                  return _BankPromoCard(
                                      promo: _filteredBankPromos[i]);
                                },
                              ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48.r, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'No se encontraron resultados',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Intentá ajustar los filtros.',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final dynamic promo;

  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final id = promo['id'];
    final title = promo['title'] ?? 'Promoción';
    final description = promo['description'] ?? '';
    final discountType = promo['discount_type'] ?? '';
    final discountValue = promo['discount_value'] ?? '';
    final imageUrl = promo['image_url'] ??
        'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&q=80&w=600';

    final professional = promo['Professional'] as Map<String, dynamic>?;
    final companyName =
        (professional?['Company'] as List<dynamic>?)?.isNotEmpty == true
            ? professional!['Company'][0]['name']
            : 'Profesional';

    String tag = '';
    if (discountType.toString().toLowerCase() == 'percentage') {
      tag = '$discountValue% OFF';
    } else if (discountType.toString().toLowerCase() == 'fixed') {
      tag = '\$$discountValue OFF';
    } else {
      tag = discountValue.toString();
    }

    return GestureDetector(
      onTap: () => context.push('/professional-promotions/$id'),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withAlpha((isDark ? 0.2 : 0.06 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: Image.network(
                    imageUrl,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160.h,
                      color: Colors.grey,
                      child: const Icon(Icons.image,
                          color: Colors.white, size: 40),
                    ),
                  ),
                ),
                if (tag.isNotEmpty)
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            color: Colors.black87),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankPromoCard extends StatelessWidget {
  final BankPromotionModel promo;

  const _BankPromoCard({required this.promo});

  List<String> _getActiveDays(BankPromotionModel p) {
    final days = <String>[];
    if (p.monday) days.add('Lu');
    if (p.tuesday) days.add('Ma');
    if (p.wednesday) days.add('Mi');
    if (p.thursday) days.add('Ju');
    if (p.friday) days.add('Vi');
    if (p.saturday) days.add('Sa');
    if (p.sunday) days.add('Do');
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryBankName =
        promo.banks.isNotEmpty ? promo.banks.first.bank.name : 'Banco';

    final companyName = promo.professional?.companies.isNotEmpty == true
        ? promo.professional!.companies.first.name
        : 'Profesional';

    final activeDays = _getActiveDays(promo);

    return GestureDetector(
      onTap: () => context.push('/bank-promotions/${promo.id}'),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary
                  .withAlpha((isDark ? 0.8 : 0.9 * 255).round()),
              theme.colorScheme.secondary
                  .withAlpha((isDark ? 0.6 : 0.7 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 16.r),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    primaryBankName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              companyName ?? 'Comercio',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              promo.description,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              '${promo.percentajeDiscount}% OFF',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: activeDays
                        .map((day) => Container(
                              width: 20.r,
                              height: 20.r,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w900),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                if (promo.installments > 0) ...[
                  SizedBox(width: 4.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${promo.installments} cuotas',
                      style: TextStyle(color: Colors.white, fontSize: 9.sp),
                    ),
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }
}
