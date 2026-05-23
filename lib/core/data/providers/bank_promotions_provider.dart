import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/bank_promotions_repository.dart';

final bankPromotionsProvider = FutureProvider.autoDispose<List>((ref) async {
  final repo = ref.read(bankPromotionsRepositoryProvider);
  return repo.findAll();
});

final bankPromotionProvider =
    FutureProvider.family.autoDispose((ref, String id) async {
  final repo = ref.read(bankPromotionsRepositoryProvider);
  return repo.getById(id);
});
