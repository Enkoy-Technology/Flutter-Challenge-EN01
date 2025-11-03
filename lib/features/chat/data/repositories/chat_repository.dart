import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/cache_service.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  final SupabaseClient _supabase;
  final CacheService? _cacheService;

  ChatRepository(this._supabase, [this._cacheService]);

  /// Get all chats for current user
  Future<List<ChatModel>> getChats(String userId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select('*')
          .contains('participant_ids', [userId])
          .order('updated_at', ascending: false);

      final chats = <ChatModel>[];

      for (final chatData in response) {
        final chat = await _enrichChatData(chatData, userId);
        chats.add(chat);
      }

      // Cache the chats
      await _cacheService?.cacheChats(chats);

      return chats;
    } catch (e) {
      // Try to return cached data if available
      final cachedChats = _cacheService?.getCachedChats();
      if (cachedChats != null && cachedChats.isNotEmpty) {
        return cachedChats;
      }
      throw Exception('Unable to load chats. Please try again.');
    }
  }

  /// Get or create a chat between two users
  Future<ChatModel> getOrCreateChat(String userId, String otherUserId) async {
    try {
      // Check if chat already exists
      final existingChats = await _supabase
          .from('chats')
          .select('*')
          .contains('participant_ids', [userId])
          .contains('participant_ids', [otherUserId]);

      if (existingChats.isNotEmpty) {
        return await _enrichChatData(existingChats.first, userId);
      }

      // Create new chat
      final newChat = {
        'participant_ids': [userId, otherUserId],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('chats')
          .insert(newChat)
          .select()
          .single();

      return await _enrichChatData(response, userId);
    } catch (e) {
      throw Exception('Unable to start chat. Please try again.');
    }
  }

  /// Get chat by ID
  Future<ChatModel> getChatById(String chatId, String userId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select('*')
          .eq('id', chatId)
          .single();

      return await _enrichChatData(response, userId);
    } catch (e) {
      throw Exception('Unable to load chat. Please try again.');
    }
  }

  /// Listen to chats updates
  Stream<List<ChatModel>> watchChats(String userId) async* {
    try {
      // Initial load - try cache first, then fetch
      List<ChatModel>? initialChats;
      try {
        initialChats = await getChats(userId);
      } catch (e) {
        // If fetch fails, try cache
        initialChats = _cacheService?.getCachedChats();
      }

      if (initialChats != null) {
        yield initialChats;
      }

      // Listen to messages table changes to refresh unread counts
      final messageStream = _supabase
          .from('messages')
          .stream(primaryKey: ['id']);

      await for (final _ in messageStream) {
        // Refresh all chats when any message changes
        final chats = <ChatModel>[];
        final chatData = await _supabase
            .from('chats')
            .select('*')
            .contains('participant_ids', [userId])
            .order('updated_at', ascending: false);

        for (final data in chatData) {
          final chat = await _enrichChatData(data, userId);
          chats.add(chat);
        }

        // Cache the updated chats
        await _cacheService?.cacheChats(chats);

        yield chats;
      }
    } catch (e) {
      // Try to yield cached data if available
      final cachedChats = _cacheService?.getCachedChats();
      if (cachedChats != null && cachedChats.isNotEmpty) {
        yield cachedChats;
      } else {
        throw Exception('Failed to watch chats: $e');
      }
    }
  }

  /// Search users
  Future<List<UserModel>> searchUsers(
    String query,
    String currentUserId,
  ) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .neq('id', currentUserId)
          .ilike('display_name', '%$query%')
          .limit(20);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get all users except current user
  Future<List<UserModel>> getAllUsers(String currentUserId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .neq('id', currentUserId)
          .order('display_name');

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Helper method to enrich chat data with last message and other user info
  Future<ChatModel> _enrichChatData(
    Map<String, dynamic> chatData,
    String currentUserId,
  ) async {
    final participantIds = (chatData['participant_ids'] as List<dynamic>)
        .map((e) => e as String)
        .toList();

    // Get other user
    final otherUserId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participantIds.first,
    );

    UserModel? otherUser;
    try {
      final userData = await _supabase
          .from('users')
          .select('*')
          .eq('id', otherUserId)
          .single();
      otherUser = UserModel.fromJson(userData);
    } catch (e) {
      // User not found, continue without user data
    }

    // Get last message
    MessageModel? lastMessage;
    try {
      final messageData = await _supabase
          .from('messages')
          .select('*')
          .eq('chat_id', chatData['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (messageData != null) {
        lastMessage = MessageModel.fromJson(messageData);
      }
    } catch (e) {
      // No messages yet
    }

    // Get unread count
    int unreadCount = 0;
    try {
      final unreadMessages = await _supabase
          .from('messages')
          .select('id')
          .eq('chat_id', chatData['id'])
          .neq('sender_id', currentUserId)
          .eq('is_read', false);

      unreadCount = unreadMessages.length;
    } catch (e) {
      // Error getting unread count
    }

    return ChatModel(
      id: chatData['id'] as String,
      participantIds: participantIds,
      createdAt: DateTime.parse(chatData['created_at'] as String),
      updatedAt: chatData['updated_at'] != null
          ? DateTime.parse(chatData['updated_at'] as String)
          : null,
      lastMessage: lastMessage,
      otherUser: otherUser,
      unreadCount: unreadCount,
    );
  }
}
