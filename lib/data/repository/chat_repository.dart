import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/chat_room.dart';

class ChatRepository {
  final firestore = FirebaseFirestore.instance;

  Future<List<ChatRoom>?> list() async {
    try {
      final querySnapshot = await firestore.collection('chat_rooms').get();
      return querySnapshot.docs
          .map((doc) => ChatRoom.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return null;
    }
  }

  Future<ChatRoom?> detail(String roomId) async {
    try {
      final docSnapshot =
          await firestore.collection('chat_rooms').doc(roomId).get();
      if (docSnapshot.exists) {
        return ChatRoom.fromJson(docSnapshot.data()!);
      }
    } catch (e) {
      print('Error fetching chat room detail: $e');
    }
    return null;
  }

  Future<ChatRoom?> create(
      String postId, String sellerId, String buyerId) async {
    try {
      final docRef = firestore.collection('chat_rooms').doc();
      final chatRoom = ChatRoom(
        chatId: docRef.id,
        postId: postId,
        sellerId: sellerId,
        buyerId: buyerId,
        lastMessage: null,
        messages: [],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(chatRoom.toJson());
      return chatRoom;
    } catch (e) {
      print('Error creating chat room: $e');
      return null;
    }
  }
}
