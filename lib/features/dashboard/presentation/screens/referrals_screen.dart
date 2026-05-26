import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service_app_flutter/core/data/repositories/user_data_bank_repository.dart';

// ─── Referral model ──────────────────────────────────────────────────────────

class _Referral {
  final String id;
  final String referredEmail;
  final DateTime createdAt;

  const _Referral({
    required this.id,
    required this.referredEmail,
    required this.createdAt,
  });
}

// ─── Providers ───────────────────────────────────────────────────────────────

final _referralsLoadingProvider = StateProvider<bool>((ref) => false);
final _referralsListProvider = StateProvider<List<_Referral>>((ref) => []);
final _bankLoadingProvider = StateProvider<bool>((ref) => false);
final _bankExistsProvider = StateProvider<bool>((ref) => false);
final _bankIdProvider = StateProvider<String?>((ref) => null);

// ─── Screen ──────────────────────────────────────────────────────────────────

class DashboardReferralsScreen extends ConsumerStatefulWidget {
  const DashboardReferralsScreen({super.key});

  @override
  ConsumerState<DashboardReferralsScreen> createState() =>
      _DashboardReferralsScreenState();
}

class _DashboardReferralsScreenState
    extends ConsumerState<DashboardReferralsScreen> {
  // Bank
  final _cbuCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  String? _bankError;
  bool _bankSuccess = false;

  // Referral
  final _emailCtrl = TextEditingController();
  String? _referralError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _cbuCtrl.dispose();
    _aliasCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadBank(), _loadReferrals()]);
  }

  Future<void> _loadBank() async {
    ref.read(_bankLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(userDataBankRepositoryProvider);
      final data = await repo.findMy();
      if (data != null) {
        _cbuCtrl.text = data['cbu'] as String? ?? '';
        _aliasCtrl.text = data['alias'] as String? ?? '';
        ref.read(_bankExistsProvider.notifier).state = true;
        ref.read(_bankIdProvider.notifier).state =
            data['id']?.toString();
      }
    } catch (_) {}
    ref.read(_bankLoadingProvider.notifier).state = false;
  }

  Future<void> _loadReferrals() async {
    ref.read(_referralsLoadingProvider.notifier).state = true;
    try {
      // Referrals endpoint not in repositories yet – placeholder empty list
      ref.read(_referralsListProvider.notifier).state = [];
    } catch (_) {}
    ref.read(_referralsLoadingProvider.notifier).state = false;
  }

  Future<void> _saveBankData() async {
    setState(() {
      _bankError = null;
      _bankSuccess = false;
    });

    final cbu = _cbuCtrl.text.trim();
    final alias = _aliasCtrl.text.trim();

    if (!RegExp(r'^\d{22}$').hasMatch(cbu)) {
      setState(() => _bankError = 'El CBU debe tener exactamente 22 dígitos.');
      return;
    }
    if (alias.isEmpty) {
      setState(() => _bankError = 'El Alias es obligatorio.');
      return;
    }

    ref.read(_bankLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(userDataBankRepositoryProvider);
      final bankExists = ref.read(_bankExistsProvider);
      final bankId = ref.read(_bankIdProvider);
      final body = {'cbu': cbu, 'alias': alias};
      if (bankExists && bankId != null) {
        await repo.update(bankId, body);
      } else {
        final result = await repo.create(body);
        ref.read(_bankIdProvider.notifier).state =
            result?['id']?.toString();
        ref.read(_bankExistsProvider.notifier).state = true;
      }
      if (mounted) setState(() => _bankSuccess = true);
      Future.delayed(const Duration(seconds: 3),
          () => mounted ? setState(() => _bankSuccess = false) : null);
    } catch (e) {
      if (mounted) {
        setState(() => _bankError = 'Error al guardar los datos bancarios.');
      }
    } finally {
      ref.read(_bankLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _addReferral() async {
    setState(() => _referralError = null);
    final email = _emailCtrl.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      setState(() => _referralError = 'Ingresá un email válido.');
      return;
    }
    // Referrals create endpoint – placeholder
    try {
      // await ref.read(referralsRepositoryProvider).create({'referred_email': email});
      final current = ref.read(_referralsListProvider);
      ref.read(_referralsListProvider.notifier).state = [
        _Referral(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            referredEmail: email,
            createdAt: DateTime.now()),
        ...current,
      ];
      _emailCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Referido agregado correctamente!'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      setState(
          () => _referralError = 'Error al agregar referido. Verificá el email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bankLoading = ref.watch(_bankLoadingProvider);
    final referrals = ref.watch(_referralsListProvider);
    final referralsLoading = ref.watch(_referralsLoadingProvider);

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
        title: const Text('Referidos'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        theme.colorScheme.primary.withAlpha(40),
                        theme.colorScheme.surface,
                      ]
                    : [
                        theme.colorScheme.primary.withAlpha(15),
                        Colors.white,
                      ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border:
                  Border.all(color: theme.colorScheme.primary.withAlpha(40)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.people_alt_outlined,
                      color: theme.colorScheme.primary, size: 22.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Programa de Referidos',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Invitá colegas y ganá beneficios exclusivos.',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ── Bank data section ─────────────────────────────────────────
          _SectionCard(
            icon: Icons.account_balance_outlined,
            title: 'Datos de Cobro',
            subtitle:
                'Ingresá tu CBU o Alias para recibir los beneficios de tus referidos.',
            isDark: isDark,
            child: Column(
              children: [
                _InputField(
                  ctrl: _cbuCtrl,
                  label: 'CBU (22 dígitos)',
                  hint: '0000000000000000000000',
                  keyboardType: TextInputType.number,
                  maxLength: 22,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 12.h),
                _InputField(
                  ctrl: _aliasCtrl,
                  label: 'Alias',
                  hint: 'Ej: mi.alias.bancario',
                ),
                if (_bankError != null)
                  _ErrorMessage(message: _bankError!),
                if (_bankSuccess)
                  _SuccessMessage(message: 'Datos guardados correctamente'),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: bankLoading ? null : _saveBankData,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: bankLoading
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Guardar Datos',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── Add referral section ──────────────────────────────────────
          _SectionCard(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Mis Referidos',
            subtitle: 'Invitá a un colega ingresando su email.',
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InputField(
                  ctrl: _emailCtrl,
                  label: 'Email del referido',
                  hint: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                if (_referralError != null)
                  _ErrorMessage(message: _referralError!),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addReferral,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Agregar Referido',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('Historial',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                if (referralsLoading)
                  const Center(child: CircularProgressIndicator())
                else if (referrals.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        'Aún no tenés referidos agregados.',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 13.sp),
                      ),
                    ),
                  )
                else
                  ...referrals.map(
                    (r) => Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(8)
                            : Colors.black.withAlpha(4),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withAlpha(13)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 16.r, color: Colors.grey),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(r.referredEmail,
                                style: TextStyle(fontSize: 13.sp)),
                          ),
                          Text(
                            '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 5),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(title,
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(subtitle,
              style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;

  const _InputField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
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
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
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
                  color:
                      isDark ? Colors.white10 : Colors.black.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                  color:
                      isDark ? Colors.white10 : Colors.black.withAlpha(20)),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(18),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16.r),
          SizedBox(width: 6.w),
          Expanded(
              child:
                  Text(message, style: TextStyle(color: Colors.red, fontSize: 12.sp))),
        ],
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  final String message;
  const _SuccessMessage({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(18),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: Colors.green, size: 16.r),
          SizedBox(width: 6.w),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: Colors.green, fontSize: 12.sp))),
        ],
      ),
    );
  }
}
