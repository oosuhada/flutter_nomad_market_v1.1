import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String messageId;
  String senderId;
  String originalContent;
  String translatedContent;
  DateTime timestamp;
  bool isRead;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.originalContent,
    required this.translatedContent,
    required this.timestamp,
    required this.isRead,
  });

  ChatMessage.fromJson(Map<String, dynamic> map)
      : this(
          messageId: map['messageId'],
          senderId: map['senderId'],
          originalContent: map['originalContent'],
          translatedContent: map['translatedContent'],
          timestamp: (map['timestamp'] as Timestamp).toDate(),
          isRead: map['isRead'],
        );

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'originalContent': originalContent,
      'translatedContent': translatedContent,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
