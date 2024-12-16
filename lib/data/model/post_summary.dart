import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/file_model.dart';

class PostSummary {
  final String id;
  final String title;
  final FileModel thumbnail;
  final Address address;
  final num price;
  final int likeCnt;
  final DateTime updatedAt;
  final DateTime createdAt;

  const PostSummary({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.address,
    required this.price,
    required this.likeCnt,
    required this.updatedAt,
    required this.createdAt,
  });

  factory PostSummary.fromJson(Map<String, dynamic> map) {
    return PostSummary(
      id: map['id'],
      title: map['title'],
      thumbnail: FileModel.fromJson(map['thumbnail']),
      address: Address.fromJson(map['address']),
      price: map['price'],
      likeCnt: map['likeCnt'],
      updatedAt: DateTime.parse(map['updatedAt']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail.toJson(),
      'address': address.toJson(),
      'price': price,
      'likeCnt': likeCnt,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PostSummary copyWith({
    String? id,
    String? title,
    FileModel? thumbnail,
    Address? address,
    num? price,
    int? likeCnt,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return PostSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      address: address ?? this.address,
      price: price ?? this.price,
      likeCnt: likeCnt ?? this.likeCnt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
