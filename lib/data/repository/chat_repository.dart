import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class ChatRepository {
  final firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

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
  /// 채팅방 목록을 실시간으로 감시하는 스트림을 반환합니다.
  /// 현재 사용자가 참여한 채팅방만 필터링합니다.
  Stream<List<ChatRoom>> getChatRoomsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return firestore
        .collection('chat_rooms')
        .where('status', isEqualTo: 'active')
        .where(Filter.or(
          Filter('buyerId', isEqualTo: userId),
          Filter('sellerId', isEqualTo: userId),
        ))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['chatId'] = doc.id; // chatId 필드 추가
        return ChatRoom.fromJson(data);
      }).toList();
    });
  }

  /// 특정 채팅방의 실시간 업데이트를 감시하는 스트림을 반환합니다.
  Stream<ChatRoom?> getChatRoomStream(String roomId) {
    return firestore
        .collection('chat_rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['chatId'] = doc.id;
      return ChatRoom.fromJson(data);
    });
  }
}

