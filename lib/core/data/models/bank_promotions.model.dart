import 'dart:convert';

class BankModel {
  final int id;
  final String name;

  BankModel({required this.id, required this.name});

  factory BankModel.fromJson(Map<String, dynamic> json) =>
      BankModel(id: json['id'] as int, name: json['name'] as String? ?? '');

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class BankPromotionBank {
  final BankModel bank;

  BankPromotionBank({required this.bank});

  factory BankPromotionBank.fromJson(Map<String, dynamic> json) =>
      BankPromotionBank(
          bank: BankModel.fromJson(json['Bank'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => {'Bank': bank.toJson()};
}

class CompanySimple {
  final String? name;

  CompanySimple({this.name});

  factory CompanySimple.fromJson(Map<String, dynamic> json) =>
      CompanySimple(name: json['name'] as String?);

  Map<String, dynamic> toJson() => {'name': name};
}

class SubscriptionSimple {
  final String? plan;

  SubscriptionSimple({this.plan});

  factory SubscriptionSimple.fromJson(Map<String, dynamic> json) =>
      SubscriptionSimple(plan: json['plan'] as String?);

  Map<String, dynamic> toJson() => {'plan': plan};
}

class ProfessionalPromo {
  final int id;
  final List<CompanySimple> companies;
  final List<SubscriptionSimple> subscriptions;

  ProfessionalPromo({
    required this.id,
    required this.companies,
    required this.subscriptions,
  });

  factory ProfessionalPromo.fromJson(Map<String, dynamic> json) {
    final compJson = json['Company'] as List<dynamic>?;
    final subJson = json['subscription'] as List<dynamic>?;
    return ProfessionalPromo(
      id: json['id'] as int,
      companies: compJson != null
          ? compJson
              .map((e) => CompanySimple.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      subscriptions: subJson != null
          ? subJson
              .map(
                  (e) => SubscriptionSimple.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'Company': companies.map((c) => c.toJson()).toList(),
        'subscription': subscriptions.map((s) => s.toJson()).toList(),
      };
}

class BankPromotionModel {
  final String id;
  final int percentajeDiscount;
  final int refund;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;
  final DateTime fromDate;
  final DateTime expirationDate;
  final String description;
  final int professionalId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String state;
  final List<String> paymentMethod;
  final String termsConditions;
  final int minimumAmount;
  final bool withInterest;
  final int installments;
  final List<BankPromotionBank> banks;
  final ProfessionalPromo? professional;
  final String? seoPath;

  BankPromotionModel({
    required this.id,
    required this.percentajeDiscount,
    required this.refund,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.fromDate,
    required this.expirationDate,
    required this.description,
    required this.professionalId,
    required this.createdAt,
    required this.updatedAt,
    required this.state,
    required this.paymentMethod,
    required this.termsConditions,
    required this.minimumAmount,
    required this.withInterest,
    required this.installments,
    required this.banks,
    this.professional,
    this.seoPath,
  });

  factory BankPromotionModel.fromJson(Map<String, dynamic> json) {
    // payment_method may be a JSON-encoded string or an actual List
    List<String> parsePaymentMethod(dynamic raw) {
      if (raw == null) return [];
      if (raw is String) {
        try {
          final decoded = jsonDecode(raw) as List<dynamic>;
          return decoded.map((e) => e.toString()).toList();
        } catch (_) {
          return [raw];
        }
      }
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [raw.toString()];
    }

    final banksJson = json['bank_promotions_banks'] as List<dynamic>?;
    return BankPromotionModel(
      id: json['id'] as String? ?? '',
      percentajeDiscount: (json['percentaje_discount'] ?? 0) as int,
      refund: (json['refund'] ?? 0) as int,
      monday: json['monday'] as bool? ?? false,
      tuesday: json['tuesday'] as bool? ?? false,
      wednesday: json['wednesday'] as bool? ?? false,
      thursday: json['thursday'] as bool? ?? false,
      friday: json['friday'] as bool? ?? false,
      saturday: json['saturday'] as bool? ?? false,
      sunday: json['sunday'] as bool? ?? false,
      fromDate: DateTime.tryParse(json['from_date'] as String? ?? '') ??
          DateTime.now(),
      expirationDate:
          DateTime.tryParse(json['expiration_date'] as String? ?? '') ??
              DateTime.now(),
      description: json['description'] as String? ?? '',
      professionalId: json['professional_id'] as int,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      state: json['state'] as String? ?? '',
      paymentMethod: parsePaymentMethod(json['payment_method']),
      termsConditions: json['terms_conditions'] as String? ?? '',
      minimumAmount: (json['minimum_amount'] ?? 0) as int,
      withInterest: json['with_interest'] as bool? ?? false,
      installments: (json['installments'] ?? 0) as int,
      banks: banksJson != null
          ? banksJson
              .map((e) => BankPromotionBank.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      professional: json['Professional'] != null
          ? ProfessionalPromo.fromJson(
              json['Professional'] as Map<String, dynamic>)
          : null,
      seoPath: json['seo_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'percentaje_discount': percentajeDiscount,
        'refund': refund,
        'monday': monday,
        'tuesday': tuesday,
        'wednesday': wednesday,
        'thursday': thursday,
        'friday': friday,
        'saturday': saturday,
        'sunday': sunday,
        'from_date': fromDate.toIso8601String().split('T').first,
        'expiration_date': expirationDate.toIso8601String().split('T').first,
        'description': description,
        'professional_id': professionalId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'state': state,
        'payment_method': paymentMethod,
        'terms_conditions': termsConditions,
        'minimum_amount': minimumAmount,
        'with_interest': withInterest,
        'installments': installments,
        'bank_promotions_banks': banks.map((b) => b.toJson()).toList(),
        'Professional': professional?.toJson(),
        'seo_path': seoPath,
      };
}
