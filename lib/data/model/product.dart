// {
//     "id": 1,
//     "title": "아이폰 팝니다",
//     "content": "상태 A급입니다",
//     "imageFiles": [
//       {
//         "id": 1,
//         "url": "http://localhost:8080/api/file/0e78ead5-cf18-465b-8f23-c1342a26fa6d",
//         "originName": "sanggoo.jpeg",
//         "contentType": "image/jpeg",
//         "createdAt": "2024-11-13T13:33:44.242Z"
//       }
//     ],
//     "user": {
//       "id": 1,
//       "username": "tester",
//       "nickname": "오상구",
//       "profileImage": {
//         "id": 1,
//         "url": "http://localhost:8080/api/file/0e78ead5-cf18-465b-8f23-c1342a26fa6d",
//         "originName": "sanggoo.jpeg",
//         "contentType": "image/jpeg",
//         "createdAt": "2024-11-13T13:33:44.242Z"
//       }
//     },
//     "address": {
//       "id": 1,
//       "fullName": "부산광역시 동래구 온천동",
//       "displayName": "온천동",
//       "defaultYn": true
//     },
//     "category": {
//       "id": 1,
//       "category": "디지털가전"
//     },
//     "price": 10000,
//     "likeCnt": 10000,
//     "myLike": false,
//     "updatedAt": "2024-11-13T13:33:44.242Z",
//     "createdAt": "2024-11-13T13:33:44.242Z"
//   }

import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/data/model/user.dart';

class Product {
  int id;
  String title;
  String content;
  List<FileModel> imageFiles;
  User user;
  Address address;
  ProductCategory category;
  int price;
  int likeCnt;
  bool myLike;
  DateTime updatedAt;
  DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.content,
    required this.imageFiles,
    required this.user,
    required this.address,
    required this.category,
    required this.price,
    required this.likeCnt,
    required this.myLike,
    required this.updatedAt,
    required this.createdAt,
  });

  Product.fromJson(Map<String, dynamic> map)
      : this(
          id: map['id'],
          title: map['title'],
          content: map['content'],
          imageFiles: List.from(map['imageFiles'])
              .map((e) => FileModel.fromJson(e))
              .toList(),
          user: User.fromJson(map['user']),
          address: Address.fromJson(map['address']),
          category: ProductCategory.fromJson(map['category']),
          price: map['price'],
          likeCnt: map['likeCnt'],
          myLike: map['myLike'],
          updatedAt: DateTime.parse(map['updatedAt']),
          createdAt: DateTime.parse(map['createdAt']),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageFiles': imageFiles.map((e) => e.toJson()).toList(),
      'user': user.toJson(),
      'address': address.toJson(),
      'category': category.toJson(),
      'price': price,
      'likeCnt': likeCnt,
      'myLike': myLike,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // copyWith
  // 필요한 부분만 변경하고 새로운 객체로 만들 때 사용
  Product copyWith({
    int? id,
    String? title,
    String? content,
    List<FileModel>? imageFiles,
    User? user,
    Address? address,
    ProductCategory? category,
    int? price,
    int? likeCnt,
    bool? myLike,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageFiles: imageFiles ?? this.imageFiles,
      user: user ?? this.user,
      address: address ?? this.address,
      category: category ?? this.category,
      price: price ?? this.price,
      likeCnt: likeCnt ?? this.likeCnt,
      myLike: myLike ?? this.myLike,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
