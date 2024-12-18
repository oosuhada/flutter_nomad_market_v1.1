import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/chat_room.dart';
import 'package:flutter_market_app/data/repository/chat_repository.dart';

// 채팅 전역 상태 클래스
class ChatGlobalState {
  final List<ChatRoom> chatRooms; // 채팅방 목록
  final ChatRoom? chatRoom; // 현재 활성화된 채팅방
  final bool isLoading; // 로딩 상태
  final String? error; // 에러 메시지

  const ChatGlobalState({
    required this.chatRooms,
    this.chatRoom,
    this.isLoading = false,
    this.error,
  });

  // 불변성을 유지하면서 상태를 복사하는 메소드
  ChatGlobalState copyWith({
    List<ChatRoom>? chatRooms,
    ChatRoom? chatRoom,
    bool? isLoading,
    String? error,
  }) {
    return ChatGlobalState(
      chatRooms: chatRooms ?? this.chatRooms,
      chatRoom: chatRoom ?? this.chatRoom,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// AutoDisposeNotifier로 변경하여 자동 리소스 정리 지원
class ChatGlobalViewModel extends AutoDisposeNotifier<ChatGlobalState> {
  final chatRepository = ChatRepository();
  StreamSubscription? _chatRoomsSubscription;
  StreamSubscription? _currentRoomSubscription;

  @override
  ChatGlobalState build() {
    // onDispose를 사용하여 스트림 구독 정리
    ref.onDispose(() {
      print('ChatGlobalViewModel - 리소스 정리');
      _chatRoomsSubscription?.cancel();
      _currentRoomSubscription?.cancel();
    });

    // 초기 상태 설정 및 스트림 구독 시작
    _initializeStreams();
    return const ChatGlobalState(chatRooms: []);
  }

  // 스트림 초기화 및 구독
  void _initializeStreams() {
    state = state.copyWith(isLoading: true);

    try {
      // 채팅방 목록 스트림 구독
      _chatRoomsSubscription?.cancel();
      _chatRoomsSubscription = chatRepository
          .getChatRoomsStream()
          .distinct() // 중복 이벤트 필터링
          .listen(
        (rooms) {
          state = state.copyWith(
            chatRooms: rooms,
            isLoading: false,
          );
        },
        onError: (error) {
          state = state.copyWith(
            error: error.toString(),
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // 특정 채팅방 상세 정보 조회
  Future<void> fetchChatDetail(String roomId) async {
    try {
      state = state.copyWith(isLoading: true);

      // 기존 채팅방 구독 취소
      await _currentRoomSubscription?.cancel();

      // 새로운 채팅방 스트림 구독
      _currentRoomSubscription =
          chatRepository.getChatRoomStream(roomId).distinct().listen(
        (room) {
          state = state.copyWith(
            chatRoom: room,
            isLoading: false,
          );
        },
        onError: (error) {
          state = state.copyWith(
            error: error.toString(),
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // 새 채팅방 생성
  Future<String?> createChat(
      String postId, String sellerId, String buyerId) async {
    try {
      state = state.copyWith(isLoading: true);
      final result = await chatRepository.create(postId, sellerId, buyerId);
      if (result != null) {
        return result.chatId;
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 게시물 ID로 채팅방 찾기
  String? findChatRoomByPostId(String postId) {
    final target = state.chatRooms.where((e) => e.postId == postId).toList();
    return target.isNotEmpty ? target.first.chatId : null;
  }
}

// 전역 Provider 정의
final chatGlobalViewModel =
    NotifierProvider.autoDispose<ChatGlobalViewModel, ChatGlobalState>(() {
  return ChatGlobalViewModel();
});
