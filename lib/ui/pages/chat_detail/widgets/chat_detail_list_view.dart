import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/date_time_utils.dart';
import 'package:flutter_market_app/data/model/chat_room.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/chat_repository.dart';
import 'package:flutter_market_app/ui/chat_global_view_model.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/chat_detail_page.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_market_app/ui/widgets/user_profile_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatDetailListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 채팅방 스트림 구독
    final chatRooms = ref.watch(chatGlobalViewModel).chatRooms;
    // 사용자 스트림 구독
    final userState = ref.watch(userGlobalViewModel);
    final user = userState?.user;

    if (user == null) {
      return const SizedBox();
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRooms[index];
          return ChatRoomListItem(chatRoom: chatRoom, currentUser: user);
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }
}

class ChatRoomListItem extends ConsumerWidget {
  final ChatRoom chatRoom;
  final User currentUser;

  const ChatRoomListItem({
    required this.chatRoom,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayUserId = currentUser.userId == chatRoom.sellerId
        ? chatRoom.buyerId
        : chatRoom.sellerId;

    // 상대방 사용자 정보 스트림 구독
    final otherUserState = ref.watch(userStreamProvider(displayUserId));

    return otherUserState.when(
      data: (displayUser) {
        if (displayUser == null) return const SizedBox();

        final displayDateTime = chatRoom.messages.isEmpty
            ? ''
            : DateTimeUtils.formatString(chatRoom.messages.last.timestamp);
        final message = chatRoom.messages.isEmpty
            ? ''
            : chatRoom.messages.last.originalContent;

        return GestureDetector(
          onTap: () {
            ref
                .read(chatGlobalViewModel.notifier)
                .fetchChatDetail(chatRoom.chatId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(),
              ),
            );
          },
          child: Container(
            height: 80,
            color: Colors.transparent,
            child: Row(
              children: [
                UserProfileImage(
                  dimension: 50,
                  imgUrl: displayUser.profileImageUrl,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${displayUser.nickname}님',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            displayDateTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(message),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

// 사용자 정보 스트림 Provider
final userStreamProvider = StreamProvider.family<User?, String>((ref, userId) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserStreamById(userId);
});
