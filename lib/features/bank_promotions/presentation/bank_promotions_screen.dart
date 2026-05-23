import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../core/data/models/bank_promotions.model.dart';
import '../../../core/data/providers/bank_promotions_provider.dart';

class BankPromotionsScreen extends ConsumerStatefulWidget {
  const BankPromotionsScreen({super.key});

  @override
  ConsumerState<BankPromotionsScreen> createState() =>
      _BankPromotionsScreenState();
}

class _BankPromotionsScreenState extends ConsumerState<BankPromotionsScreen> {
  String search = '';
  String stateFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bankPromotionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Promociones Bancarias')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          hintText: 'Buscar banco o descripción'),
                      onChanged: (v) => setState(() => search = v),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  DropdownButton<String>(
                    value: stateFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todos')),
                      DropdownMenuItem(value: 'active', child: Text('Activos')),
                      DropdownMenuItem(
                          value: 'inactive', child: Text('Inactivos')),
                    ],
                    onChanged: (v) => setState(() => stateFilter = v ?? 'all'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (list) {
                  final promos = (list as List<BankPromotionModel>?) ?? [];
                  final banksSet = <String>{};
                  for (var p in promos) {
                    for (var b in p.banks) {
                      banksSet.add(b.bank.name);
                    }
                  }
                  final filtered = promos.where((p) {
                    final matchesSearch = search.isEmpty ||
                        p.description
                            .toLowerCase()
                            .contains(search.toLowerCase()) ||
                        p.banks.any((b) => b.bank.name
                            .toLowerCase()
                            .contains(search.toLowerCase()));
                    final matchesState = stateFilter == 'all' ||
                        (stateFilter == 'active' && p.state == 'active') ||
                        (stateFilter == 'inactive' && p.state != 'active');
                    return matchesSearch && matchesState;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No hay promociones'));
                  }

                  return ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final promo = filtered[i];
                      return _BankPromotionCard(promo: promo);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankPromotionCard extends StatelessWidget {
  final BankPromotionModel promo;

  const _BankPromotionCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => context.push('/bank-promotions/${promo.id}'),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(promo.description,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 8.w,
                          children: promo.banks
                              .map((b) => Chip(label: Text(b.bank.name)))
                              .toList(),
                        ),
                        SizedBox(height: 6.h),
                        GestureDetector(
                          onTap: () {
                            if (promo.professional != null) {
                              context.push(
                                  '/specialist/${promo.professional!.id}');
                            }
                          },
                          child: Text(
                            promo.professional?.companies.isNotEmpty == true
                                ? promo.professional!.companies.first.name ?? ''
                                : '',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${promo.percentajeDiscount}% ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.sp)),
                      SizedBox(height: 8.h),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final text =
                              '${promo.description}\nDescuento: ${promo.percentajeDiscount}%\nMás info: ${promo.seoPath ?? ''}';
                          await Clipboard.setData(ClipboardData(text: text));
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Enlace copiado al portapapeles')));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
