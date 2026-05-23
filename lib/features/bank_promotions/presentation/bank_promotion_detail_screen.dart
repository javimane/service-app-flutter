import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/data/providers/bank_promotions_provider.dart';

class BankPromotionDetailScreen extends ConsumerWidget {
  final String id;

  const BankPromotionDetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bankPromotionProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Promo')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (promo) {
          final p = promo;
          return Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.description,
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text('Descuento: ${p.percentajeDiscount}%'),
                SizedBox(height: 8.h),
                Text(
                    'Válida desde: ${p.fromDate.toIso8601String().split('T').first} hasta: ${p.expirationDate.toIso8601String().split('T').first}'),
                SizedBox(height: 8.h),
                Text('Monto mínimo: ${p.minimumAmount}'),
                SizedBox(height: 8.h),
                Text('Formas de pago: ${p.paymentMethod.join(', ')}'),
                SizedBox(height: 8.h),
                Text('Términos: ${p.termsConditions}'),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Compartir'),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final text =
                              '${p.description}\nDescuento: ${p.percentajeDiscount}%\nMás info: ${p.seoPath ?? ''}';
                          await Clipboard.setData(ClipboardData(text: text));
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Enlace copiado al portapapeles')));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
