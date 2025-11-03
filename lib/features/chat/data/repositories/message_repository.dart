import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/cache_service.dart';
import '../models/message_model.dart';

class MessageRepository {
  final SupabaseClient _supabase;
  final CacheService? _cacheService;
  final _uuid = const Uuid();

  MessageRepository(this._supabase, [this._cacheService]);

  /// Get messages for a chat
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      final messages = response
          .map<MessageModel>((json) => MessageModel.fromJson(json))
          .toList();

      // Cache the messages
      await _cacheService?.cacheMessages(chatId, messages);

      return messages;
    } catch (e) {
      // Try to return cached data if available
      final cachedMessages = _cacheService?.getCachedMessages(chatId);
      if (cachedMessages != null && cachedMessages.isNotEmpty) {
        return cachedMessages;
      }
      throw Exception('Failed to get messages: $e');
    }
  }

  /// Send a text message
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    try {
      // Use microsecond precision for timestamp
      final now = DateTime.now().toUtc();
      final timestamp = now.toIso8601String();

      final message = {
        'id': _uuid.v4(),
        'chat_id': chatId,
        'sender_id': senderId,
        'content': content,
        'message_type': 'text',
        'created_at': timestamp,
        'status': 'sent',
        'is_read': false,
      };

      final response = await _supabase
          .from('messages')
          .insert(message)
          .select()
          .single();

      // Update chat's updated_at
      await _supabase
          .from('chats')
          .update({'updated_at': timestamp})
          .eq('id', chatId);

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Unable to send message. Please try again.');
    }
  }

  /// Send a media message
  Future<MessageModel> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String filePath,
    required String messageType,
  }) async {
    try {
      // Use microsecond precision for timestamp
      final now = DateTime.now().toUtc();
      final timestamp = now.toIso8601String();

      // Upload media file
      final fileName = '${_uuid.v4()}-${now.microsecondsSinceEpoch}';
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      await _supabase.storage.from('media').uploadBinary(fileName, bytes);

      final mediaUrl = _supabase.storage.from('media').getPublicUrl(fileName);

      // Create message
      final message = {
        'id': _uuid.v4(),
        'chat_id': chatId,
        'sender_id': senderId,
        'content': messageType == 'image' ? '📷 Photo' : '🎥 Video',
        'message_type': messageType,
        'media_url': mediaUrl,
        'created_at': timestamp,
        'status': 'sent',
        'is_read': false,
      };

      final response = await _supabase
          .from('messages')
          .insert(message)
          .select()
          .single();

      // Update chat's updated_at
      await _supabase
          .from('chats')
          .update({'updated_at': timestamp})
          .eq('id', chatId);

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Unable to send photo. Please try again.');
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'status': 'read',
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
    } catch (e) {
      // Silent fail - not critical for user experience
    }
  }

  /// Mark all messages in a chat as read
  Future<void> markChatMessagesAsRead(String chatId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'status': 'read',
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('chat_id', chatId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } catch (e) {
      // Silent fail - not critical for user experience
    }
  }

  /// Listen to messages in a chat
  Stream<List<MessageModel>> watchMessages(String chatId) async* {
    try {
      // Initial load - try cache first, then fetch
      List<MessageModel>? initialMessages;
      try {
        initialMessages = await getMessages(chatId);
      } catch (e) {
        // If fetch fails, try cache
        initialMessages = _cacheService?.getCachedMessages(chatId);
      }

      if (initialMessages != null) {
        yield initialMessages;
      }

      // Listen to changes
      final stream = _supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      await for (final data in stream) {
        final messages = data
            .map<MessageModel>((json) => MessageModel.fromJson(json))
            .toList();

        // Cache the updated messages
        await _cacheService?.cacheMessages(chatId, messages);

        yield messages;
      }
    } catch (e) {
      // Try to yield cached data if available
      final cachedMessages = _cacheService?.getCachedMessages(chatId);
      if (cachedMessages != null && cachedMessages.isNotEmpty) {
        yield cachedMessages;
      } else {
        throw Exception('Unable to load messages. Please try again.');
      }
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
    } catch (e) {
      throw Exception('Unable to delete message. Please try again.');
    }
  }

  /// Update message status
  Future<void> updateMessageStatus(String messageId, String status) async {
    try {
      await _supabase
          .from('messages')
          .update({'status': status})
          .eq('id', messageId);
    } catch (e) {
      // Silent fail - not critical for user experience
    }
  }
}
