import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/data/repositories/chat_repository.dart';
import '../../../core/services/notification_service.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  Timer? _pollTimer;
  List<dynamic> _lastConversations = [];

  @override
  void initState() {
    super.initState();
    // start polling for new conversations/messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
          try {
            final messenger = ScaffoldMessenger.of(context);
            final convos = await ref
                .read(chatRepositoryProvider)
                .getUserConversations(userId: userId);
            // compare unread counts
            for (final c in convos) {
              final id = c['id'].toString();
              final prev = _lastConversations.firstWhere((e) => e['id'] == id,
                  orElse: () => null);
              final prevUnread =
                  prev != null ? (prev['unreadCount'] as int? ?? 0) : 0;
              final nowUnread = c['unreadCount'] as int? ?? 0;
              if (nowUnread > prevUnread) {
                final from = id;
                final last = c['message'] as String? ?? '';
                NotificationService.showNotification(
                    title: 'Mensaje de $from', body: last);
                messenger.showSnackBar(
                    SnackBar(content: Text('Nuevo mensaje de $from')));
              }
            }
            if (!mounted) return;
            _lastConversations = convos;
            setState(() {});
          } catch (_) {}
        });
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Row(
                children: [
                  Text(
                    'MENSAJES',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit_square, size: 24.r),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: Colors.transparent),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.05 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar en chats...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: userId == null
                  ? const Center(
                      child: Text('Inicia sesión para ver tus mensajes'))
                  : FutureBuilder<List<dynamic>>(
                      future: ref
                          .read(chatRepositoryProvider)
                          .getUserConversations(userId: userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        final convos = snapshot.data ?? [];
                        if (convos.isEmpty) {
                          return const Center(
                              child: Text('Sin conversaciones'));
                        }
                        return ListView.builder(
                          itemCount: convos.length,
                          itemBuilder: (context, index) {
                            final c = convos[index] as Map<String, dynamic>;
                            final name = c['id'] as String;
                            final last = c['message'] as String? ?? '';
                            final unread = c['unreadCount'] as int? ?? 0;
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 8.h),
                              leading: CircleAvatar(
                                  radius: 28.r,
                                  child:
                                      Text(name.substring(0, 2).toUpperCase())),
                              title: Text(name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp)),
                              subtitle: Text(last,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(c['updated_at']?.toString() ?? '',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12.sp)),
                                  if (unread > 0)
                                    Container(
                                      margin: EdgeInsets.only(top: 4.h),
                                      padding: EdgeInsets.all(6.r),
                                      decoration: BoxDecoration(
                                          color: theme.colorScheme.secondary,
                                          shape: BoxShape.circle),
                                      child: Text(unread.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                    )
                                ],
                              ),
                              onTap: () {
                                // abrir conversación individual
                                context.push('/chat/$name');
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
