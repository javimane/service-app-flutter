import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/data/providers/session_provider.dart';
import '../../../../core/data/repositories/chat_repository.dart';
import '../../../../core/data/repositories/products_repository.dart';
import '../../../../core/data/repositories/professional_proposals_repository.dart';
import '../../../../core/data/repositories/professionals_repository.dart';
import '../../../../core/data/repositories/storage_repository.dart';
import '../../../../core/services/upload_service.dart';
import '../../../../core/services/pdf_proposal_service.dart';
import '../../../../core/widgets/app_dropdown.dart';
import 'proposal_add_item_screen.dart';

// ─── Providers ──────────────────────────────────────────────────────────────

final _myProfessionalProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(professionalsRepositoryProvider).getMyProfessional();
});

final _chatClientsProvider = FutureProvider.autoDispose((ref) async {
  final session = ref.watch(sessionInfoProvider);
  if (session.userId == null) return [];
  return ref
      .watch(chatRepositoryProvider)
      .getChatClients(userId: session.userId!);
});

final _myProductsProvider = FutureProvider.autoDispose((ref) async {
  final session = ref.watch(sessionInfoProvider);
  if (session.professionalId == null) return [];
  return ref
      .watch(productsRepositoryProvider)
      .getProductsByProfessional(session.professionalId!);
});

// ─── Screen ─────────────────────────────────────────────────────────────────

class ProposalCreatorScreen extends ConsumerStatefulWidget {
  const ProposalCreatorScreen({super.key});

  @override
  ConsumerState<ProposalCreatorScreen> createState() =>
      _ProposalCreatorScreenState();
}

class _ProposalCreatorScreenState extends ConsumerState<ProposalCreatorScreen> {
  // Client
  String? _selectedClientId;
  String _clientSearch = '';

  // Dates
  DateTime? _completionDate;
  DateTime? _expirationDate;

  // Financials
  String _currency = 'ARS';
  double _taxRate = 0.21;
  String _taxMethod = 'added'; // 'added' or 'included'

  // Items
  List<Map<String, dynamic>> _items = [];

  bool _isSending = false;

  String get _currencySymbol => _currency == 'ARS' ? '\$' : 'u\$s';

  double get _itemsSum =>
      _items.fold(0, (sum, item) => sum + (item['total'] as num));

  double get _subtotal {
    if (_taxMethod == 'added') return _itemsSum;
    return _itemsSum / (1 + _taxRate);
  }

  double get _tax {
    if (_taxMethod == 'added') return _itemsSum * _taxRate;
    return _itemsSum - (_itemsSum / (1 + _taxRate));
  }

  double get _total {
    if (_taxMethod == 'added') return _itemsSum + (_itemsSum * _taxRate);
    return _itemsSum;
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _showAddItemModal(BuildContext context) async {
    final newItems = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(builder: (_) => const ProposalAddItemScreen()),
    );

    if (newItems != null && newItems.isNotEmpty) {
      setState(() {
        _items.addAll(newItems);
      });
    }
  }

