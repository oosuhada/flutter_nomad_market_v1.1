import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/date_time_utils.dart';
import 'package:flutter_market_app/data/model/chat_room.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/ui/chat_global_view_model.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/chat_detail_page.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_market_app/ui/widgets/user_profile_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatTabListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 채팅방 상태 감시
    final chatState = ref.watch(chatGlobalViewModel);
    final chatRooms = chatState.chatRooms;

    // 사용자 상태 감시
    final userState = ref.watch(userGlobalViewModel);
    final currentUser = userState.user!;

    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRooms[index];
          return ChatRoomItem(
            room: chatRoom,
            currentUser: currentUser,
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 1);
        },
      ),
    );
  }
}

// 채팅방 아이템을 별도 위젯으로 분리
class ChatRoomItem extends ConsumerWidget {
  final ChatRoom room;
  final User currentUser;

  const ChatRoomItem({
    Key? key,
    required this.room,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayUserId =
        currentUser.userId == room.sellerId ? room.buyerId : room.sellerId;

    // 상대방 사용자 정보 스트림 구독
    final otherUserState = ref.watch(userStreamProvider(displayUserId));

    return otherUserState.when(
      data: (displayUser) {
        if (displayUser == null) return const SizedBox();

        final displayDateTime = room.messages.isEmpty
            ? ''
            : DateTimeUtils.formatString(room.messages.last.timestamp);
        final message =
            room.messages.isEmpty ? '' : room.messages.last.originalContent;

        return GestureDetector(
          onTap: () {
            ref.read(chatGlobalViewModel.notifier).fetchChatDetail(room.chatId);
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
