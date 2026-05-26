import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:service_app_flutter/core/data/repositories/reels_repository.dart';
import 'package:service_app_flutter/core/data/repositories/video_repository.dart';
import 'package:service_app_flutter/core/services/upload_service.dart';

// ─── Model ─────────────────────────────────────────────────────────────────

class _ReelItem {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final int views;
  final int likes;

  const _ReelItem({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.views,
    required this.likes,
  });

  factory _ReelItem.fromJson(Map<String, dynamic> json) => _ReelItem(
        id: json['id'].toString(),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        videoUrl: json['video_url'] as String? ?? '',
        views: json['views_count'] as int? ?? 0,
        likes: json['likes'] as int? ?? 0,
      );
}

String _compact(int n) =>
    n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

// ─── Providers ─────────────────────────────────────────────────────────────

final _reelsLoadingProvider = StateProvider<bool>((ref) => true);
final _reelsListProvider = StateProvider<List<_ReelItem>>((ref) => []);
final _totalViewsProvider = StateProvider<int>((ref) => 0);
final _totalLikesProvider = StateProvider<int>((ref) => 0);
final _reelsStatusMsgProvider = StateProvider<String?>((ref) => null);

// ─── Screen ─────────────────────────────────────────────────────────────────

class DashboardReelsScreen extends ConsumerStatefulWidget {
  const DashboardReelsScreen({super.key});

  @override
  ConsumerState<DashboardReelsScreen> createState() =>
      _DashboardReelsScreenState();
}

class _DashboardReelsScreenState
    extends ConsumerState<DashboardReelsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    ref.read(_reelsLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(reelsRepositoryProvider);
      final raw = await repo.findAll();
      final list = (raw is List
              ? raw
              : (raw is Map ? raw['data'] as List? ?? [] : []))
          .cast<dynamic>()
          .map((r) => _ReelItem.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
      ref.read(_reelsListProvider.notifier).state = list;
      ref.read(_totalViewsProvider.notifier).state =
          list.fold(0, (sum, r) => sum + r.views);
      ref.read(_totalLikesProvider.notifier).state =
          list.fold(0, (sum, r) => sum + r.likes);
    } catch (e) {
      debugPrint('Error loading reels: $e');
    } finally {
      ref.read(_reelsLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _deleteReel(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Reel'),
        content: const Text(
            '¿Estás seguro de que querés eliminar este reel? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(reelsRepositoryProvider).delete(id);
      final current = ref.read(_reelsListProvider);
      ref.read(_reelsListProvider.notifier).state =
          current.where((r) => r.id != id).toList();
      ref.read(_reelsStatusMsgProvider.notifier).state =
          'El reel fue eliminado correctamente.';
    } catch (e) {
      ref.read(_reelsStatusMsgProvider.notifier).state =
          'Error al eliminar el reel: $e';
    }
  }

  void _openUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadReelSheet(
        onUploaded: (reel) {
          final current = ref.read(_reelsListProvider);
          ref.read(_reelsListProvider.notifier).state = [reel, ...current];
          ref.read(_reelsStatusMsgProvider.notifier).state =
              'El reel se publicó y se guardó correctamente.';
        },
        onProcessing: () {
          ref.read(_reelsStatusMsgProvider.notifier).state =
              'Procesando... te notificaremos cuando esté listo.';
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = ref.watch(_reelsLoadingProvider);
    final reels = ref.watch(_reelsListProvider);
    final totalViews = ref.watch(_totalViewsProvider);
    final totalLikes = ref.watch(_totalLikesProvider);
    final statusMsg = ref.watch(_reelsStatusMsgProvider);

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
        title: const Text('Mis Reels'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _openUploadSheet,
            icon: Icon(Icons.add_rounded,
                color: theme.colorScheme.primary, size: 20.r),
            label: Text('Crear Reel',
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20.r),
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
                          theme.colorScheme.primary.withAlpha(18),
                          Colors.white,
                        ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contenido en video',
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  SizedBox(height: 4.h),
                  Text(
                    'Gestioná tus reels desde un solo lugar',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Subí nuevos videos, revisá el rendimiento y mantené tu perfil activo.',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                  SizedBox(height: 16.h),

                  // Stats row
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.play_circle_outline_rounded,
                        label: 'Reels activos',
                        value: '${reels.length}',
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 8.w),
                      _StatPill(
                        icon: Icons.visibility_outlined,
                        label: 'Visualizaciones',
                        value: _compact(totalViews),
                        color: Colors.blueAccent,
                      ),
                      SizedBox(width: 8.w),
                      _StatPill(
                        icon: Icons.favorite_border_rounded,
                        label: 'Me gusta',
                        value: _compact(totalLikes),
                        color: Colors.pink,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Status message
          if (statusMsg != null)
            SliverToBoxAdapter(
              child: Container(
                margin:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: theme.colorScheme.primary, size: 16.r),
                    SizedBox(width: 8.w),
                    Expanded(
                        child: Text(statusMsg,
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: theme.colorScheme.primary))),
                    IconButton(
                      onPressed: () => ref
                          .read(_reelsStatusMsgProvider.notifier)
                          .state = null,
                      icon: const Icon(Icons.close, size: 16),
                      color: theme.colorScheme.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),

          // Grid title
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            sliver: SliverToBoxAdapter(
              child: Text('Tus reels creados',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),

          // Content
          isLoading
              ? SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200.h,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                )
              : reels.isEmpty
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        height: 220.h,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_library_outlined,
                                  size: 64.r,
                                  color: Colors.grey.withAlpha(80)),
                              SizedBox(height: 14.h),
                              Text(
                                'No tenés reels todavía\nHacé clic en "Crear Reel" para subir tu primer video.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.sp),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20.h),
                              ElevatedButton.icon(
                                onPressed: _openUploadSheet,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Crear mi primer Reel'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 4.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _ReelCard(
                            reel: reels[i],
                            onDelete: () => _deleteReel(reels[i].id),
                          ),
                          childCount: reels.length,
                        ),
                      ),
                    ),
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadSheet,
        icon: const Icon(Icons.video_call_rounded),
        label: const Text('Crear Reel'),
      ),
    );
  }
}

