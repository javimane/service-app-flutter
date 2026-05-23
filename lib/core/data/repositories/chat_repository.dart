import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/supabase_provider.dart';

class ChatRepository {
  final SupabaseClient _supabase;
  ChatRepository(this._supabase);

  Future<List<dynamic>> getMessages(
      {required String userId, required String receiverId}) async {
    final dynamic response = await _supabase
        .from('messages')
        .select()
        .or('and(sender_id.eq.$userId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$userId)')
        .order('created_at', ascending: true);
    if (response == null) {
      return [];
    }
    if (response is List) {
      return response;
    }
    if (response is Map && response['data'] != null) {
      return (response['data'] as List<dynamic>);
    }
    return [];
  }

  Future<Map<String, dynamic>> sendMessage(
      {required String senderId,
      required String receiverId,
      required String content,
      String? fileUrl}) async {
    final message = {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': false,
      'file_url': fileUrl,
    };
    final dynamic response =
        await _supabase.from('messages').insert(message).select().maybeSingle();
    if (response == null) {
      throw Exception('No response from supabase');
    }
    if (response is Map && response['data'] != null) {
      return (response['data'] as Map<String, dynamic>);
    }
    return response as Map<String, dynamic>;
  }

  Future<void> markMessagesAsRead(
      {required String userId, required String senderId}) async {
    final dynamic res = await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', userId)
        .eq('sender_id', senderId)
        .eq('is_read', false);
    if (res == null) {
      return;
    }
  }

  Future<List<dynamic>> getUserConversations({required String userId}) async {
    final dynamic res = await _supabase
        .from('messages')
        .select()
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);
    final messages = res is List
        ? res
        : (res is Map && res['data'] != null
            ? (res['data'] as List<dynamic>)
            : <dynamic>[]);

    final Map<String, Map<String, dynamic>> conversations = {};
    for (final msg in messages) {
      final otherId =
          msg['sender_id'] == userId ? msg['receiver_id'] : msg['sender_id'];
      if (!conversations.containsKey(otherId)) {
        conversations[otherId] = {
          'id': otherId,
          'message': msg['content'],
          'updated_at': msg['created_at'],
          'unreadCount':
              (msg['receiver_id'] == userId && msg['is_read'] == false) ? 1 : 0,
        };
      } else {
        if (msg['receiver_id'] == userId && msg['is_read'] == false) {
          conversations[otherId]!['unreadCount'] =
              (conversations[otherId]!['unreadCount'] as int) + 1;
        }
      }
    }

    return conversations.values.toList();
  }

  Future<List<dynamic>> getChatClients({required String userId}) async {
    final dynamic res = await _supabase
        .from('messages')
        .select('sender_id, receiver_id')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId');
    final messages = res is List
        ? res
        : (res is Map && res['data'] != null
            ? (res['data'] as List<dynamic>)
            : <dynamic>[]);
    final otherIds = <String>{};
    for (final m in messages) {
      final other =
          m['sender_id'] == userId ? m['receiver_id'] : m['sender_id'];
      otherIds.add(other.toString());
    }
    if (otherIds.isEmpty) return [];
    // Some Supabase clients may not support .in_ depending on version; fetch individually
    final profiles = <dynamic>[];
    for (final id in otherIds) {
      final dynamic p =
          await _supabase.from('profiles').select().eq('id', id).maybeSingle();
      if (p != null) {
        profiles.add(p is Map && p['data'] != null ? p['data'] : p);
      }
    }
    return profiles;
  }

  Future<Map<String, dynamic>?> getProfileByUserId(String id) async {
    final dynamic res =
        await _supabase.from('profiles').select().eq('id', id).maybeSingle();
    if (res == null) {
      return null;
    }
    if (res is Map && res['data'] != null) {
      return (res['data'] as Map<String, dynamic>);
    }
    return res as Map<String, dynamic>?;
  }

  // Real-time subscriptions removed: polling is used by the UI to fetch updates.
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.read(supabaseClientProvider));
});
