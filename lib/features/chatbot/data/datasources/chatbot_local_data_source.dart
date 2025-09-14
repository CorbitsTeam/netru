import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';

abstract class ChatbotLocalDataSource {
  /// Save chat session to local storage
  Future<void> saveSession(ChatSessionModel session);

  /// Get chat session from local storage
  Future<ChatSessionModel?> getSession(String sessionId);

  /// Get all sessions for a user
  Future<List<ChatSessionModel>> getUserSessions(String userId);

  /// Delete session from local storage
  Future<void> deleteSession(String sessionId);

  /// Save message to local storage
  Future<void> saveMessage(String sessionId, ChatMessageModel message);

  /// Get messages for a session
  Future<List<ChatMessageModel>> getSessionMessages(String sessionId);

  /// Clear all chat data
  Future<void> clearAllData();
}

class ChatbotLocalDataSourceImpl implements ChatbotLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _sessionsKey = 'chat_sessions';
  static const String _messagesPrefix = 'chat_messages_';

  ChatbotLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveSession(ChatSessionModel session) async {
    try {
      final existingSessions = await getUserSessions(session.userId);

      // Update existing session or add new one
      final sessionIndex = existingSessions.indexWhere(
        (s) => s.id == session.id,
      );
      if (sessionIndex != -1) {
        existingSessions[sessionIndex] = session;
      } else {
        existingSessions.add(session);
      }

      // Convert to JSON and save
      final sessionsJson = existingSessions.map((s) => s.toJson()).toList();
      await sharedPreferences.setString(
        '${_sessionsKey}_${session.userId}',
        jsonEncode(sessionsJson),
      );
    } catch (e) {
      throw Exception('خطأ في حفظ الجلسة: $e');
    }
  }

  @override
  Future<ChatSessionModel?> getSession(String sessionId) async {
    try {
      // We need userId to get sessions, so we'll search all user sessions
      final allKeys = sharedPreferences.getKeys();
      final sessionKeys =
          allKeys.where((key) => key.startsWith(_sessionsKey)).toList();

      for (final key in sessionKeys) {
        final sessionsData = sharedPreferences.getString(key);
        if (sessionsData != null) {
          final sessionsList = jsonDecode(sessionsData) as List<dynamic>;
          for (final sessionJson in sessionsList) {
            final session = ChatSessionModel.fromJson(
              sessionJson as Map<String, dynamic>,
            );
            if (session.id == sessionId) {
              return session;
            }
          }
        }
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب الجلسة: $e');
    }
  }

  @override
  Future<List<ChatSessionModel>> getUserSessions(String userId) async {
    try {
      final sessionsData = sharedPreferences.getString(
        '${_sessionsKey}_$userId',
      );
      if (sessionsData == null) return [];

      final sessionsList = jsonDecode(sessionsData) as List<dynamic>;
      return sessionsList
          .map(
            (sessionJson) =>
                ChatSessionModel.fromJson(sessionJson as Map<String, dynamic>),
          )
          .toList()
        ..sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        ); // Sort by most recent
    } catch (e) {
      throw Exception('خطأ في جلب جلسات المستخدم: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      // Find and remove session from all user session lists
      final allKeys = sharedPreferences.getKeys();
      final sessionKeys =
          allKeys.where((key) => key.startsWith(_sessionsKey)).toList();

      for (final key in sessionKeys) {
        final sessionsData = sharedPreferences.getString(key);
        if (sessionsData != null) {
          final sessionsList = jsonDecode(sessionsData) as List<dynamic>;
          final updatedSessions =
              sessionsList.where((sessionJson) {
                final session = ChatSessionModel.fromJson(
                  sessionJson as Map<String, dynamic>,
                );
                return session.id != sessionId;
              }).toList();

          if (updatedSessions.length != sessionsList.length) {
            // Session was found and removed
            await sharedPreferences.setString(key, jsonEncode(updatedSessions));
            // Also delete messages for this session
            await sharedPreferences.remove('$_messagesPrefix$sessionId');
            break;
          }
        }
      }
    } catch (e) {
      throw Exception('خطأ في حذف الجلسة: $e');
    }
  }

  @override
  Future<void> saveMessage(String sessionId, ChatMessageModel message) async {
    try {
      final existingMessages = await getSessionMessages(sessionId);

      // Update existing message or add new one
      final messageIndex = existingMessages.indexWhere(
        (m) => m.id == message.id,
      );
      if (messageIndex != -1) {
        existingMessages[messageIndex] = message;
      } else {
        existingMessages.add(message);
      }

      // Convert to JSON and save
      final messagesJson = existingMessages.map((m) => m.toJson()).toList();
      await sharedPreferences.setString(
        '$_messagesPrefix$sessionId',
        jsonEncode(messagesJson),
      );
    } catch (e) {
      throw Exception('خطأ في حفظ الرسالة: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getSessionMessages(String sessionId) async {
    try {
      final messagesData = sharedPreferences.getString(
        '$_messagesPrefix$sessionId',
      );
      if (messagesData == null) return [];

      final messagesList = jsonDecode(messagesData) as List<dynamic>;
      return messagesList
          .map(
            (messageJson) =>
                ChatMessageModel.fromJson(messageJson as Map<String, dynamic>),
          )
          .toList()
        ..sort(
          (a, b) => a.timestamp.compareTo(b.timestamp),
        ); // Sort chronologically
    } catch (e) {
      throw Exception('خطأ في جلب رسائل الجلسة: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      final allKeys = sharedPreferences.getKeys();
      final chatKeys =
          allKeys
              .where(
                (key) =>
                    key.startsWith(_sessionsKey) ||
                    key.startsWith(_messagesPrefix),
              )
              .toList();

      for (final key in chatKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw Exception('خطأ في مسح البيانات: $e');
    }
  }
}
