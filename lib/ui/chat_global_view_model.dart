import 'package:flutter_market_app/data/model/chat_room.dart';
import 'package:flutter_market_app/data/repository/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatGlobalState {
  List<ChatRoom> chatRooms;
  ChatRoom? chatRoom;
  ChatGlobalState({
    required this.chatRooms,
    required this.chatRoom,
  });

  ChatGlobalState copyWith({
    List<ChatRoom>? chatRooms,
    ChatRoom? chatRoom,
  }) {
    return ChatGlobalState(
      chatRooms: chatRooms ?? this.chatRooms,
      chatRoom: chatRoom ?? this.chatRoom,
    );
  }
}

class ChatGlobalViewModel extends Notifier<ChatGlobalState> {
  @override
  ChatGlobalState build() {
    fetchList().then((e) {
      connectSocket();
    });
    return ChatGlobalState(
      chatRooms: [],
      chatRoom: null,
    );
  }

  final chatRepository = ChatRepository();

  Future<void> fetchList() async {
    final result = await chatRepository.list();
    if (result != null) {
      state = state.copyWith(
        chatRooms: result,
      );
    }
  }

  Future<void> fetchChatDetail(String roomId) async {
    final result = await chatRepository.detail(roomId);
    if (result != null) {
      state = state.copyWith(
        chatRoom: result,
      );
    }
  }

  Future<String?> createChat(
      String postId, String sellerId, String buyerId) async {
    final result = await chatRepository.create(postId, sellerId, buyerId);
    if (result != null) {
      state = state.copyWith(
        chatRooms: [result, ...state.chatRooms],
      );
      return result.chatId;
    }
    return null;
  }

  String? findChatRoomByPostId(String postId) {
    final target = state.chatRooms.where((e) => e.postId == postId).toList();
    if (target.isNotEmpty) {
      return target.first.chatId;
    }
    return null;
  }

  void connectSocket() {
    // Implement socket connection logic if needed
  }

  void send(String content) {
    final room = state.chatRoom;
    if (room != null) {
      // Implement send message logic if needed
    }
  }
}

final chatGlobalViewModel =
    NotifierProvider<ChatGlobalViewModel, ChatGlobalState>(() {
  return ChatGlobalViewModel();
});
