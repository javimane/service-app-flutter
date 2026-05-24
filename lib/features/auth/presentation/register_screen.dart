import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/notifiers/auth_notifier.dart';
// custom_text_field not used anymore

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _accepted = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa un correo';
    final re = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!re.hasMatch(v)) return 'Correo inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
    if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'La contraseña debe incluir un número';
    }
    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return 'La contraseña debe incluir una minúscula';
    }
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'La contraseña debe incluir una mayúscula';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) {
      return 'La contraseña debe incluir un carácter especial';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes aceptar los términos')));
      return;
    }
    setState(() => _loading = true);
    final router = GoRouter.of(context);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .register(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      router.go('/home');
    } catch (e) {
      final msg = e is Exception ? e.toString() : 'Ocurrió un error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('AUTHENTICATION',
            style: TextStyle(
                letterSpacing: 1.5, fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('OK.SYS',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                  children: [
                    const TextSpan(text: 'ÚNETE AL\n'),
                    TextSpan(
                      text: 'SISTEMA',
                      style: TextStyle(color: theme.colorScheme.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea tu identidad digital premium.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'NOMBRE COMPLETO',
                          hintText: 'Ej. Alex Mercer'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'CORREO ELECTRÓNICO',
                          hintText: 'usuario@obsidian.io'),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'TELÉFONO', hintText: '+34 000 000 000'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'CONTRASEÑA', hintText: '••••••••'),
                      validator: _validatePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _accepted,
                    onChanged: (val) =>
                        setState(() => _accepted = val ?? false),
                    fillColor: WidgetStateProperty.resolveWith(
                        (states) => theme.colorScheme.surface),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Acepto los '),
                          TextSpan(
                            text: 'Términos de Servicio',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' y la '),
                          TextSpan(
                            text: 'Política de Privacidad',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' de Obsidian Kinetic.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(102),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
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
                            Text('CREAR CUENTA'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya eres miembro? ',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.fingerprint,
                color: isDark ? Colors.white30 : Colors.black38),
            Icon(Icons.arrow_forward_rounded,
                color: isDark ? Colors.white30 : Colors.black38),
            Icon(Icons.person_add_alt_1, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
