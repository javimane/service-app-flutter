import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../core/data/repositories/chat_repository.dart';
import '../../../core/data/repositories/storage_repository.dart';
import '../../../core/services/upload_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? initialMessage;

  const ChatScreen({super.key, required this.chatId, this.initialMessage});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  Timer? _pollTimer;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _userId;
  
  Map<String, dynamic>? _otherProfile;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChat();
    });
  }

  Future<void> _initChat() async {
    final supabase = Supabase.instance.client;
    _userId = supabase.auth.currentUser?.id;
    if (_userId == null) return;

    // Fetch other user profile
    final profile = await ref.read(chatRepositoryProvider).getProfileByUserId(widget.chatId);
    if (mounted) {
      setState(() {
        _otherProfile = profile;
      });
    }

    await _fetchMessages();

    // Send initial message if present
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _controller.text = widget.initialMessage!;
      // Optional: automatically send it? We'll just pre-fill it for now.
    }

    // Polling
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchMessages(silent: true);
    });
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    if (_userId == null) return;
    
    if (!silent && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final repo = ref.read(chatRepositoryProvider);
      final messages = await repo.getMessages(userId: _userId!, receiverId: widget.chatId);
      
      // Mark as read
      await repo.markMessagesAsRead(userId: _userId!, senderId: widget.chatId);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        
        // Scroll to bottom
        if (!silent) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _userId == null) return;

    _controller.clear();
    
    // Optimistic UI update could go here, but we'll let polling/fetching handle it
    
    try {
      await ref.read(chatRepositoryProvider).sendMessage(
        senderId: _userId!,
        receiverId: widget.chatId,
        content: text,
      );
      await _fetchMessages(silent: true);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el mensaje: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_userId == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // compress to save bandwidth
      );

      if (image == null) return;
      final file = File(image.path);

      setState(() => _isUploading = true);

      // 1. Get Presigned URL
      final fileName = image.name;
      final storageRepo = ref.read(storageRepositoryProvider);
      
      final config = await storageRepo.getChatConfig(fileName);
      
      final signedUrl = config['signedUrl'];
      final publicUrl = config['publicUrl'];

      if (signedUrl == null || publicUrl == null) {
        throw Exception('No se pudo obtener la ruta del archivo.');
      }

      // 2. Upload directly to presigned URL
      await ref.read(uploadServiceProvider).uploadToPresignedUrl(
        uploadUrl: signedUrl,
        file: file,
      );

      // 3. Obtain a valid view URL from the backend to save in the message
      final viewUrlResponse = await storageRepo.getChatViewUrl(publicUrl);
      final fileUrlToSave = viewUrlResponse['signedUrl'] ?? publicUrl;

      // 4. Send message with file
      await ref.read(chatRepositoryProvider).sendMessage(
        senderId: _userId!,
        receiverId: widget.chatId,
        content: 'Archivo adjunto: $fileName',
        fileUrl: fileUrlToSave,
      );

      await _fetchMessages(silent: true);
      _scrollToBottom();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFFE85D35);

    final otherName = _otherProfile?['display_name'] ?? _otherProfile?['name'] ?? 'Usuario';
    final otherInitial = otherName.isNotEmpty ? otherName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: primaryColor,
                  child: Text(
                    otherInitial,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'En línea',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? Colors.white10 : Colors.black12,
            height: 1,
          ),
        ),
      ),
      body: CustomPaint(
        painter: _DottedBackgroundPainter(
          color: isDark
              ? Colors.white10
              : Colors.black.withAlpha((0.05 * 255).round()),
        ),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(
                          child: Text(
                            'No hay mensajes aún',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 24.h),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg['sender_id'] == _userId;
                            final time = _formatTime(msg['created_at']);
                            final isRead = msg['is_read'] == true;
                            final text = msg['content'] ?? '';
                            final fileUrl = msg['file_url'];

                            return Padding(
                              padding: EdgeInsets.only(bottom: 24.h),
                              child: isMe
                                  ? _buildSentMessage(
                                      text: text,
                                      time: time,
                                      isRead: isRead,
                                      primaryColor: primaryColor,
                                      fileUrl: fileUrl,
                                    )
                                  : _buildReceivedMessage(
                                      text: text,
                                      time: time,
                                      isDark: isDark,
                                      fileUrl: fileUrl,
                                    ),
                            );
                          },
                        ),
            ),
            _buildBottomInput(isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage({
    required String text,
    required String time,
    required bool isDark,
    String? fileUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: 60.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(4.r),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withAlpha((0.03 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fileUrl != null && fileUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          time,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildSentMessage({
    required String text,
    required String time,
    required bool isRead,
    required Color primaryColor,
    String? fileUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(left: 60.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(4.r),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withAlpha((0.3 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (fileUrl != null && fileUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '$time - ${isRead ? 'LEÍDO' : 'ENVIADO'}',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[500],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInput(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            _isUploading 
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: SizedBox(
                    width: 20.r, 
                    height: 20.r, 
                    child: const CircularProgressIndicator(strokeWidth: 2)
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickAndUploadImage,
                  color: Colors.grey[500],
                ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.transparent,
                  border: Border.all(
                    color: isDark ? Colors.transparent : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha((0.4 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: Colors.white,
                iconSize: 20.r,
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }
}

class _DottedBackgroundPainter extends CustomPainter {
  final Color color;

  _DottedBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