  Future<void> _generateAndSend(List<dynamic> clientsList) async {
    if (_selectedClientId == null && _clientSearch.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecciona o ingresa un cliente.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes agregar al menos un ítem al presupuesto.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final myProfessional = ref.read(_myProfessionalProvider).value;
      if (myProfessional == null) {
        throw Exception('No se pudo obtener el perfil profesional.');
      }

      // 1. Build Client Info
      Map<String, dynamic>? selectedClientData;
      if (_selectedClientId != null) {
        selectedClientData = clientsList.firstWhere(
          (c) => c['id']?.toString() == _selectedClientId,
          orElse: () => null,
        );
      }

      final clientInfo = {
        'name': selectedClientData?['display_name'] ?? _clientSearch,
        'email': selectedClientData?['email'] ?? '',
        'phone': selectedClientData?['phone'] ?? '',
        'address': selectedClientData?['address'] ?? '',
      };

      // 2. Build Professional Info
      final professionalInfo = {
        'name': myProfessional.displayName ?? myProfessional.name,
        'companyName': myProfessional.companyName ?? '',
        'email': '', // Add email if available in model
        'address': '', // Add address if available
        'avatarUrl': myProfessional.avatarUrl,
      };

      // 3. Generate PDF
      final pdfBytes = await PdfProposalService.generateProposal(
        professional: professionalInfo,
        client: clientInfo,
        items: _items,
        subtotal: _subtotal,
        tax: _tax,
        total: _total,
        currencySymbol: _currencySymbol,
        taxMethod: _taxMethod,
        taxRate: _taxRate,
      );

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/presupuesto.pdf');
      await tempFile.writeAsBytes(pdfBytes);

      // 4. Upload PDF
      final storageRepo = ref.read(storageRepositoryProvider);
      final config = await storageRepo.getProposalsConfig();
      final uploadUrl = config?['uploadUrl'] as String?;
      String? publicUrl;

      if (uploadUrl != null) {
        final uploadService = ref.read(uploadServiceProvider);
        await uploadService.uploadToPresignedUrl(
            uploadUrl: uploadUrl, file: tempFile);
        publicUrl = config?['publicUrl'] as String?;
      }

      if (publicUrl == null) {
        throw Exception('No se pudo obtener la URL de subida.');
      }

      // 5. Create DB Record
      final repo = ref.read(professionalProposalsRepositoryProvider);
      await repo.create({
        'title': 'Presupuesto para ${clientInfo['name']}',
        'description': 'Generado automáticamente desde la app',
        'amount': _total,
        'file_url': publicUrl,
        if (selectedClientData != null) 'user_id': selectedClientData['id'],
        'accepted': false,
        'professional_name': professionalInfo['name'],
      });

      if (mounted) {
        // Show success and share option
        _showSuccessDialog(tempFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al enviar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Presupuesto Enviado!'),
        content: const Text(
            'El presupuesto fue creado, guardado y enviado con éxito.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Share.shareXFiles([XFile(filePath)],
                  text: 'Aquí tienes mi presupuesto.');
            },
            child: const Text('Compartir PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              context.pop(); // Go back to proposals list
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isCompletion) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isCompletion) {
          _completionDate = date;
        } else {
          _expirationDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final chatClientsAsync = ref.watch(_chatClientsProvider);
    final clientsList = chatClientsAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Presupuesto'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- STEP 1: Client ---
                    _SectionHeader(
                        step: '01', title: 'Información del Cliente'),
                    SizedBox(height: 12.h),
                    AppDropdown<String?>(
                      value: _selectedClientId,
                      hint: 'Seleccionar cliente...',
                      isExpanded: true,
                      items: [
                        const AppDropdownItem(value: null, label: 'Cliente manual...'),
                        ...clientsList
                            .map((c) => AppDropdownItem<String?>(
                                  value: c['id']?.toString(),
                                  label: c['display_name'] ?? c['email'] ?? 'Usuario',
                                ))
                            .toList(),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedClientId = val;
                          if (val != null) {
                            final c = clientsList.firstWhere(
                                (x) => x['id']?.toString() == val,
                                orElse: () => null);
                            if (c != null) {
                              _clientSearch =
                                  c['display_name'] ?? c['email'] ?? '';
                            }
                          }
                        });
                      },
                    ),
                    if (_selectedClientId == null) ...[
                      SizedBox(height: 10.h),
                      TextFormField(
                        decoration: _inputDecoration(
                            isDark, 'Nombre del cliente manual'),
                        onChanged: (val) => _clientSearch = val,
                      ),
                    ],

                    SizedBox(height: 24.h),

                    // --- STEP 2: Dates ---
                    _SectionHeader(step: '02', title: 'Plazos del Proyecto'),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _DateSelector(
                            label: 'Finalización Estimada',
                            date: _completionDate,
                            onTap: () => _pickDate(context, true),
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _DateSelector(
                            label: 'Vencimiento',
                            date: _expirationDate,
                            onTap: () => _pickDate(context, false),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // --- STEP 3: Financials ---
                    _SectionHeader(
                        step: '03', title: 'Configuración Financiera'),
                    SizedBox(height: 12.h),
                    AppDropdown<String>(
                      value: _currency,
                      hint: 'Moneda',
                      isExpanded: true,
                      items: const [
                        AppDropdownItem(value: 'ARS', label: 'Pesos (\$)'),
                        AppDropdownItem(value: 'USD', label: 'Dólares (USD)'),
                      ],
                      onChanged: (val) => setState(() => _currency = val),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: AppDropdown<double>(
                            value: _taxRate,
                            hint: 'Tasa de IVA',
                            isExpanded: true,
                            items: const [
                              AppDropdownItem(value: 0.0, label: 'Sin IVA (0%)'),
                              AppDropdownItem(value: 0.105, label: 'IVA 10.5%'),
                              AppDropdownItem(value: 0.21, label: 'IVA 21%'),
                            ],
                            onChanged: (val) => setState(() => _taxRate = val),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: AppDropdown<String>(
                            value: _taxMethod,
                            hint: 'Método de IVA',
                            isExpanded: true,
                            items: const [
                              AppDropdownItem(value: 'added', label: 'Sumar al total'),
                              AppDropdownItem(value: 'included', label: 'Incluido en total'),
                            ],
                            onChanged: (val) => setState(() => _taxMethod = val),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // --- STEP 4: Items ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _SectionHeader(
                              step: '04',
                              title: 'Detalle de Servicios y Productos'),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddItemModal(context),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Añadir Ítem'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    if (_items.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20.r),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(10)
                              : Colors.black.withAlpha(5),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12),
                        ),
                        child: const Text('Aún no se han añadido ítems.',
                            style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx, i) {
                          final item = _items[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item['name']),
                            subtitle: Text(
                                'Cant: ${item['qty']} x $_currencySymbol ${item['rate']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$_currencySymbol ${item['total']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 8.w),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _removeItem(i),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    SizedBox(height: 32.h),

                    // --- Summary ---
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text(
                                  '$_currencySymbol ${_subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'IVA (${(_taxRate * 100).toStringAsFixed(1)}%):'),
                              Text(
                                  '$_currencySymbol ${_tax.toStringAsFixed(2)}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Text(
                                  '$_currencySymbol ${_total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Button
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(10),
                      offset: const Offset(0, -4),
                      blurRadius: 10),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSending ? null : () => _generateAndSend(clientsList),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  icon: _isSending
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                  label: Text(_isSending
                      ? 'Enviando...'
                      : 'GENERAR Y ENVIAR PRESUPUESTO'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
    );

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor:
          isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
      border: border,
      enabledBorder: border,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String step;
  final String title;

  const _SectionHeader({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(30),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text('PASO $step',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool isDark;

  const _DateSelector(
      {required this.label,
      required this.date,
      required this.onTap,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        SizedBox(height: 6.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(5),
              borderRadius: BorderRadius.circular(12.r),
              border:
                  Border.all(color: isDark ? Colors.white24 : Colors.black12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    date != null
                        ? DateFormat('dd/MM/yyyy').format(date!)
                        : 'dd/mm/aaaa',
                    style: TextStyle(
                        color: date != null
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.grey)),
                const Icon(Icons.calendar_today_rounded,
                    size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

