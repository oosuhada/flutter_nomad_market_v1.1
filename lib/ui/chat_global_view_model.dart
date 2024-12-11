// 1. 상태 클래스
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

// 2. 뷰모델
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

  // 리스트 가지고오기
  Future<void> fetchList() async {
    final result = await chatRepository.list();
    if (result != null) {
      state = state.copyWith(
        chatRooms: result,
      );
    }
  }

  // 디테일 가지고오기

  Future<void> fetchChatDetail(int roomId) async {
    final result = await chatRepository.detail(roomId);
    if (result != null) {
      state = state.copyWith(
        chatRoom: result,
      );
    }
  }

  // 채팅방 만들기
  Future<int?> createChat(int productId) async {
    final result = await chatRepository.create(productId);
    if (result != null) {
      state = state.copyWith(
        chatRooms: [result, ...state.chatRooms],
      );
      return result.roomId;
    }

    return null;
  }

  int? findChatRoomByProductId(int productId) {
    final target =
        state.chatRooms.where((e) => e.product.id == productId).toList();
    if (target.isNotEmpty) {
      return target.first.roomId;
    }

    return null;
  }

  ChatSocket? chatSocket;

  void connectSocket() {
    chatSocket = chatRepository.connectSocket();
    final subscription = chatSocket!.messageStream.listen((chatRoom) {
      // 1. chatRooms 업데이트
      final chatRooms = state.chatRooms;
      final target =
          chatRooms.where((e) => e.roomId == chatRoom.roomId).toList();
      if (target.isNotEmpty) {
        final newList = chatRooms.map((e) {
          if (e.roomId == chatRoom.roomId) {
            return chatRoom;
          }
          return e;
        }).toList();
        state = state.copyWith(
          chatRooms: newList,
        );
      } else {
        state = state.copyWith(
          chatRooms: [...chatRooms, chatRoom],
        );
      }
      // 2. chatRoom 업데이트
      final room = state.chatRoom;
      if (room?.roomId == chatRoom.roomId) {
        //
        state = state.copyWith(
          chatRoom: ChatRoom(
            roomId: room!.roomId,
            product: room.product,
            sender: room.sender,
            messages: [...room.messages, chatRoom.messages.first],
            createdAt: room.createdAt,
          ),
        );
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }

  void send(String content) {
    final room = state.chatRoom;
    if (room != null) {
      chatSocket?.sendMessage(
        content: content,
        roomId: room.roomId,
      );
    }
  }
}

// 3. 뷰모델 관리자
final chatGlobalViewModel =
    NotifierProvider<ChatGlobalViewModel, ChatGlobalState>(() {
  return ChatGlobalViewModel();
});
