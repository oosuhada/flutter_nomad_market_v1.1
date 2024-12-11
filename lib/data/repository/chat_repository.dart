import 'dart:async';
import 'dart:convert';

import 'package:flutter_market_app/data/model/chat_room.dart';
import 'package:flutter_market_app/data/repository/base_remote_repository.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRepository extends BaseRemoteRepository {
  //
  Future<List<ChatRoom>?> list() async {
    final response = await client.get('/api/chat/room/list');
    if (response.statusCode == 200) {
      final content = response.data['content'];
      return List.from(content)
          .map(
            (e) => ChatRoom.fromJson(e),
          )
          .toList();
    }

    return null;
  }

  Future<ChatRoom?> detail(int roomId) async {
    final response = await client.get('/api/chat/room/$roomId');
    if (response.statusCode == 200) {
      return ChatRoom.fromJson(response.data['content']);
    }

    return null;
  }

  Future<ChatRoom?> create(int productId) async {
    final response = await client.post('/api/chat/room/make/$productId');
    if (response.statusCode == 201) {
      return ChatRoom.fromJson(response.data['content']);
    }

    return null;
  }

// [요청 헤더]
//         {
//                 "transports": ["websocket"],
//                 "content-type": "application/octet-stream",
//                 "Authorization": "Barear YOUR_JWT",
//         }
// [구독 정보]
// 엔드포인트 : /user/queue/pub
// 수신 데이터 : 채팅 내역 상세와 동일
// [메시지 전송 정보]
// 엔드포인트 : /chat-socket/chat.send
// 송신 데이터 : {"content": "내용", "roomId": "1"}

  // Stream<ChatRoom>, void Function(int roomId, String message)
  ChatSocket connectSocket() {
    // host:8080/ws
    StompClient? stompCliet;
    final chatRoomStream = StreamController<ChatRoom>(onListen: () {
      stompCliet?.activate();
    }, onCancel: () {
      stompCliet?.deactivate();
    });

    stompCliet = StompClient(
      config: StompConfig.sockJS(
          url: '${client.options.baseUrl}/ws',
          webSocketConnectHeaders: {
            'transports': ["websocket"],
            'content-type': 'application/octet-stream',
            'Authorization': bearerToken,
          },
          onConnect: (frame) {
            // onConnect, 즉 웹소켓 연결이 완료된 후 구독!
            stompCliet?.subscribe(
              destination: '/user/queue/pub',
              callback: (frame) {
                if (frame.body != null) {
                  chatRoomStream
                      .add(ChatRoom.fromJson(jsonDecode(frame.body!)));
                }
              },
            );
          }),
    );
    // {"content": "내용", "roomId": "1"}

    return ChatSocket(
      messageStream: chatRoomStream.stream,
      sendMessage: ({required content, required roomId}) {
        stompCliet?.send(
            destination: '/chat-socket/chat.send',
            body: jsonEncode({
              'content': content,
              'roomId': roomId,
            }));
      },
    );
  }
}

class ChatSocket {
  final Stream<ChatRoom> messageStream;
  final void Function({
    required int roomId,
    required String content,
  }) sendMessage;

  ChatSocket({
    required this.messageStream,
    required this.sendMessage,
  });
}
