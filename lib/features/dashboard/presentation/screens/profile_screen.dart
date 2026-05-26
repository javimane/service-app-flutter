import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/data/models/professional_model.dart';
import '../../../../core/data/repositories/professionals_repository.dart';

class DashboardProfileScreen extends ConsumerStatefulWidget {
  const DashboardProfileScreen({super.key});

  @override
  ConsumerState<DashboardProfileScreen> createState() =>
      _DashboardProfileScreenState();
}

class _DashboardProfileScreenState
    extends ConsumerState<DashboardProfileScreen> {
  bool _loading = true;
  bool _saving = false;
  // ignore: unused_field
  ProfessionalModel? _professional;

  final _bioCtrl = TextEditingController();
  final _webCtrl = TextEditingController();
  bool _isMatriculate = false;
  bool _emergency = false;

  File? _newAvatar;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(professionalsRepositoryProvider);
      final prof = await repo.getMyProfessional();
      if (prof != null) {
        _professional = prof;
        _bioCtrl.text = prof.bio ?? '';
        _webCtrl.text = prof.webUrl ?? '';
        _isMatriculate = prof.isMatriculate ?? false;
        _emergency = prof.emergency ?? false;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newAvatar = File(picked.path);
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Si hubiera endpoint para actualizar la info en professionalsRepositoryProvider, se usaría acá.
      // Actualmente no existe un update() explícito en ese repositorio del template, pero se agregaría así.
      // Mocked save:
      await Future.delayed(const Duration(seconds: 1));

      // Upload avatar logic si aplica:
      if (_newAvatar != null) {
        // final storageConfig = await ref.read(storageRepositoryProvider).getProfileImagesConfig();
        // final uploadUrl = storageConfig?['uploadUrl'];
        // if (uploadUrl != null) {
        //   await ref.read(uploadServiceProvider).uploadToPresignedUrl(uploadUrl: uploadUrl, file: _newAvatar!);
        // }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Perfil guardado correctamente'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
        title: const Text('Mi Perfil'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: _saving
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(strokeWidth: 2.r))
                : const Icon(Icons.check_rounded),
            onPressed: _saving || _loading ? null : _save,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                // ── Hero Avatar ────────────────────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100.r,
                        height: 100.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                          border: Border.all(
                              color: theme.dividerColor.withAlpha(50)),
                          image: _newAvatar != null
                              ? DecorationImage(
                                  image: FileImage(_newAvatar!),
                                  fit: BoxFit.cover)
                              : (_professional?.avatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_professional!.avatarUrl!),
                                      fit: BoxFit.cover)
                                  : null),
                        ),
                        child: _newAvatar == null && _professional?.avatarUrl == null
                            ? Icon(Icons.person_rounded,
                                size: 50.r, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickAvatar,
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2.r),
                            ),
                            child: Icon(Icons.camera_alt_rounded,
                                size: 16.r, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    _professional?.name ?? 'Mi Nombre',
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 4.h),
                Center(
                  child: Text(
                    'Perfil Profesional',
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                ),
                SizedBox(height: 32.h),

                // ── Editor ─────────────────────────────────────────────────────
                Text('Datos profesionales',
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),

                // Bio
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Descripción / Bio',
                    hintText:
                        'Contá qué hacés, tu experiencia y qué te diferencia.',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 16.h),

                // Web
                TextFormField(
                  controller: _webCtrl,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'Sitio Web / Portfolio',
                    prefixIcon: const Icon(Icons.link_rounded),
                    hintText: 'https://tusitio.com',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 16.h),

                // Switches
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withAlpha(20)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Profesional Matriculado'),
                        subtitle: const Text(
                            'Mostrá que tenés matrícula habilitante.'),
                        value: _isMatriculate,
                        onChanged: (v) => setState(() => _isMatriculate = v),
                        activeTrackColor: theme.colorScheme.primary.withAlpha(128),
                        activeThumbColor: theme.colorScheme.primary,
                      ),
                      Divider(
                          height: 1, color: theme.dividerColor.withAlpha(50)),
                      SwitchListTile(
                        title: const Text('Atención de Urgencias'),
                        subtitle: const Text('Aceptás consultas de emergencia.'),
                        value: _emergency,
                        onChanged: (v) => setState(() => _emergency = v),
                        activeTrackColor: theme.colorScheme.primary.withAlpha(128),
                        activeThumbColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving || _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _saving
                        ? const CircularProgressIndicator()
                        : const Text('Guardar cambios',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}
