import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/notifiers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingrese un correo';
    final email = v.trim();
    final regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!regex.hasMatch(email)) return 'Correo inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Ingrese la contraseña';
    if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      router.go('/home');
    } catch (e) {
      if (mounted) {
        messenger
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded,
                      color: theme.colorScheme.primary, size: 40),
                  const SizedBox(width: 8),
                  Text('SERCIO',
                      style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: isDark ? Colors.white : Colors.black87)),
                ],
              ),
              const SizedBox(height: 60),
              Text('Iniciar Sesión',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Ingresa tus credenciales para continuar',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                          labelText: 'CORREO ELECTRÓNICO',
                          hintText: 'nombre@ejemplo.com',
                          suffixIcon: Icon(Icons.alternate_email)),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      validator: _validatePassword,
                      decoration: const InputDecoration(
                          labelText: 'CONTRASEÑA',
                          hintText: '••••••••',
                          suffixIcon: Icon(Icons.lock_outline)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(102),
                        blurRadius: 20,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text('INGRESAR'),
                              SizedBox(width: 8),
                              Icon(Icons.chevron_right)
                            ]),
                ),
              ),
              const SizedBox(height: 48),
              Center(
                  child: Text('O CONTINÚA CON',
                      style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2.0,
                          color: isDark ? Colors.white30 : Colors.black38))),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('GOOGLE'),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor:
                                isDark ? Colors.white : Colors.black,
                            side: BorderSide(
                                color:
                                    isDark ? Colors.white10 : Colors.black12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))))),
                const SizedBox(width: 16),
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.facebook, size: 20),
                        label: const Text('FACEBOOK'),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor:
                                isDark ? Colors.white : Colors.black,
                            side: BorderSide(
                                color:
                                    isDark ? Colors.white10 : Colors.black12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))))),
              ]),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          final router = GoRouter.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _loading = true);
                          try {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .login('test1@test.com', 'Test2026');
                            if (!mounted) return;
                            router.go('/home');
                          } catch (e) {
                            if (mounted)
                              messenger.showSnackBar(SnackBar(
                                  content: Text(
                                      'Error test login: ${e.toString()}')));
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  child: const Text('Login de prueba'),
                ),
              ),
              const SizedBox(height: 48),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('¿No tienes una cuenta? ',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87)),
                TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text('REGÍSTRATE',
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold))),
              ]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Icon(Icons.fingerprint, color: theme.colorScheme.primary),
          Icon(Icons.arrow_forward_rounded,
              color: isDark ? Colors.white30 : Colors.black38),
          Icon(Icons.person_add_alt_1,
              color: isDark ? Colors.white30 : Colors.black38),
        ]),
      ),
    );
  }
}
