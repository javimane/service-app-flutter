import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app_flutter/core/data/repositories/professional_proposals_repository.dart';
import 'package:service_app_flutter/core/data/repositories/storage_repository.dart';
import 'package:service_app_flutter/core/services/upload_service.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

final _proposalsTabProvider = StateProvider<String>((ref) => 'received');
final _proposalsLoadingProvider = StateProvider<bool>((ref) => true);
final _receivedProposalsProvider = StateProvider<List<dynamic>>((ref) => []);
final _sentProposalsProvider = StateProvider<List<dynamic>>((ref) => []);

// ─── Main Screen ────────────────────────────────────────────────────────────

class DashboardProposalsScreen extends ConsumerStatefulWidget {
  const DashboardProposalsScreen({super.key});

  @override
  ConsumerState<DashboardProposalsScreen> createState() =>
      _DashboardProposalsScreenState();
}

class _DashboardProposalsScreenState
    extends ConsumerState<DashboardProposalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProposals());
  }

  Future<void> _loadProposals() async {
    ref.read(_proposalsLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(professionalProposalsRepositoryProvider);
      final received = await repo.getReceived();
      final sent = await repo.getSent();
      ref.read(_receivedProposalsProvider.notifier).state =
          (received?['data'] as List?) ?? [];
      ref.read(_sentProposalsProvider.notifier).state =
          (sent?['data'] as List?) ?? [];
    } catch (e) {
      debugPrint('Error loading proposals: $e');
    } finally {
      ref.read(_proposalsLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _acceptProposal(String id) async {
    try {
      final repo = ref.read(professionalProposalsRepositoryProvider);
      await repo.accept(id);
      final received = ref.read(_receivedProposalsProvider);
      ref.read(_receivedProposalsProvider.notifier).state = received
          .map((p) => p['id'] == id ? {...p, 'accepted': true} : p)
          .toList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Presupuesto aceptado exitosamente'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al aceptar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeTab = ref.watch(_proposalsTabProvider);
    final isLoading = ref.watch(_proposalsLoadingProvider);
    final received = ref.watch(_receivedProposalsProvider);
    final sent = ref.watch(_sentProposalsProvider);
    final current = activeTab == 'received' ? received : sent;

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
        title: const Text('Presupuestos'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showCreateProposalSheet(context),
            icon: Icon(Icons.add_rounded,
                color: theme.colorScheme.primary, size: 24.r),
            tooltip: 'Nuevo Presupuesto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                _TabChip(
                  label: 'Recibidos',
                  count: received.length,
                  isActive: activeTab == 'received',
                  onTap: () =>
                      ref.read(_proposalsTabProvider.notifier).state =
                          'received',
                ),
                SizedBox(width: 10.w),
                _TabChip(
                  label: 'Enviados',
                  count: sent.length,
                  isActive: activeTab == 'sent',
                  onTap: () =>
                      ref.read(_proposalsTabProvider.notifier).state = 'sent',
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : current.isEmpty
                    ? _EmptyState(
                        icon: Icons.description_outlined,
                        message:
                            'No hay presupuestos ${activeTab == 'received' ? 'recibidos' : 'enviados'} aún.',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProposals,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.r),
                          itemCount: current.length,
                          itemBuilder: (_, i) => _ProposalCard(
                            proposal: current[i],
                            isReceived: activeTab == 'received',
                            onAccept: _acceptProposal,
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProposalSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo Presupuesto'),
      ),
    );
  }

  void _showCreateProposalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateProposalSheet(),
    );
  }
}

// ─── Tab Chip ───────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withAlpha(60),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: isActive ? Colors.white : null,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withAlpha(60)
                    : theme.colorScheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? Colors.white
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Proposal Card ──────────────────────────────────────────────────────────

class _ProposalCard extends StatelessWidget {
  final dynamic proposal;
  final bool isReceived;
  final Future<void> Function(String) onAccept;

  const _ProposalCard({
    required this.proposal,
    required this.isReceived,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAccepted = proposal['accepted'] == true;
    final name = isReceived
        ? (proposal['professional_name'] ?? 'Profesional')
        : (proposal['sent_to'] ?? 'Usuario');
    final dateRaw = proposal['created_at'] as String?;
    final date = dateRaw != null
        ? DateTime.tryParse(dateRaw)
            ?.toLocal()
            .toString()
            .substring(0, 10) ??
            dateRaw
        : '—';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withAlpha(13),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.description_rounded,
                      color: theme.colorScheme.primary, size: 20.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReceived
                            ? 'Recibido de: $name'
                            : 'Enviado a: $name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        'Emitido el $date',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isAccepted
                        ? Colors.green.withAlpha(30)
                        : Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAccepted
                            ? Icons.check_circle_rounded
                            : Icons.access_time_rounded,
                        size: 12.r,
                        color: isAccepted ? Colors.green : Colors.orange,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isAccepted ? 'Aceptado' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isAccepted ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (proposal['title'] != null) ...[
              SizedBox(height: 10.h),
              Text(
                proposal['title'] as String,
                style:
                    TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
            ],

            SizedBox(height: 14.h),

            // Action Buttons
            Row(
              children: [
                if (proposal['file_url'] != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Open URL - implement with url_launcher if available
                      },
                      icon: Icon(Icons.open_in_new_rounded, size: 16.r),
                      label: const Text('Ver Archivo'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                if (isReceived &&
                    !isAccepted &&
                    proposal['file_url'] != null)
                  SizedBox(width: 8.w),
                if (isReceived && !isAccepted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          onAccept(proposal['id'].toString()),
                      icon: Icon(Icons.check_circle_outline_rounded,
                          size: 16.r),
                      label: const Text('Aceptar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Proposal Sheet ──────────────────────────────────────────────────

class _CreateProposalSheet extends ConsumerStatefulWidget {
  const _CreateProposalSheet();

  @override
  ConsumerState<_CreateProposalSheet> createState() =>
      _CreateProposalSheetState();
}

class _CreateProposalSheetState
    extends ConsumerState<_CreateProposalSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    // Uses image_picker to allow picking an image as the proposal attachment
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) {
      setState(() {
        _selectedFile = File(picked.path);
        _fileName = picked.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      String? fileUrl;
      if (_selectedFile != null) {
        final storageRepo = ref.read(storageRepositoryProvider);
        final config = await storageRepo.getProposalsConfig();
        final uploadUrl = config?['uploadUrl'] as String?;
        if (uploadUrl != null) {
          final uploadService = ref.read(uploadServiceProvider);
          await uploadService.uploadToPresignedUrl(
              uploadUrl: uploadUrl, file: _selectedFile!);
          fileUrl = config?['publicUrl'] as String?;
        }
      }

      final repo = ref.read(professionalProposalsRepositoryProvider);
      await repo.create({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'amount': double.tryParse(_amountCtrl.text) ?? 0,
        if (fileUrl != null) 'file_url': fileUrl,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Presupuesto creado exitosamente'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text('Nuevo Presupuesto',
                style: TextStyle(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            Text('GESTIÓN DOCUMENTAL',
                style: TextStyle(
                    fontSize: 10.sp,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            SizedBox(height: 20.h),
            _FormField(
                controller: _titleCtrl,
                label: 'Título del Proyecto',
                hint: 'Ej: Instalación eléctrica completa'),
            SizedBox(height: 12.h),
            _FormField(
                controller: _descCtrl,
                label: 'Descripción',
                hint: 'Detallá el trabajo a realizar...',
                maxLines: 3),
            SizedBox(height: 12.h),
            _FormField(
                controller: _amountCtrl,
                label: 'Monto (\$)',
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
            SizedBox(height: 16.h),

            // File picker
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white24
                        : Colors.black.withAlpha(30),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file_rounded,
                        color: theme.colorScheme.primary, size: 20.r),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _fileName ?? 'Adjuntar archivo (PDF, DOC)',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _fileName != null
                              ? null
                              : Colors.grey,
                        ),
                      ),
                    ),
                    if (_fileName != null)
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 18.r),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.r,
                        width: 20.r,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Crear Presupuesto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Helpers ─────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
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
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
            filled: true,
            fillColor: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withAlpha(20)),
            ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.r, color: Colors.grey.withAlpha(80)),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
