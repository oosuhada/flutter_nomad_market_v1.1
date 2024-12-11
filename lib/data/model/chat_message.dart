//       {
//         "id": 0,
//         "messageType": "SENDER_TO_PRODUCT_OWNER",
//         "content": "안녕하세요. 네고 가능할까요?",
//         "createdAt": "2024-11-13T16:48:35.131Z"
//       }

class ChatMessage {
  int id;
  String messageType;
  String content;
  DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.messageType,
    required this.content,
    required this.createdAt,
  });

  ChatMessage.fromJson(Map<String, dynamic> map)
      : this(
          id: map['id'],
          messageType: map['messageType'],
          content: map['content'],
          createdAt: DateTime.parse(map['createdAt']),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageType': messageType,
      'contetnt': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
