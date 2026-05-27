import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/data/providers/session_provider.dart';
import '../../../../data/services/alert_service.dart';
import 'package:service_app_flutter/core/data/repositories/professional_proposals_repository.dart';
import 'proposal_creator_screen.dart';

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

      List<dynamic> _extractList(dynamic resp) {
        if (resp == null) return [];
        // If API returns a map with `data` field
        if (resp is Map) {
          final data = resp['data'];
          if (data is List) return data;
          if (data is Map) return [data];
        }
        // If it's already a list
        if (resp is List) return resp;
        // If it's a JSON-encoded string, try to decode
        if (resp is String) {
          try {
            final decoded = jsonDecode(resp);
            return _extractList(decoded);
          } catch (_) {
            return [];
          }
        }
        return [];
      }

      ref.read(_receivedProposalsProvider.notifier).state =
          _extractList(received);
      ref.read(_sentProposalsProvider.notifier).state = _extractList(sent);
    } catch (e) {
      debugPrint('Error loading proposals: $e');
      AlertService.showError('Error cargando presupuestos: ${e.toString()}');
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
    final session = ref.watch(sessionInfoProvider);
    final bool canCreateProposal = session.isActive &&
        (session.plan == 'standard' || session.plan == 'premium');
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
          if (canCreateProposal)
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
                  onTap: () => ref.read(_proposalsTabProvider.notifier).state =
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
      floatingActionButton: canCreateProposal
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateProposalSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo Presupuesto'),
            )
          : null,
    );
  }

  void _showCreateProposalSheet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProposalCreatorScreen()),
    ).then((_) => _loadProposals());
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
          color:
              isActive ? theme.colorScheme.primary : theme.colorScheme.surface,
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
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
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
                  color: isActive ? Colors.white : theme.colorScheme.primary,
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
        ? DateTime.tryParse(dateRaw)?.toLocal().toString().substring(0, 10) ??
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
                        isReceived ? 'Recibido de: $name' : 'Enviado a: $name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        'Emitido el $date',
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
                          color: isAccepted ? Colors.green : Colors.orange,
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
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
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
                if (isReceived && !isAccepted && proposal['file_url'] != null)
                  SizedBox(width: 8.w),
                if (isReceived && !isAccepted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onAccept(proposal['id'].toString()),
                      icon:
                          Icon(Icons.check_circle_outline_rounded, size: 16.r),
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

// ─── Shared Helpers ─────────────────────────────────────────────────────────

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
