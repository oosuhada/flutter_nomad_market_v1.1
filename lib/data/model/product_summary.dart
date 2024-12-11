// {
//         "id": 1,
//         "title": "아이폰 팝니다",
//         "thumbnail": {
//           "id": 1,
//           "url": "http://localhost:8080/api/file/0e78ead5-cf18-465b-8f23-c1342a26fa6d",
//           "originName": "sanggoo.jpeg",
//           "contentType": "image/jpeg",
//           "createdAt": "2024-11-13T05:56:34.757Z"
//         },
//         "address": {
//           "id": 1,
//           "fullName": "부산광역시 동래구 온천동",
//           "displayName": "온천동",
//           "defaultYn": true
//         },
//         "price": 10000,
//         "likeCnt": 10000,
//         "updatedAt": "2024-11-13T05:56:34.757Z",
//         "createdAt": "2024-11-13T05:56:34.757Z"
//       }

import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/file_model.dart';

class ProductSummary {
  int id;
  String title;
  FileModel thumbnail;
  Address address;
  int price;
  int likeCnt;
  DateTime updatedAt;
  DateTime createdAt;

  ProductSummary({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.address,
    required this.price,
    required this.likeCnt,
    required this.updatedAt,
    required this.createdAt,
  });

  ProductSummary.fromJson(Map<String, dynamic> map)
      : this(
          id: map['id'],
          title: map['title'],
          thumbnail: FileModel.fromJson(map['thumbnail']),
          address: Address.fromJson(map['address']),
          price: map['price'],
          likeCnt: map['likeCnt'],
          updatedAt: DateTime.parse(map['updatedAt']),
          createdAt: DateTime.parse(map['createdAt']),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail.toJson(),
      'address': address.toJson(),
      'price': price,
      'likeCnt': likeCnt,
      'updatedAt': updatedAt.toIso8601String(),
      'createAt': createdAt.toIso8601String(),
    };
  }
}
