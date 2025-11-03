import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/chat/data/models/chat_model.dart';
import '../../features/chat/data/models/message_model.dart';

class CacheService {
  static const String _chatsKey = 'cached_chats';
  static const String _messagesKeyPrefix = 'cached_messages_';

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Cache chats list
  Future<void> cacheChats(List<ChatModel> chats) async {
    try {
      final jsonList = chats.map((chat) => chat.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_chatsKey, jsonString);
    } catch (e) {
      // Silent fail - caching is not critical
    }
  }

  /// Get cached chats
  List<ChatModel>? getCachedChats() {
    try {
      final jsonString = _prefs.getString(_chatsKey);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ChatModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache messages for a specific chat
  Future<void> cacheMessages(String chatId, List<MessageModel> messages) async {
    try {
      final jsonList = messages.map((msg) => msg.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString('$_messagesKeyPrefix$chatId', jsonString);
    } catch (e) {
      // Silent fail - caching is not critical
    }
  }

  /// Get cached messages for a specific chat
  List<MessageModel>? getCachedMessages(String chatId) {
    try {
      final jsonString = _prefs.getString('$_messagesKeyPrefix$chatId');
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_messagesKeyPrefix) || key == _chatsKey) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Clear cached messages for a specific chat
  Future<void> clearChatMessages(String chatId) async {
    try {
      await _prefs.remove('$_messagesKeyPrefix$chatId');
    } catch (e) {
      // Silent fail
    }
  }
}

