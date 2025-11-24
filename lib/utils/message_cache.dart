import '../models/message.dart';

/// Simple in-memory cache for messages to reduce API calls
class MessageCache {
  // Singleton instance
  static final MessageCache _instance = MessageCache._internal();
  factory MessageCache() => _instance;
  MessageCache._internal();

  // Cache storage: chatId -> List of messages
  final Map<String, List<Message>> _cache = {};
  
  // Cache expiry time (5 minutes)
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get cached messages for a chat
  /// Returns null if cache is empty or expired
  List<Message>? getCachedMessages(String chatId) {
    final timestamp = _cacheTimestamps[chatId];
    
    // Check if cache exists and is not expired
    if (timestamp != null && 
        DateTime.now().difference(timestamp) < _cacheExpiry) {
      return _cache[chatId];
    }
    
    // Cache expired or doesn't exist
    return null;
  }

  /// Cache messages for a chat
  void cacheMessages(String chatId, List<Message> messages) {
    _cache[chatId] = List.from(messages); // Create a copy
    _cacheTimestamps[chatId] = DateTime.now();
  }

  /// Add a single message to the cache
  void addMessage(String chatId, Message message) {
    if (_cache.containsKey(chatId)) {
      _cache[chatId]!.add(message);
      // Update timestamp to keep cache fresh
      _cacheTimestamps[chatId] = DateTime.now();
    }
  }

  /// Clear cache for a specific chat
  void clearChatCache(String chatId) {
    _cache.remove(chatId);
    _cacheTimestamps.remove(chatId);
  }

  /// Clear all cached messages
  void clearAll() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache size (number of cached chats)
  int get cacheSize => _cache.length;
}