// ─── Reel Card ─────────────────────────────────────────────────────────────

class _ReelCard extends StatefulWidget {
  final _ReelItem reel;
  final VoidCallback onDelete;

  const _ReelCard({required this.reel, required this.onDelete});

  @override
  State<_ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<_ReelCard> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.reel.videoUrl.isNotEmpty) {
      _ctrl = VideoPlayerController.networkUrl(
          Uri.parse(widget.reel.videoUrl))
        ..initialize().then((_) {
          if (mounted) setState(() => _initialized = true);
        });
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.black.withAlpha(13)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isDark ? 25 : 6),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player area
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            child: _initialized && _ctrl != null
                ? AspectRatio(
                    aspectRatio: _ctrl!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_ctrl!),
                        GestureDetector(
                          onTap: () => setState(() {
                            _ctrl!.value.isPlaying
                                ? _ctrl!.pause()
                                : _ctrl!.play();
                          }),
                          child: AnimatedOpacity(
                            opacity: _ctrl!.value.isPlaying ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 30.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 180.h,
                    color: Colors.black12,
                    child: Center(
                      child: Icon(Icons.video_file_outlined,
                          size: 40.r, color: Colors.grey.withAlpha(100)),
                    ),
                  ),
          ),

          // Info
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reel.title.isEmpty ? 'Sin título' : widget.reel.title,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
                if (widget.reel.description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    widget.reel.description,
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 15.r, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(_compact(widget.reel.views),
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    SizedBox(width: 12.w),
                    Icon(Icons.favorite_border_rounded,
                        size: 15.r, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(_compact(widget.reel.likes),
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: widget.onDelete,
                      icon: Icon(Icons.delete_outline_rounded,
                          size: 15.r, color: Colors.red),
                      label: Text('Eliminar',
                          style: TextStyle(
                              color: Colors.red, fontSize: 12.sp)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upload Reel Sheet ─────────────────────────────────────────────────────

class _UploadReelSheet extends ConsumerStatefulWidget {
  final void Function(_ReelItem) onUploaded;
  final VoidCallback onProcessing;

  const _UploadReelSheet(
      {required this.onUploaded, required this.onProcessing});

  @override
  ConsumerState<_UploadReelSheet> createState() =>
      _UploadReelSheetState();
}

class _UploadReelSheetState extends ConsumerState<_UploadReelSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  File? _selectedFile;
  bool _isPublishing = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_selectedFile == null || _titleCtrl.text.trim().isEmpty) return;
    setState(() => _isPublishing = true);

    // Close sheet immediately and notify processing
    if (mounted) Navigator.pop(context);
    widget.onProcessing();

    try {
      // 1. Get presigned upload URL for the video
      final videoRepo = ref.read(videoRepositoryProvider);
      final uploadData = await videoRepo.getUploadUrl({
        'fileName': _selectedFile!.path.split('/').last,
        'fileType': 'video/mp4',
        'type': 'REEL',
      });
      final uploadUrl = uploadData?['uploadUrl'] as String?;
      final key = uploadData?['key'] as String?;
      if (uploadUrl == null || key == null) {
        throw Exception('No se pudo obtener la URL de subida del reel.');
      }

      // 2. Upload video to S3
      await ref.read(uploadServiceProvider).uploadToPresignedUrl(
            uploadUrl: uploadUrl,
            file: _selectedFile!,
          );

      // 3. Create reel record
      final reelsRepo = ref.read(reelsRepositoryProvider);
      final created = await reelsRepo.create({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'video_url': key,
      });

      // 4. Poll until activated (max 10 attempts * 6s = 60s)
      final createdId = (created as Map?)?['id']?.toString() ?? '';
      dynamic activatedReel = created;
      if (createdId.isNotEmpty) {
        for (var attempt = 0; attempt < 10; attempt++) {
          if ((activatedReel as Map?)?['activate'] == true) break;
          await Future.delayed(const Duration(seconds: 6));
          final detail = await reelsRepo.findById(createdId);
          activatedReel = detail;
        }
      }

      final reel = _ReelItem.fromJson(
          Map<String, dynamic>.from(activatedReel as Map? ?? {}));
      widget.onUploaded(reel);
    } catch (e) {
      debugPrint('Error uploading reel: $e');
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canSubmit =
        _selectedFile != null && _titleCtrl.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
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
            SizedBox(height: 16.h),
            Text('Subir nuevo Reel',
                style: TextStyle(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('Cargá un video con título y descripción breve.',
                style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
            SizedBox(height: 20.h),

            // Video file picker
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : Colors.black.withAlpha(25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.upload_file_rounded,
                          color: theme.colorScheme.primary, size: 22.r),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile != null
                                ? 'Video seleccionado'
                                : 'Seleccionar archivo de video',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            _selectedFile != null
                                ? _selectedFile!.path.split('/').last
                                : 'MP4, MOV, AVI...',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_selectedFile != null)
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 22.r),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Title
            _SheetField(
              ctrl: _titleCtrl,
              label: 'Título *',
              hint: 'Ej. Resultado final del proyecto',
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 12.h),

            // Description
            _SheetField(
              ctrl: _descCtrl,
              label: 'Descripción',
              hint: 'Contá qué muestra este reel y por qué es importante.',
              maxLines: 3,
            ),

            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isPublishing || !canSubmit) ? null : _submit,
                icon: Icon(
                    _isPublishing
                        ? Icons.hourglass_top_rounded
                        : Icons.video_call_rounded,
                    size: 20.r),
                label: Text(
                  _isPublishing ? 'Procesando...' : 'Crear Reel',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final int maxLines;
  final void Function(String)? onChanged;

  const _SheetField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
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
          maxLines: maxLines,
          onChanged: onChanged,
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

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18.r),
            SizedBox(height: 4.h),
            Text(value,
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
