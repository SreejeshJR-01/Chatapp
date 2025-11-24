import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const Chat({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    // Extract participant information from the participants array
    String participantId = '';
    String participantName = 'Unknown';
    
    if (json['participants'] != null && json['participants'] is List) {
      final participants = json['participants'] as List;
      if (participants.isNotEmpty) {
        final participant = participants[0] as Map<String, dynamic>;
        participantId = participant['_id'] as String? ?? '';
        participantName = participant['name'] as String? ?? 'Unknown';
      }
    }
    
    // Handle lastMessage - it could be a string or an object
    String? lastMessage;
    if (json['lastMessage'] != null) {
      if (json['lastMessage'] is String) {
        lastMessage = json['lastMessage'] as String;
      } else if (json['lastMessage'] is Map) {
        final msgObj = json['lastMessage'] as Map<String, dynamic>;
        lastMessage = msgObj['content'] as String? ?? msgObj['text'] as String?;
      }
    }
    
    return Chat(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      participantId: participantId,
      participantName: participantName,
      lastMessage: lastMessage,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  @override
  List<Object?> get props => [
        id,
        participantId,
        participantName,
        lastMessage,
        lastMessageTime,
        unreadCount,
      ];
}
