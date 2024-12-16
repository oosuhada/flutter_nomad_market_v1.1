import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/chat_message.dart';

class ChatRoom {
  String chatId;
  String postId;
  String sellerId;
  String buyerId;
  ChatMessage? lastMessage;
  List<ChatMessage> messages;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  ChatRoom({
    required this.chatId,
    required this.postId,
    required this.sellerId,
    required this.buyerId,
    this.lastMessage,
    required this.messages,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatRoom.fromJson(Map<String, dynamic> map)
      : this(
          chatId: map['chatId'],
          postId: map['postId'],
          sellerId: map['sellerId'],
          buyerId: map['buyerId'],
          lastMessage: map['lastMessage'] != null
              ? ChatMessage.fromJson(map['lastMessage'])
              : null,
          messages: List.from(map['messages'])
              .map((e) => ChatMessage.fromJson(e))
              .toList(),
          status: map['status'],
          createdAt: (map['createdAt'] as Timestamp).toDate(),
          updatedAt: (map['updatedAt'] as Timestamp).toDate(),
        );

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'postId': postId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'lastMessage': lastMessage?.toJson(),
      'messages': messages.map((e) => e.toJson()).toList(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
