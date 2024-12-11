//     "product": {
//       "id": 1,
//       "title": "아이폰 팝니다",
//       "user": {
//         "id": 1,
//         "username": "tester",
//         "nickname": "오상구",
//         "profileImage": {
//           "id": 1,
//           "url": "http://localhost:8080/api/file/0e78ead5-cf18-465b-8f23-c1342a26fa6d",
//           "originName": "sanggoo.jpeg",
//           "contentType": "image/jpeg",
//           "createdAt": "2024-11-13T16:48:35.131Z"
//         }
//       },
//       "address": {
//         "id": 1,
//         "fullName": "부산광역시 동래구 온천동",
//         "displayName": "온천동",
//         "defaultYn": true
//       },
//       "price": 100000
//     }

import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/user.dart';

class ChatProduct {
  int id;
  String title;
  User user;
  Address address;
  int price;
  ChatProduct({
    required this.id,
    required this.title,
    required this.user,
    required this.address,
    required this.price,
  });

  ChatProduct.fromJson(Map<String, dynamic> map)
      : this(
          id: map['id'],
          title: map['title'],
          user: User.fromJson(map['user']),
          address: Address.fromJson(map['address']),
          price: map['price'],
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user': user.toJson(),
      'address': address.toJson(),
      'price': price,
    };
  }
}
